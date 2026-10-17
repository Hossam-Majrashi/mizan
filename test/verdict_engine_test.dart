import 'package:flutter_test/flutter_test.dart';
import 'package:mizan/features/comparator/models/comparison_result.dart';
import 'package:mizan/features/comparator/models/video_item.dart';
import 'package:mizan/features/comparator/services/verdict_engine.dart';

void main() {
  group('VerdictEngine Priority and Decision Tests', () {
    final baseVideoA = VideoItem(
      id: 'A',
      path: '/path/to/video_a.mp4',
      fileName: 'video_a.mp4',
      fileSize: 104857600, // 100 MB
      duration: const Duration(minutes: 2),
      width: 1920,
      height: 1080,
      fps: 30.0,
      videoCodec: 'H.264',
      videoBitrate: 8000000,
      bitDepth: 8,
    );

    final baseVideoB = VideoItem(
      id: 'B',
      path: '/path/to/video_b.mp4',
      fileName: 'video_b.mp4',
      fileSize: 104857600, // 100 MB
      duration: const Duration(minutes: 2),
      width: 1920,
      height: 1080,
      fps: 30.0,
      videoCodec: 'H.264',
      videoBitrate: 8000000,
      bitDepth: 8,
    );

    test(
      '1. Identical videos report same quality and frames within tolerance',
      () {
        final metrics = ComparisonMetrics(
          effectiveResolutionA: '1920x1080 (Native)',
          effectiveResolutionB: '1920x1080 (Native)',
          effectiveResWinner: 'tie',
          sharpnessA: 80.0,
          sharpnessB: 80.0,
          sharpnessWinner: 'tie',
          artifactsA: 1.05,
          artifactsB: 1.05,
          artifactsWinner: 'tie',
          noiseA: 3.2,
          noiseB: 3.2,
          noiseWinner: 'tie',
          avgSsim: 0.9999,
          avgPsnr: 95.0,
          uniqueFpsA: 30.0,
          uniqueFpsB: 30.0,
          fpsWinner: 'tie',
          duplicatesA: 0,
          duplicatesB: 0,
          duplicatesWinner: 'tie',
          videoBitrateA: 8000000,
          videoBitrateB: 8000000,
          bitrateWinner: 'tie',
          videoCodecA: 'H.264',
          videoCodecB: 'H.264',
          codecWinner: 'tie',
          bitDepthA: 8,
          bitDepthB: 8,
          bitDepthWinner: 'tie',
          audioInfoA: 'AAC 192k',
          audioInfoB: 'AAC 192k',
          audioWinner: 'tie',
          fileSizeA: 100000000,
          fileSizeB: 100000000,
          fileSizeWinner: 'tie',
          isSameContent: true,
          contentDistance: 0.0,
        );

        final verdict = VerdictEngine.evaluate(
          videoA: baseVideoA,
          videoB: baseVideoB,
          metrics: metrics,
          samplePairs: [],
        );

        expect(verdict.verdictType, equals(VerdictType.same));
        expect(verdict.confidence, equals(ConfidenceLevel.high));
      },
    );

    test('2. Same video at lower resolution: higher resolution wins', () {
      final lowResB = VideoItem(
        id: 'B',
        path: '/path/to/video_720p.mp4',
        fileName: 'video_720p.mp4',
        fileSize: 50000000,
        duration: const Duration(minutes: 2),
        width: 1280,
        height: 720,
        fps: 30.0,
        videoCodec: 'H.264',
        videoBitrate: 4000000,
      );

      final metrics = ComparisonMetrics(
        effectiveResolutionA: '1920x1080 (Native)',
        effectiveResolutionB: '1280x720 (Native)',
        effectiveResWinner: 'A',
        sharpnessA: 85.0,
        sharpnessB: 50.0,
        sharpnessWinner: 'A',
        artifactsA: 1.05,
        artifactsB: 1.30,
        artifactsWinner: 'A',
        noiseA: 3.0,
        noiseB: 3.5,
        noiseWinner: 'A',
        avgSsim: 0.88,
        avgPsnr: 36.5,
        uniqueFpsA: 30.0,
        uniqueFpsB: 30.0,
        fpsWinner: 'tie',
        duplicatesA: 0,
        duplicatesB: 0,
        duplicatesWinner: 'tie',
        videoBitrateA: 8000000,
        videoBitrateB: 4000000,
        bitrateWinner: 'A',
        videoCodecA: 'H.264',
        videoCodecB: 'H.264',
        codecWinner: 'tie',
        bitDepthA: 8,
        bitDepthB: 8,
        bitDepthWinner: 'tie',
        audioInfoA: 'AAC 192k',
        audioInfoB: 'AAC 192k',
        audioWinner: 'tie',
        fileSizeA: 100000000,
        fileSizeB: 50000000,
        fileSizeWinner: 'B',
        isSameContent: true,
        contentDistance: 4.0,
      );

      final verdict = VerdictEngine.evaluate(
        videoA: baseVideoA,
        videoB: lowResB,
        metrics: metrics,
        samplePairs: [],
      );

      expect(verdict.verdictType, equals(VerdictType.winnerA));
      expect(verdict.winnerFileName, equals(baseVideoA.fileName));
    });

    test('3. Same video at lower bitrate: higher bitrate wins', () {
      final lowBitrateB = VideoItem(
        id: 'B',
        path: '/path/to/low_bitrate.mp4',
        fileName: 'low_bitrate.mp4',
        fileSize: 20000000,
        duration: const Duration(minutes: 2),
        width: 1920,
        height: 1080,
        fps: 30.0,
        videoCodec: 'H.264',
        videoBitrate: 1500000,
      );

      final metrics = ComparisonMetrics(
        effectiveResolutionA: '1920x1080 (Native)',
        effectiveResolutionB: '1920x1080 (Native)',
        effectiveResWinner: 'tie',
        sharpnessA: 82.0,
        sharpnessB: 68.0,
        sharpnessWinner: 'A',
        artifactsA: 1.08,
        artifactsB: 1.45,
        artifactsWinner: 'A',
        noiseA: 3.1,
        noiseB: 5.8,
        noiseWinner: 'A',
        avgSsim: 0.91,
        avgPsnr: 38.0,
        uniqueFpsA: 30.0,
        uniqueFpsB: 30.0,
        fpsWinner: 'tie',
        duplicatesA: 0,
        duplicatesB: 0,
        duplicatesWinner: 'tie',
        videoBitrateA: 8000000,
        videoBitrateB: 1500000,
        bitrateWinner: 'A',
        videoCodecA: 'H.264',
        videoCodecB: 'H.264',
        codecWinner: 'tie',
        bitDepthA: 8,
        bitDepthB: 8,
        bitDepthWinner: 'tie',
        audioInfoA: 'AAC 192k',
        audioInfoB: 'AAC 128k',
        audioWinner: 'A',
        fileSizeA: 100000000,
        fileSizeB: 20000000,
        fileSizeWinner: 'B',
        isSameContent: true,
        contentDistance: 3.0,
      );

      final verdict = VerdictEngine.evaluate(
        videoA: baseVideoA,
        videoB: lowBitrateB,
        metrics: metrics,
        samplePairs: [],
      );

      expect(verdict.verdictType, equals(VerdictType.winnerA));
      expect(verdict.winnerFileName, equals(baseVideoA.fileName));
    });

    test('4. Native 1080p vs Upscaled 720p: Native 1080p wins regardless of declared resolution', () {
      final upscaledA = VideoItem(
        id: 'A',
        path: '/path/to/upscaled_fake_1080p.mp4',
        fileName: 'upscaled_fake_1080p.mp4',
        fileSize: 120000000,
        duration: const Duration(minutes: 2),
        width: 1920,
        height: 1080,
        fps: 30.0,
        videoCodec: 'H.264',
        videoBitrate: 8500000,
      );

      final nativeB = VideoItem(
        id: 'B',
        path: '/path/to/native_1080p.mp4',
        fileName: 'native_1080p.mp4',
        fileSize: 90000000,
        duration: const Duration(minutes: 2),
        width: 1920,
        height: 1080,
        fps: 30.0,
        videoCodec: 'H.264',
        videoBitrate: 7000000,
      );

      final metrics = ComparisonMetrics(
        effectiveResolutionA: '1280x720 (Upscaled to 1080p)',
        effectiveResolutionB: '1920x1080 (Native)',
        effectiveResWinner: 'B',
        sharpnessA: 28.0,
        sharpnessB: 84.0,
        sharpnessWinner: 'B',
        artifactsA: 1.35,
        artifactsB: 1.05,
        artifactsWinner: 'B',
        noiseA: 4.5,
        noiseB: 2.8,
        noiseWinner: 'B',
        avgSsim: 0.89,
        avgPsnr: 37.2,
        uniqueFpsA: 30.0,
        uniqueFpsB: 30.0,
        fpsWinner: 'tie',
        duplicatesA: 0,
        duplicatesB: 0,
        duplicatesWinner: 'tie',
        videoBitrateA: 8500000,
        videoBitrateB: 7000000,
        bitrateWinner: 'A',
        videoCodecA: 'H.264',
        videoCodecB: 'H.264',
        codecWinner: 'tie',
        bitDepthA: 8,
        bitDepthB: 8,
        bitDepthWinner: 'tie',
        audioInfoA: 'AAC 192k',
        audioInfoB: 'AAC 192k',
        audioWinner: 'tie',
        fileSizeA: 120000000,
        fileSizeB: 90000000,
        fileSizeWinner: 'B',
        isSameContent: true,
        contentDistance: 5.0,
      );

      final verdict = VerdictEngine.evaluate(
        videoA: upscaledA,
        videoB: nativeB,
        metrics: metrics,
        samplePairs: [],
      );

      expect(verdict.verdictType, equals(VerdictType.winnerB));
      expect(verdict.winnerFileName, equals(nativeB.fileName));
    });

    test('5. 30 fps vs 60 fps duplicated: genuine frame completeness wins', () {
      final fake60fps = VideoItem(
        id: 'A',
        path: '/path/to/fake_60fps.mp4',
        fileName: 'fake_60fps.mp4',
        fileSize: 110000000,
        duration: const Duration(minutes: 2),
        width: 1920,
        height: 1080,
        fps: 60.0,
        videoCodec: 'H.264',
        videoBitrate: 8000000,
      );

      final genuine60fps = VideoItem(
        id: 'B',
        path: '/path/to/real_60fps.mp4',
        fileName: 'real_60fps.mp4',
        fileSize: 115000000,
        duration: const Duration(minutes: 2),
        width: 1920,
        height: 1080,
        fps: 60.0,
        videoCodec: 'H.264',
        videoBitrate: 8200000,
      );

      final metrics = ComparisonMetrics(
        effectiveResolutionA: '1920x1080 (Native)',
        effectiveResolutionB: '1920x1080 (Native)',
        effectiveResWinner: 'tie',
        sharpnessA: 80.0,
        sharpnessB: 81.0,
        sharpnessWinner: 'tie',
        artifactsA: 1.05,
        artifactsB: 1.05,
        artifactsWinner: 'tie',
        noiseA: 3.0,
        noiseB: 3.0,
        noiseWinner: 'tie',
        avgSsim: 0.98,
        avgPsnr: 44.0,
        uniqueFpsA: 30.0, // 30 fps repeated to 60 fps
        uniqueFpsB: 60.0,
        fpsWinner: 'B',
        duplicatesA: 30,
        duplicatesB: 0,
        duplicatesWinner: 'B',
        videoBitrateA: 8000000,
        videoBitrateB: 8200000,
        bitrateWinner: 'B',
        videoCodecA: 'H.264',
        videoCodecB: 'H.264',
        codecWinner: 'tie',
        bitDepthA: 8,
        bitDepthB: 8,
        bitDepthWinner: 'tie',
        audioInfoA: 'AAC 192k',
        audioInfoB: 'AAC 192k',
        audioWinner: 'tie',
        fileSizeA: 110000000,
        fileSizeB: 115000000,
        fileSizeWinner: 'A',
        isSameContent: true,
        contentDistance: 2.0,
      );

      final verdict = VerdictEngine.evaluate(
        videoA: fake60fps,
        videoB: genuine60fps,
        metrics: metrics,
        samplePairs: [],
      );

      expect(verdict.verdictType, equals(VerdictType.winnerB));
      expect(verdict.winnerFileName, equals(genuine60fps.fileName));
    });

    test('6. Two different videos: marked as low confidence with different content notice', () {
      final metrics = ComparisonMetrics(
        effectiveResolutionA: '1920x1080 (Native)',
        effectiveResolutionB: '1920x1080 (Native)',
        effectiveResWinner: 'tie',
        sharpnessA: 85.0,
        sharpnessB: 40.0,
        sharpnessWinner: 'A',
        artifactsA: 1.1,
        artifactsB: 1.2,
        artifactsWinner: 'A',
        noiseA: 3.0,
        noiseB: 4.0,
        noiseWinner: 'A',
        avgSsim: 0.35, // Completely different scenes
        avgPsnr: 14.5,
        uniqueFpsA: 30.0,
        uniqueFpsB: 30.0,
        fpsWinner: 'tie',
        duplicatesA: 0,
        duplicatesB: 0,
        duplicatesWinner: 'tie',
        videoBitrateA: 8000000,
        videoBitrateB: 8000000,
        bitrateWinner: 'tie',
        videoCodecA: 'H.264',
        videoCodecB: 'H.264',
        codecWinner: 'tie',
        bitDepthA: 8,
        bitDepthB: 8,
        bitDepthWinner: 'tie',
        audioInfoA: 'AAC 192k',
        audioInfoB: 'AAC 192k',
        audioWinner: 'tie',
        fileSizeA: 100000000,
        fileSizeB: 100000000,
        fileSizeWinner: 'tie',
        isSameContent: false, // Perceptual check failed!
        contentDistance: 38.0,
      );

      final verdict = VerdictEngine.evaluate(
        videoA: baseVideoA,
        videoB: baseVideoB,
        metrics: metrics,
        samplePairs: [],
      );

      expect(verdict.confidence, equals(ConfidenceLevel.low));
      expect(verdict.explanation, contains('different'));
    });

    test('7. Same stream in two different containers: reports same quality and frames', () {
      final mp4File = VideoItem(
        id: 'A',
        path: '/path/to/movie.mp4',
        fileName: 'movie.mp4',
        fileSize: 100000000,
        duration: const Duration(minutes: 5),
        width: 1920,
        height: 1080,
        fps: 24.0,
        videoCodec: 'H.264',
        videoBitrate: 6000000,
      );

      final mkvFile = VideoItem(
        id: 'B',
        path: '/path/to/movie.mkv',
        fileName: 'movie.mkv',
        fileSize: 100500000,
        duration: const Duration(minutes: 5),
        width: 1920,
        height: 1080,
        fps: 24.0,
        videoCodec: 'H.264',
        videoBitrate: 6000000,
      );

      final metrics = ComparisonMetrics(
        effectiveResolutionA: '1920x1080 (Native)',
        effectiveResolutionB: '1920x1080 (Native)',
        effectiveResWinner: 'tie',
        sharpnessA: 78.5,
        sharpnessB: 78.5,
        sharpnessWinner: 'tie',
        artifactsA: 1.04,
        artifactsB: 1.04,
        artifactsWinner: 'tie',
        noiseA: 2.9,
        noiseB: 2.9,
        noiseWinner: 'tie',
        avgSsim: 1.0,
        avgPsnr: 100.0,
        uniqueFpsA: 24.0,
        uniqueFpsB: 24.0,
        fpsWinner: 'tie',
        duplicatesA: 0,
        duplicatesB: 0,
        duplicatesWinner: 'tie',
        videoBitrateA: 6000000,
        videoBitrateB: 6000000,
        bitrateWinner: 'tie',
        videoCodecA: 'H.264',
        videoCodecB: 'H.264',
        codecWinner: 'tie',
        bitDepthA: 8,
        bitDepthB: 8,
        bitDepthWinner: 'tie',
        audioInfoA: 'AAC 256k',
        audioInfoB: 'AAC 256k',
        audioWinner: 'tie',
        fileSizeA: 100000000,
        fileSizeB: 100500000,
        fileSizeWinner: 'A',
        isSameContent: true,
        contentDistance: 0.0,
      );

      final verdict = VerdictEngine.evaluate(
        videoA: mp4File,
        videoB: mkvFile,
        metrics: metrics,
        samplePairs: [],
      );

      expect(verdict.verdictType, equals(VerdictType.same));
      expect(verdict.confidence, equals(ConfidenceLevel.high));
    });
  });
}
