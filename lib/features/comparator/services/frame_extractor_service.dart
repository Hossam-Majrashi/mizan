import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class FrameExtractorService {
  /// Extracts a decoded PNG frame at a specific timestamp
  static Future<Uint8List?> extractFrameAtTimestamp({
    required String filePath,
    required Duration timestamp,
  }) async {
    final timeStr = _formatDurationForFfmpeg(timestamp);

    try {
      final result = await Process.run('ffmpeg', [
        '-ss',
        timeStr,
        '-i',
        filePath,
        '-vframes',
        '1',
        '-f',
        'image2pipe',
        '-vcodec',
        'png',
        '-',
      ], stdoutEncoding: null);

      if (result.exitCode == 0 && result.stdout is List<int>) {
        final bytes = Uint8List.fromList(result.stdout as List<int>);
        if (bytes.isNotEmpty) {
          return bytes;
        }
      }
    } catch (e) {
      debugPrint('Direct ffmpeg pipe failed: $e');
    }

    // Fallback: create temporary file and delete immediately
    try {
      final tempDir = Directory.systemTemp.createTempSync('mizan_frame_');
      final tempOut = '${tempDir.path}/frame.png';

      final res = await Process.run('ffmpeg', [
        '-ss',
        timeStr,
        '-i',
        filePath,
        '-vframes',
        '1',
        '-y',
        tempOut,
      ]);

      if (res.exitCode == 0) {
        final outFile = File(tempOut);
        if (await outFile.exists()) {
          final bytes = await outFile.readAsBytes();
          // Immediately delete temporary directory
          tempDir.deleteSync(recursive: true);
          return bytes;
        }
      }
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}

    return null;
  }

  static String _formatDurationForFfmpeg(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    final millis = d.inMilliseconds % 1000;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${millis.toString().padLeft(3, '0')}';
  }

  /// Generates a test frame when testing or when decoding is not directly possible
  static Uint8List generateSyntheticFrame({
    required int width,
    required int height,
    required int frameIndex,
    required double sharpnessFactor,
  }) {
    final image = img.Image(width: width, height: height);
    final baseColor = (frameIndex * 40) % 200;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // High frequency pattern modulated by sharpness factor
        final pattern = (((x ~/ 4) + (y ~/ 4)) % 2 == 0)
            ? (50 * sharpnessFactor).round()
            : 0;
        final val = (baseColor + pattern).clamp(0, 255);
        image.setPixelRgba(x, y, val, val, val, 255);
      }
    }
    return Uint8List.fromList(img.encodePng(image));
  }
}
