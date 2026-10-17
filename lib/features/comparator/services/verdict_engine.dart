import '../models/comparison_result.dart';
import '../models/video_item.dart';

class VerdictEngine {
  /// Evaluates two videos according to the strict priority order:
  /// 1. Real pixels (effective resolution) & pixel-level picture quality (sharpness, artifacts, SSIM/PSNR).
  /// 2. Real unique frame rate and frame completeness.
  /// 3. Video bitrate, modern codec efficiency (AV1 > HEVC/VP9 > H.264), and bit depth.
  /// 4. Audio stream (tie-break only).
  /// 5. File size is informational only.
  static ComparisonVerdict evaluate({
    required VideoItem videoA,
    required VideoItem videoB,
    required ComparisonMetrics metrics,
    required List<FrameSamplePair> samplePairs,
    double tolerancePercentage = 0.03, // 3% default normal tolerance
  }) {
    // 1. Content Identity Check
    if (!metrics.isSameContent) {
      return ComparisonVerdict(
        verdictType: VerdictType.mixed,
        winnerFileName: videoA.fileName,
        confidence: ConfidenceLevel.low,
        explanation: 'Videos appear to contain different scenes or content (perceptual distance high). Marked with low confidence.',
        mixedDetails: [
          'Different content detected across sampled timestamps.',
          'Direct pixel comparison is not statistically representative.',
        ],
        metrics: metrics,
        samplePairs: samplePairs,
      );
    }

    // Check if within tolerance for "Same quality and frames"
    final resolutionSame = metrics.effectiveResWinner == 'tie';
    final sharpnessDiffRatio =
        (metrics.sharpnessA - metrics.sharpnessB).abs() /
        ((metrics.sharpnessA + metrics.sharpnessB) / 2.0 + 0.001);
    final artifactsDiffRatio =
        (metrics.artifactsA - metrics.artifactsB).abs() /
        ((metrics.artifactsA + metrics.artifactsB) / 2.0 + 0.001);
    final fpsDiffRatio =
        (metrics.uniqueFpsA - metrics.uniqueFpsB).abs() /
        ((metrics.uniqueFpsA + metrics.uniqueFpsB) / 2.0 + 0.001);

    final isSameQuality =
        resolutionSame &&
        sharpnessDiffRatio <= tolerancePercentage &&
        artifactsDiffRatio <= tolerancePercentage &&
        fpsDiffRatio <= tolerancePercentage &&
        metrics.avgSsim >= (1.0 - tolerancePercentage);

    if (isSameQuality) {
      final smallerNote = videoA.fileSize < videoB.fileSize
          ? '${videoA.fileName} is smaller by ${videoA.formattedSize}'
          : (videoB.fileSize < videoA.fileSize
                ? '${videoB.fileName} is smaller by ${videoB.formattedSize}'
                : 'Both have identical file size');

      return ComparisonVerdict(
        verdictType: VerdictType.same,
        winnerFileName: 'Both files',
        confidence: ConfidenceLevel.high,
        explanation:
            'Every measured pixel and frame metric is identical within the tolerance threshold. $smallerNote.',
        mixedDetails: [
          'SSIM is exceptionally high (${metrics.avgSsim.toStringAsFixed(4)}).',
          'No significant difference in effective resolution or frame uniqueness.',
        ],
        metrics: metrics,
        samplePairs: samplePairs,
      );
    }

    // Track points for overall priority verdict
    int scoreA = 0;
    int scoreB = 0;
    final winsA = <String>[];
    final winsB = <String>[];

    // Priority 1: Real Pixels (Effective Resolution) - Weight: 50
    if (metrics.effectiveResWinner == 'A') {
      scoreA += 50;
      winsA.add(
        'Higher effective resolution (${metrics.effectiveResolutionA})',
      );
    } else if (metrics.effectiveResWinner == 'B') {
      scoreB += 50;
      winsB.add(
        'Higher effective resolution (${metrics.effectiveResolutionB})',
      );
    }

    // Priority 1b: Picture Quality (Sharpness & Artifacts) - Weight: 35
    if (metrics.sharpnessWinner == 'A') {
      scoreA += 20;
      winsA.add('Superior fine detail and edge sharpness');
    } else if (metrics.sharpnessWinner == 'B') {
      scoreB += 20;
      winsB.add('Superior fine detail and edge sharpness');
    }

    if (metrics.artifactsWinner == 'A') {
      scoreA += 15;
      winsA.add('Fewer compression and block artifacts');
    } else if (metrics.artifactsWinner == 'B') {
      scoreB += 15;
      winsB.add('Fewer compression and block artifacts');
    }

    // Priority 2: Real Unique Frame Rate & Completeness - Weight: 25
    if (metrics.fpsWinner == 'A') {
      scoreA += 15;
      winsA.add(
        'Higher real unique framerate (${metrics.uniqueFpsA.toStringAsFixed(1)} fps)',
      );
    } else if (metrics.fpsWinner == 'B') {
      scoreB += 15;
      winsB.add(
        'Higher real unique framerate (${metrics.uniqueFpsB.toStringAsFixed(1)} fps)',
      );
    }

    if (metrics.duplicatesWinner == 'A') {
      scoreA += 10;
      winsA.add('Fewer repeated/duplicate frames');
    } else if (metrics.duplicatesWinner == 'B') {
      scoreB += 10;
      winsB.add('Fewer repeated/duplicate frames');
    }

    // Priority 3: Bitrate, Codec, Bit Depth - Weight: 15
    if (metrics.bitrateWinner == 'A') {
      scoreA += 7;
      winsA.add('Higher video bitrate');
    } else if (metrics.bitrateWinner == 'B') {
      scoreB += 7;
      winsB.add('Higher video bitrate');
    }

    if (metrics.codecWinner == 'A') {
      scoreA += 5;
      winsA.add('More efficient modern codec (${metrics.videoCodecA})');
    } else if (metrics.codecWinner == 'B') {
      scoreB += 5;
      winsB.add('More efficient modern codec (${metrics.videoCodecB})');
    }

    if (metrics.bitDepthWinner == 'A') {
      scoreA += 3;
      winsA.add('Higher color bit-depth (${metrics.bitDepthA}-bit)');
    } else if (metrics.bitDepthWinner == 'B') {
      scoreB += 3;
      winsB.add('Higher color bit-depth (${metrics.bitDepthB}-bit)');
    }

    // Priority 4: Audio (Tie-break only)
    if (scoreA == scoreB) {
      if (metrics.audioWinner == 'A') {
        scoreA += 1;
        winsA.add('Better audio stream (tie-breaker)');
      } else if (metrics.audioWinner == 'B') {
        scoreB += 1;
        winsB.add('Better audio stream (tie-breaker)');
      }
    }

    final scoreDiff = (scoreA - scoreB).abs();
    final isMixed = winsA.isNotEmpty && winsB.isNotEmpty && scoreDiff < 30;
    final winnerIsA = scoreA >= scoreB;
    final winnerFile = winnerIsA ? videoA.fileName : videoB.fileName;
    final otherFile = winnerIsA ? videoB.fileName : videoA.fileName;
    final winnerWins = winnerIsA ? winsA : winsB;
    final otherWins = winnerIsA ? winsB : winsA;

    ConfidenceLevel confidence = ConfidenceLevel.high;
    if (isMixed || scoreDiff < 25) {
      confidence = ConfidenceLevel.medium;
    }
    if (scoreDiff < 10) {
      confidence = ConfidenceLevel.low;
    }

    String explanation;
    if (winnerWins.isNotEmpty) {
      explanation = '$winnerFile is higher quality: ${winnerWins.first}.';
    } else {
      explanation = '$winnerFile shows better overall pixel characteristics.';
    }

    final mixedDetails = <String>[];
    if (isMixed) {
      mixedDetails.add('$winnerFile leads in: ${winnerWins.join(', ')}');
      mixedDetails.add(
        'However, $otherFile is ahead in: ${otherWins.join(', ')}',
      );
    } else {
      mixedDetails.addAll(winnerWins);
    }

    return ComparisonVerdict(
      verdictType: isMixed
          ? VerdictType.mixed
          : (winnerIsA ? VerdictType.winnerA : VerdictType.winnerB),
      winnerFileName: winnerFile,
      confidence: confidence,
      explanation: explanation,
      mixedDetails: mixedDetails,
      metrics: metrics,
      samplePairs: samplePairs,
    );
  }
}
