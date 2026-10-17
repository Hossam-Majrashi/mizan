import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mizan/features/comparator/services/quality_analysis_service.dart';

void main() {
  group('QualityAnalysisService Mathematical Algorithms', () {
    test('Identical images produce SSIM = 1.0 and PSNR = 100 dB', () {
      final imgA = img.Image(width: 64, height: 64);
      for (int y = 0; y < 64; y++) {
        for (int x = 0; x < 64; x++) {
          final c = (x * 3 + y * 2) % 255;
          imgA.setPixelRgba(x, y, c, c, c, 255);
        }
      }

      final ssim = QualityAnalysisService.calculateSsim(imgA, imgA);
      final psnr = QualityAnalysisService.calculatePsnr(imgA, imgA);

      expect(ssim, closeTo(1.0, 0.001));
      expect(psnr, equals(100.0));
    });

    test(
      'Sharp high-contrast image produces higher sharpness than blurred image',
      () {
        final sharpImg = img.Image(width: 64, height: 64);
        final blurImg = img.Image(width: 64, height: 64);

        for (int y = 0; y < 64; y++) {
          for (int x = 0; x < 64; x++) {
            final sharpVal = ((x ~/ 4) % 2 == 0) ? 255 : 0;
            sharpImg.setPixelRgba(x, y, sharpVal, sharpVal, sharpVal, 255);

            // Flat / smooth value
            final blurVal = (128 + x).clamp(0, 255);
            blurImg.setPixelRgba(x, y, blurVal, blurVal, blurVal, 255);
          }
        }

        final sharpScore = QualityAnalysisService.calculateSharpness(sharpImg);
        final blurScore = QualityAnalysisService.calculateSharpness(blurImg);

        expect(sharpScore, greaterThan(blurScore));
      },
    );

    test('Effective resolution detects upscaled low-sharpness 1080p', () {
      final nativeRes = QualityAnalysisService.detectEffectiveResolution(
        declaredWidth: 1920,
        declaredHeight: 1080,
        sharpness: 85.0,
        blockiness: 1.05,
      );
      expect(nativeRes, contains('Native'));

      final upscaledRes = QualityAnalysisService.detectEffectiveResolution(
        declaredWidth: 1920,
        declaredHeight: 1080,
        sharpness: 22.0,
        blockiness: 1.45,
      );
      expect(upscaledRes, contains('Upscaled'));
    });
  });
}
