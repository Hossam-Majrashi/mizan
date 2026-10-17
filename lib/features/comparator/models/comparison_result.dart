import 'dart:convert';
import 'dart:typed_data';

enum VerdictType { winnerA, winnerB, same, mixed }

enum ConfidenceLevel { high, medium, low }

class FrameSamplePair {
  final Duration timestamp;
  final Uint8List frameABytes;
  final Uint8List frameBBytes;
  final double ssim;
  final double psnr;
  final double sharpnessA;
  final double sharpnessB;

  const FrameSamplePair({
    required this.timestamp,
    required this.frameABytes,
    required this.frameBBytes,
    required this.ssim,
    required this.psnr,
    required this.sharpnessA,
    required this.sharpnessB,
  });

  String get formattedTimestamp {
    final m = timestamp.inMinutes;
    final s = timestamp.inSeconds % 60;
    final ms = (timestamp.inMilliseconds % 1000) ~/ 100;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.$ms';
  }
}

class ComparisonMetrics {
  final String effectiveResolutionA;
  final String effectiveResolutionB;
  final String effectiveResWinner; // 'A', 'B', 'tie'

  final double sharpnessA;
  final double sharpnessB;
  final String sharpnessWinner;

  final double artifactsA;
  final double artifactsB;
  final String artifactsWinner;

  final double noiseA;
  final double noiseB;
  final String noiseWinner;

  final double avgSsim;
  final double avgPsnr;

  final double uniqueFpsA;
  final double uniqueFpsB;
  final String fpsWinner;

  final int duplicatesA;
  final int duplicatesB;
  final String duplicatesWinner;

  final int videoBitrateA;
  final int videoBitrateB;
  final String bitrateWinner;

  final String videoCodecA;
  final String videoCodecB;
  final String codecWinner;

  final int bitDepthA;
  final int bitDepthB;
  final String bitDepthWinner;

  final String audioInfoA;
  final String audioInfoB;
  final String audioWinner;

  final int fileSizeA;
  final int fileSizeB;
  final String fileSizeWinner;

  final bool isSameContent;
  final double contentDistance;

  const ComparisonMetrics({
    required this.effectiveResolutionA,
    required this.effectiveResolutionB,
    required this.effectiveResWinner,
    required this.sharpnessA,
    required this.sharpnessB,
    required this.sharpnessWinner,
    required this.artifactsA,
    required this.artifactsB,
    required this.artifactsWinner,
    required this.noiseA,
    required this.noiseB,
    required this.noiseWinner,
    required this.avgSsim,
    required this.avgPsnr,
    required this.uniqueFpsA,
    required this.uniqueFpsB,
    required this.fpsWinner,
    required this.duplicatesA,
    required this.duplicatesB,
    required this.duplicatesWinner,
    required this.videoBitrateA,
    required this.videoBitrateB,
    required this.bitrateWinner,
    required this.videoCodecA,
    required this.videoCodecB,
    required this.codecWinner,
    required this.bitDepthA,
    required this.bitDepthB,
    required this.bitDepthWinner,
    required this.audioInfoA,
    required this.audioInfoB,
    required this.audioWinner,
    required this.fileSizeA,
    required this.fileSizeB,
    required this.fileSizeWinner,
    required this.isSameContent,
    required this.contentDistance,
  });

  Map<String, dynamic> toJson() {
    return {
      'effectiveResolution': {
        'videoA': effectiveResolutionA,
        'videoB': effectiveResolutionB,
        'winner': effectiveResWinner,
      },
      'sharpness': {
        'videoA': sharpnessA,
        'videoB': sharpnessB,
        'winner': sharpnessWinner,
      },
      'compressionArtifacts': {
        'videoA': artifactsA,
        'videoB': artifactsB,
        'winner': artifactsWinner,
      },
      'noiseLevel': {'videoA': noiseA, 'videoB': noiseB, 'winner': noiseWinner},
      'ssim': avgSsim,
      'psnr': avgPsnr,
      'framerate': {
        'videoA': uniqueFpsA,
        'videoB': uniqueFpsB,
        'winner': fpsWinner,
      },
      'duplicateFrames': {
        'videoA': duplicatesA,
        'videoB': duplicatesB,
        'winner': duplicatesWinner,
      },
      'videoBitrate': {
        'videoA': videoBitrateA,
        'videoB': videoBitrateB,
        'winner': bitrateWinner,
      },
      'codec': {
        'videoA': videoCodecA,
        'videoB': videoCodecB,
        'winner': codecWinner,
      },
      'bitDepth': {
        'videoA': bitDepthA,
        'videoB': bitDepthB,
        'winner': bitDepthWinner,
      },
      'audio': {
        'videoA': audioInfoA,
        'videoB': audioInfoB,
        'winner': audioWinner,
      },
      'fileSize': {
        'videoA': fileSizeA,
        'videoB': fileSizeB,
        'winner': fileSizeWinner,
      },
      'isSameContent': isSameContent,
    };
  }
}

class ComparisonVerdict {
  final VerdictType verdictType;
  final String winnerFileName;
  final ConfidenceLevel confidence;
  final String explanation;
  final List<String> mixedDetails;
  final ComparisonMetrics metrics;
  final List<FrameSamplePair> samplePairs;

  const ComparisonVerdict({
    required this.verdictType,
    required this.winnerFileName,
    required this.confidence,
    required this.explanation,
    required this.mixedDetails,
    required this.metrics,
    required this.samplePairs,
  });

  String toFormattedText({
    required String fileAName,
    required String fileBName,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('========================================');
    buffer.writeln('MIZAN - VIDEO QUALITY COMPARISON REPORT');
    buffer.writeln('========================================');
    buffer.writeln('Video A: $fileAName');
    buffer.writeln('Video B: $fileBName');
    buffer.writeln('----------------------------------------');
    buffer.writeln('VERDICT: ${verdictType.name.toUpperCase()}');
    buffer.writeln('Winner: $winnerFileName');
    buffer.writeln('Confidence: ${confidence.name.toUpperCase()}');
    buffer.writeln('Summary: $explanation');
    if (mixedDetails.isNotEmpty) {
      buffer.writeln('Detailed Observations:');
      for (final detail in mixedDetails) {
        buffer.writeln(' - $detail');
      }
    }
    buffer.writeln('----------------------------------------');
    buffer.writeln('MEASURED METRICS:');
    buffer.writeln(
      ' - Effective Resolution: A=${metrics.effectiveResolutionA} vs B=${metrics.effectiveResolutionB} (Winner: ${metrics.effectiveResWinner})',
    );
    buffer.writeln(
      ' - Sharpness Score: A=${metrics.sharpnessA.toStringAsFixed(1)} vs B=${metrics.sharpnessB.toStringAsFixed(1)} (Winner: ${metrics.sharpnessWinner})',
    );
    buffer.writeln(
      ' - Artifacts (Lower is better): A=${metrics.artifactsA.toStringAsFixed(2)} vs B=${metrics.artifactsB.toStringAsFixed(2)} (Winner: ${metrics.artifactsWinner})',
    );
    buffer.writeln(
      ' - Noise Level: A=${metrics.noiseA.toStringAsFixed(2)} vs B=${metrics.noiseB.toStringAsFixed(2)} (Winner: ${metrics.noiseWinner})',
    );
    buffer.writeln(' - SSIM: ${metrics.avgSsim.toStringAsFixed(4)}');
    buffer.writeln(' - PSNR: ${metrics.avgPsnr.toStringAsFixed(2)} dB');
    buffer.writeln(
      ' - Unique Framerate: A=${metrics.uniqueFpsA.toStringAsFixed(1)} fps vs B=${metrics.uniqueFpsB.toStringAsFixed(1)} fps',
    );
    buffer.writeln(
      ' - Duplicate Frames: A=${metrics.duplicatesA} vs B=${metrics.duplicatesB}',
    );
    buffer.writeln(
      ' - Video Codec: A=${metrics.videoCodecA} vs B=${metrics.videoCodecB}',
    );
    buffer.writeln(
      ' - Video Bitrate: A=${(metrics.videoBitrateA / 1000).toStringAsFixed(0)} kbps vs B=${(metrics.videoBitrateB / 1000).toStringAsFixed(0)} kbps',
    );
    buffer.writeln(
      ' - Bit Depth: A=${metrics.bitDepthA}-bit vs B=${metrics.bitDepthB}-bit',
    );
    buffer.writeln('========================================');
    return buffer.toString();
  }

  String toJsonString({required String fileAName, required String fileBName}) {
    final map = {
      'app': 'Mizan',
      'version': '1.0.0+1',
      'timestamp': DateTime.now().toIso8601String(),
      'videoA': fileAName,
      'videoB': fileBName,
      'verdict': verdictType.name,
      'winner': winnerFileName,
      'confidence': confidence.name,
      'explanation': explanation,
      'mixedDetails': mixedDetails,
      'metrics': metrics.toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}
