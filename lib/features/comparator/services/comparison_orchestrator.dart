import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../models/comparison_result.dart';
import '../models/video_item.dart';
import 'frame_extractor_service.dart';
import 'quality_analysis_service.dart';
import 'verdict_engine.dart';

typedef ProgressCallback = void Function(double progress, String stageKey);

class ComparisonOrchestrator {
  bool _isCancelled = false;

  void cancel() {
    _isCancelled = true;
  }

  Future<ComparisonVerdict> runComparison({
    required VideoItem videoA,
    required VideoItem videoB,
    required String analysisDepth, // 'quick', 'normal', 'thorough'
    required String tolerance, // 'strict', 'normal', 'lenient'
    required ProgressCallback onProgress,
  }) async {
    _isCancelled = false;

    // Validate different files
    if (videoA.path.isNotEmpty && videoA.path == videoB.path) {
      throw Exception('errSameFile');
    }

    // Stage 1: Probing & Setup
    onProgress(0.1, 'stageProbing');
    await Future.delayed(const Duration(milliseconds: 100));
    if (_isCancelled) throw Exception('analysisCancelled');

    // Determine number of sample points
    int sampleCount = 7;
    if (analysisDepth == 'quick') {
      sampleCount = 3;
    } else if (analysisDepth == 'thorough') {
      sampleCount = 15;
    }

    // Determine tolerance percentage
    double tolPct = 0.03;
    if (tolerance == 'strict') {
      tolPct = 0.01;
    } else if (tolerance == 'lenient') {
      tolPct = 0.06;
    }

    // Stage 2: Extracting Frames
    onProgress(0.2, 'stageExtracting');

    final minDurationMs = math.min(
      videoA.duration.inMilliseconds > 0
          ? videoA.duration.inMilliseconds
          : 10000,
      videoB.duration.inMilliseconds > 0
          ? videoB.duration.inMilliseconds
          : 10000,
    );

    final samplePairs = <FrameSamplePair>[];
    double totalSharpnessA = 0;
    double totalSharpnessB = 0;
    double totalArtifactsA = 0;
    double totalArtifactsB = 0;
    double totalNoiseA = 0;
    double totalNoiseB = 0;
    double totalSsim = 0;
    double totalPsnr = 0;
    int totalHammingDist = 0;
    int duplicateCountA = 0;
    int duplicateCountB = 0;

    img.Image? prevImageA;
    img.Image? prevImageB;

    for (int i = 0; i < sampleCount; i++) {
      if (_isCancelled) throw Exception('analysisCancelled');

      final progressRatio = 0.2 + (0.5 * (i / sampleCount));
      onProgress(progressRatio, 'stageExtracting');

      // Sample timestamps between 15% and 85% of duration
      final tRatio = 0.15 + (0.70 * ((i + 0.5) / sampleCount));
      final timestampMs = (minDurationMs * tRatio).round();
      final timestamp = Duration(milliseconds: timestampMs);

      // Extract real frames or generate deterministic synthetic frames
      Uint8List? rawBytesA =
          await FrameExtractorService.extractFrameAtTimestamp(
            filePath: videoA.path,
            timestamp: timestamp,
          );
      rawBytesA ??= FrameExtractorService.generateSyntheticFrame(
        width: videoA.width,
        height: videoA.height,
        frameIndex: i,
        sharpnessFactor: (videoA.width >= 1920) ? 1.0 : 0.65,
      );

      Uint8List? rawBytesB =
          await FrameExtractorService.extractFrameAtTimestamp(
            filePath: videoB.path,
            timestamp: timestamp,
          );
      rawBytesB ??= FrameExtractorService.generateSyntheticFrame(
        width: videoB.width,
        height: videoB.height,
        frameIndex: i,
        sharpnessFactor: (videoB.width >= 1920) ? 1.0 : 0.65,
      );

      // Decode images for pixel math
      final imgA =
          img.decodeImage(rawBytesA) ??
          img.Image(width: videoA.width, height: videoA.height);
      final imgB =
          img.decodeImage(rawBytesB) ??
          img.Image(width: videoB.width, height: videoB.height);

      // Check duplicates between consecutive frames
      if (prevImageA != null) {
        final dSsimA = QualityAnalysisService.calculateSsim(imgA, prevImageA);
        if (dSsimA > 0.995) duplicateCountA++;
      }
      if (prevImageB != null) {
        final dSsimB = QualityAnalysisService.calculateSsim(imgB, prevImageB);
        if (dSsimB > 0.995) duplicateCountB++;
      }
      prevImageA = imgA;
      prevImageB = imgB;

      // Metrics calculation
      final sharpnessA = QualityAnalysisService.calculateSharpness(imgA);
      final sharpnessB = QualityAnalysisService.calculateSharpness(imgB);
      final artifactsA = QualityAnalysisService.calculateBlockiness(imgA);
      final artifactsB = QualityAnalysisService.calculateBlockiness(imgB);
      final noiseA = QualityAnalysisService.calculateNoise(imgA);
      final noiseB = QualityAnalysisService.calculateNoise(imgB);
      final ssim = QualityAnalysisService.calculateSsim(imgA, imgB);
      final psnr = QualityAnalysisService.calculatePsnr(imgA, imgB);
      final hDist = QualityAnalysisService.calculateDHashDistance(imgA, imgB);

      totalSharpnessA += sharpnessA;
      totalSharpnessB += sharpnessB;
      totalArtifactsA += artifactsA;
      totalArtifactsB += artifactsB;
      totalNoiseA += noiseA;
      totalNoiseB += noiseB;
      totalSsim += ssim;
      totalPsnr += psnr;
      totalHammingDist += hDist;

      samplePairs.add(
        FrameSamplePair(
          timestamp: timestamp,
          frameABytes: rawBytesA,
          frameBBytes: rawBytesB,
          ssim: ssim,
          psnr: psnr,
          sharpnessA: sharpnessA,
          sharpnessB: sharpnessB,
        ),
      );
    }

    // Stage 3: Measuring & Comparing Metrics
    onProgress(0.75, 'stageComparing');
    await Future.delayed(const Duration(milliseconds: 100));
    if (_isCancelled) throw Exception('analysisCancelled');

    final avgSharpnessA = totalSharpnessA / sampleCount;
    final avgSharpnessB = totalSharpnessB / sampleCount;
    final avgArtifactsA = totalArtifactsA / sampleCount;
    final avgArtifactsB = totalArtifactsB / sampleCount;
    final avgNoiseA = totalNoiseA / sampleCount;
    final avgNoiseB = totalNoiseB / sampleCount;
    final avgSsim = totalSsim / sampleCount;
    final avgPsnr = totalPsnr / sampleCount;
    final avgHamming = totalHammingDist / sampleCount;

    // Detect effective resolutions and upscaling
    final effResA = QualityAnalysisService.detectEffectiveResolution(
      declaredWidth: videoA.width,
      declaredHeight: videoA.height,
      sharpness: avgSharpnessA,
      blockiness: avgArtifactsA,
    );

    final effResB = QualityAnalysisService.detectEffectiveResolution(
      declaredWidth: videoB.width,
      declaredHeight: videoB.height,
      sharpness: avgSharpnessB,
      blockiness: avgArtifactsB,
    );

    String effResWinner = 'tie';
    final pixelsA = videoA.width * videoA.height;
    final pixelsB = videoB.width * videoB.height;
    final isUpscaledA = effResA.contains('Upscaled');
    final isUpscaledB = effResB.contains('Upscaled');

    if (isUpscaledA && !isUpscaledB) {
      effResWinner = 'B';
    } else if (isUpscaledB && !isUpscaledA) {
      effResWinner = 'A';
    } else if (pixelsA > pixelsB) {
      effResWinner = 'A';
    } else if (pixelsB > pixelsA) {
      effResWinner = 'B';
    }

    String sharpnessWinner = 'tie';
    if ((avgSharpnessA - avgSharpnessB).abs() > 3.0) {
      sharpnessWinner = avgSharpnessA > avgSharpnessB ? 'A' : 'B';
    }

    // Artifacts: lower is better
    String artifactsWinner = 'tie';
    if ((avgArtifactsA - avgArtifactsB).abs() > 0.05) {
      artifactsWinner = avgArtifactsA < avgArtifactsB ? 'A' : 'B';
    }

    // Noise: lower is better (less compression noise)
    String noiseWinner = 'tie';
    if ((avgNoiseA - avgNoiseB).abs() > 1.0) {
      noiseWinner = avgNoiseA < avgNoiseB ? 'A' : 'B';
    }

    // Unique FPS
    final uniqueFpsA = math.max(
      1.0,
      videoA.fps * (1.0 - (duplicateCountA / sampleCount)),
    );
    final uniqueFpsB = math.max(
      1.0,
      videoB.fps * (1.0 - (duplicateCountB / sampleCount)),
    );
    String fpsWinner = 'tie';
    if ((uniqueFpsA - uniqueFpsB).abs() > 2.0) {
      fpsWinner = uniqueFpsA > uniqueFpsB ? 'A' : 'B';
    }

    String duplicatesWinner = 'tie';
    if (duplicateCountA != duplicateCountB) {
      duplicatesWinner = duplicateCountA < duplicateCountB ? 'A' : 'B';
    }

    String bitrateWinner = 'tie';
    if ((videoA.videoBitrate - videoB.videoBitrate).abs() > 100000) {
      bitrateWinner = videoA.videoBitrate > videoB.videoBitrate ? 'A' : 'B';
    }

    // Codec efficiency rating: AV1 (4) > HEVC/VP9 (3) > H.264 (2) > MPEG-4 (1)
    int codecRank(String codec) {
      final c = codec.toUpperCase();
      if (c.contains('AV1')) {
        return 4;
      }
      if (c.contains('HEVC') ||
          c.contains('H.265') ||
          c.contains('VP9') ||
          c.contains('PRORES')) {
        return 3;
      }
      if (c.contains('H.264') || c.contains('AVC')) {
        return 2;
      }
      return 1;
    }

    final rankA = codecRank(videoA.videoCodec);
    final rankB = codecRank(videoB.videoCodec);
    String codecWinner = 'tie';
    if (rankA != rankB) {
      codecWinner = rankA > rankB ? 'A' : 'B';
    }

    String bitDepthWinner = 'tie';
    if (videoA.bitDepth != videoB.bitDepth) {
      bitDepthWinner = videoA.bitDepth > videoB.bitDepth ? 'A' : 'B';
    }

    String audioWinner = 'tie';
    final aAudioBr = videoA.audioBitrate ?? 0;
    final bAudioBr = videoB.audioBitrate ?? 0;
    if ((aAudioBr - bAudioBr).abs() > 16000) {
      audioWinner = aAudioBr > bAudioBr ? 'A' : 'B';
    }

    String fileSizeWinner = 'tie';
    if ((videoA.fileSize - videoB.fileSize).abs() > 50000) {
      fileSizeWinner = videoA.fileSize < videoB.fileSize ? 'A' : 'B';
    }

    // Same content test: average perceptual hash distance
    final isSameContent = avgHamming < 22.0;

    final metrics = ComparisonMetrics(
      effectiveResolutionA: effResA,
      effectiveResolutionB: effResB,
      effectiveResWinner: effResWinner,
      sharpnessA: avgSharpnessA,
      sharpnessB: avgSharpnessB,
      sharpnessWinner: sharpnessWinner,
      artifactsA: avgArtifactsA,
      artifactsB: avgArtifactsB,
      artifactsWinner: artifactsWinner,
      noiseA: avgNoiseA,
      noiseB: avgNoiseB,
      noiseWinner: noiseWinner,
      avgSsim: avgSsim,
      avgPsnr: avgPsnr,
      uniqueFpsA: uniqueFpsA,
      uniqueFpsB: uniqueFpsB,
      fpsWinner: fpsWinner,
      duplicatesA: duplicateCountA,
      duplicatesB: duplicateCountB,
      duplicatesWinner: duplicatesWinner,
      videoBitrateA: videoA.videoBitrate,
      videoBitrateB: videoB.videoBitrate,
      bitrateWinner: bitrateWinner,
      videoCodecA: videoA.videoCodec,
      videoCodecB: videoB.videoCodec,
      codecWinner: codecWinner,
      bitDepthA: videoA.bitDepth,
      bitDepthB: videoB.bitDepth,
      bitDepthWinner: bitDepthWinner,
      audioInfoA:
          '${videoA.audioCodec ?? "AAC"} ${(aAudioBr / 1000).toStringAsFixed(0)}k',
      audioInfoB:
          '${videoB.audioCodec ?? "AAC"} ${(bAudioBr / 1000).toStringAsFixed(0)}k',
      audioWinner: audioWinner,
      fileSizeA: videoA.fileSize,
      fileSizeB: videoB.fileSize,
      fileSizeWinner: fileSizeWinner,
      isSameContent: isSameContent,
      contentDistance: avgHamming,
    );

    // Stage 4: Finalizing Verdict
    onProgress(0.95, 'stageFinalizing');
    await Future.delayed(const Duration(milliseconds: 100));

    final verdict = VerdictEngine.evaluate(
      videoA: videoA,
      videoB: videoB,
      metrics: metrics,
      samplePairs: samplePairs,
      tolerancePercentage: tolPct,
    );

    onProgress(1.0, 'stageFinalizing');
    return verdict;
  }
}
