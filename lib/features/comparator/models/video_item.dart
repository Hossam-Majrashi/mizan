import 'dart:typed_data';

class VideoItem {
  final String id; // 'A' or 'B'
  final String path;
  final String fileName;
  final int fileSize;
  final Duration duration;
  final int width;
  final int height;
  final double fps;
  final String videoCodec;
  final String? audioCodec;
  final int? audioBitrate;
  final int? audioChannels;
  final int? audioSampleRate;
  final int videoBitrate;
  final int bitDepth;
  final String colorSpace;
  final bool hasHdr;
  final Uint8List? thumbnailBytes;

  const VideoItem({
    required this.id,
    required this.path,
    required this.fileName,
    required this.fileSize,
    required this.duration,
    required this.width,
    required this.height,
    required this.fps,
    required this.videoCodec,
    this.audioCodec,
    this.audioBitrate,
    this.audioChannels,
    this.audioSampleRate,
    required this.videoBitrate,
    this.bitDepth = 8,
    this.colorSpace = 'BT.709',
    this.hasHdr = false,
    this.thumbnailBytes,
  });

  String get resolutionText => '${width}x$height';

  String get formattedSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    }
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
