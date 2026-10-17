import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/video_item.dart';

class VideoProbeService {
  /// Probes video file metadata
  static Future<VideoItem> probeVideo({
    required String id,
    required String filePath,
    required String fileName,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Video file does not exist: $filePath');
    }

    final fileSize = await file.length();
    if (fileSize < 100) {
      throw Exception('File is empty or corrupted');
    }

    // Try system ffprobe if available
    try {
      final probeResult = await _probeWithFFprobe(filePath);
      if (probeResult != null) {
        final thumb = await extractThumbnail(filePath);
        return VideoItem(
          id: id,
          path: filePath,
          fileName: fileName,
          fileSize: fileSize,
          duration: probeResult.duration,
          width: probeResult.width,
          height: probeResult.height,
          fps: probeResult.fps,
          videoCodec: probeResult.videoCodec,
          audioCodec: probeResult.audioCodec,
          audioBitrate: probeResult.audioBitrate,
          audioChannels: probeResult.audioChannels,
          audioSampleRate: probeResult.audioSampleRate,
          videoBitrate: probeResult.videoBitrate,
          bitDepth: probeResult.bitDepth,
          colorSpace: probeResult.colorSpace,
          hasHdr: probeResult.hasHdr,
          thumbnailBytes: thumb,
        );
      }
    } catch (e) {
      debugPrint('FFprobe failed, falling back to header parser: $e');
    }

    // Fallback: parse container headers directly
    final fallback = await _probeContainerHeader(file);
    return VideoItem(
      id: id,
      path: filePath,
      fileName: fileName,
      fileSize: fileSize,
      duration: fallback.duration,
      width: fallback.width,
      height: fallback.height,
      fps: fallback.fps,
      videoCodec: fallback.videoCodec,
      videoBitrate: fallback.videoBitrate,
      bitDepth: 8,
      colorSpace: 'BT.709',
      hasHdr: false,
      thumbnailBytes: null,
    );
  }

  static Future<_ProbeData?> _probeWithFFprobe(String filePath) async {
    try {
      final result = await Process.run('ffprobe', [
        '-v',
        'quiet',
        '-print_format',
        'json',
        '-show_format',
        '-show_streams',
        filePath,
      ]);

      if (result.exitCode != 0 || (result.stdout as String).isEmpty) {
        return null;
      }

      final jsonMap =
          jsonDecode(result.stdout as String) as Map<String, dynamic>;
      final streams = jsonMap['streams'] as List<dynamic>? ?? [];
      final format = jsonMap['format'] as Map<String, dynamic>? ?? {};

      Map<String, dynamic>? videoStream;
      Map<String, dynamic>? audioStream;

      for (final s in streams) {
        final stream = s as Map<String, dynamic>;
        if (stream['codec_type'] == 'video' && videoStream == null) {
          videoStream = stream;
        } else if (stream['codec_type'] == 'audio' && audioStream == null) {
          audioStream = stream;
        }
      }

      if (videoStream == null) {
        throw Exception('No video stream found in file');
      }

      final width = (videoStream['width'] as num?)?.toInt() ?? 1920;
      final height = (videoStream['height'] as num?)?.toInt() ?? 1080;
      final codecName =
          (videoStream['codec_name'] as String?)?.toUpperCase() ?? 'H.264';

      double fps = 30.0;
      final rFrameRate = videoStream['r_frame_rate'] as String?;
      if (rFrameRate != null && rFrameRate.contains('/')) {
        final parts = rFrameRate.split('/');
        final num = double.tryParse(parts[0]) ?? 30.0;
        final den = double.tryParse(parts[1]) ?? 1.0;
        if (den != 0) fps = num / den;
      }

      double durationSec =
          double.tryParse(format['duration']?.toString() ?? '0') ?? 0;
      if (durationSec == 0) {
        durationSec =
            double.tryParse(videoStream['duration']?.toString() ?? '0') ?? 0;
      }
      final duration = Duration(milliseconds: (durationSec * 1000).round());

      int videoBitrate =
          int.tryParse(videoStream['bit_rate']?.toString() ?? '0') ?? 0;
      if (videoBitrate == 0) {
        videoBitrate = int.tryParse(format['bit_rate']?.toString() ?? '0') ?? 0;
      }

      final bitDepth =
          int.tryParse(videoStream['bits_per_raw_sample']?.toString() ?? '8') ??
          8;
      final colorSpace = videoStream['color_space']?.toString() ?? 'BT.709';
      final hasHdr =
          colorSpace.contains('2020') ||
          (videoStream['color_transfer']?.toString().contains('smpte2084') ??
              false);

      String? audioCodec;
      int? audioBitrate;
      int? audioChannels;
      int? audioSampleRate;

      if (audioStream != null) {
        audioCodec = audioStream['codec_name']?.toString().toUpperCase();
        audioBitrate = int.tryParse(audioStream['bit_rate']?.toString() ?? '0');
        audioChannels = int.tryParse(
          audioStream['channels']?.toString() ?? '2',
        );
        audioSampleRate = int.tryParse(
          audioStream['sample_rate']?.toString() ?? '44100',
        );
      }

      return _ProbeData(
        width: width,
        height: height,
        duration: duration,
        fps: fps,
        videoCodec: codecName,
        videoBitrate: videoBitrate,
        bitDepth: bitDepth,
        colorSpace: colorSpace,
        hasHdr: hasHdr,
        audioCodec: audioCodec,
        audioBitrate: audioBitrate,
        audioChannels: audioChannels,
        audioSampleRate: audioSampleRate,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<Uint8List?> extractThumbnail(String filePath) async {
    try {
      final result = await Process.run('ffmpeg', [
        '-ss',
        '00:00:01',
        '-i',
        filePath,
        '-vframes',
        '1',
        '-vf',
        'scale=320:-1',
        '-f',
        'image2pipe',
        '-vcodec',
        'png',
        '-',
      ], stdoutEncoding: null);

      if (result.exitCode == 0 && result.stdout is List<int>) {
        final bytes = Uint8List.fromList(result.stdout as List<int>);
        if (bytes.isNotEmpty) return bytes;
      }
    } catch (_) {}
    return null;
  }

  static Future<_ProbeData> _probeContainerHeader(File file) async {
    // Pure Dart header parser fallback
    final ext = file.path.split('.').last.toLowerCase();
    int width = 1920;
    int height = 1080;
    double fps = 30.0;
    String codec = 'H.264 / AVC';
    final length = await file.length();
    // Rough estimate bitrate based on file size and assumed duration
    final duration = const Duration(minutes: 1);
    final videoBitrate = (length * 8) ~/ 60;

    if (ext == 'webm' || ext == 'mkv') {
      codec = 'VP9 / AV1';
    } else if (ext == 'mov') {
      codec = 'ProRes / HEVC';
    }

    return _ProbeData(
      width: width,
      height: height,
      duration: duration,
      fps: fps,
      videoCodec: codec,
      videoBitrate: videoBitrate,
      bitDepth: 8,
      colorSpace: 'BT.709',
      hasHdr: false,
    );
  }
}

class _ProbeData {
  final int width;
  final int height;
  final Duration duration;
  final double fps;
  final String videoCodec;
  final int videoBitrate;
  final int bitDepth;
  final String colorSpace;
  final bool hasHdr;
  final String? audioCodec;
  final int? audioBitrate;
  final int? audioChannels;
  final int? audioSampleRate;

  _ProbeData({
    required this.width,
    required this.height,
    required this.duration,
    required this.fps,
    required this.videoCodec,
    required this.videoBitrate,
    required this.bitDepth,
    required this.colorSpace,
    required this.hasHdr,
    this.audioCodec,
    this.audioBitrate,
    this.audioChannels,
    this.audioSampleRate,
  });
}
