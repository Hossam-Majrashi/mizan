import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class QualityAnalysisService {
  /// Calculate luminance array from an image
  static Float32List _toLuminance(img.Image image) {
    final length = image.width * image.height;
    final lum = Float32List(length);
    int idx = 0;
    for (final pixel in image) {
      // Standard Rec.709 luminance
      lum[idx++] = 0.2126 * pixel.r + 0.7152 * pixel.g + 0.0722 * pixel.b;
    }
    return lum;
  }

  /// Sharpness: Laplacian variance calculation
  static double calculateSharpness(img.Image image) {
    if (image.width < 3 || image.height < 3) return 0.0;
    final w = image.width;
    final h = image.height;
    final lum = _toLuminance(image);

    double sum = 0.0;
    double sumSq = 0.0;
    int count = 0;

    // 3x3 Laplacian kernel: [0, 1, 0; 1, -4, 1; 0, 1, 0]
    for (int y = 1; y < h - 1; y++) {
      final row = y * w;
      for (int x = 1; x < w - 1; x++) {
        final val = lum[row + x];
        final lap =
            lum[row - w + x] +
            lum[row + w + x] +
            lum[row + x - 1] +
            lum[row + x + 1] -
            4.0 * val;

        sum += lap;
        sumSq += lap * lap;
        count++;
      }
    }

    if (count == 0) return 0.0;
    final mean = sum / count;
    final variance = (sumSq / count) - (mean * mean);
    return math.max(0.0, variance);
  }

  /// Blockiness estimation (Wang-Bovik generalized DCT/block boundary discontinuity)
  static double calculateBlockiness(img.Image image) {
    if (image.width < 16 || image.height < 16) return 0.0;
    final w = image.width;
    final h = image.height;
    final lum = _toLuminance(image);

    double blockDiff = 0.0;
    int blockCount = 0;
    double nonBlockDiff = 0.0;
    int nonBlockCount = 0;

    for (int y = 1; y < h - 1; y++) {
      final row = y * w;
      final isBlockY = (y % 8 == 0);
      for (int x = 1; x < w - 1; x++) {
        final isBlockX = (x % 8 == 0);
        final diff = (lum[row + x] - lum[row + x - 1]).abs();

        if (isBlockX || isBlockY) {
          blockDiff += diff;
          blockCount++;
        } else {
          nonBlockDiff += diff;
          nonBlockCount++;
        }
      }
    }

    if (nonBlockCount == 0 || nonBlockDiff == 0.0) return 0.0;
    final avgBlock = blockDiff / (blockCount > 0 ? blockCount : 1);
    final avgNonBlock = nonBlockDiff / nonBlockCount;
    return math.max(0.0, avgBlock / avgNonBlock);
  }

  /// Noise level estimation via high frequency median absolute deviation
  static double calculateNoise(img.Image image) {
    if (image.width < 5 || image.height < 5) return 0.0;
    final w = image.width;
    final h = image.height;
    final lum = _toLuminance(image);

    final diffs = <double>[];
    for (int y = 2; y < h - 2; y += 2) {
      final row = y * w;
      for (int x = 2; x < w - 2; x += 2) {
        // High pass difference
        final val = (lum[row + x] - lum[row + x - 1]).abs();
        diffs.add(val);
      }
    }

    if (diffs.isEmpty) return 0.0;
    diffs.sort();
    final median = diffs[diffs.length ~/ 2];
    return median;
  }

  /// SSIM (Structural Similarity Index) between two images (scaled to same dimensions)
  static double calculateSsim(img.Image imgA, img.Image imgB) {
    final w = math.min(imgA.width, imgB.width);
    final h = math.min(imgA.height, imgB.height);

    final aResized = (imgA.width == w && imgA.height == h)
        ? imgA
        : img.copyResize(imgA, width: w, height: h);
    final bResized = (imgB.width == w && imgB.height == h)
        ? imgB
        : img.copyResize(imgB, width: w, height: h);

    final lumA = _toLuminance(aResized);
    final lumB = _toLuminance(bResized);

    const c1 = 6.5025; // (0.01 * 255)^2
    const c2 = 58.5225; // (0.03 * 255)^2

    double sumSsim = 0.0;
    int count = 0;
    const blockSize = 8;

    for (int by = 0; by <= h - blockSize; by += blockSize) {
      for (int bx = 0; bx <= w - blockSize; bx += blockSize) {
        double meanA = 0;
        double meanB = 0;
        for (int y = 0; y < blockSize; y++) {
          final row = (by + y) * w;
          for (int x = 0; x < blockSize; x++) {
            meanA += lumA[row + bx + x];
            meanB += lumB[row + bx + x];
          }
        }
        meanA /= (blockSize * blockSize);
        meanB /= (blockSize * blockSize);

        double varA = 0;
        double varB = 0;
        double covar = 0;

        for (int y = 0; y < blockSize; y++) {
          final row = (by + y) * w;
          for (int x = 0; x < blockSize; x++) {
            final da = lumA[row + bx + x] - meanA;
            final db = lumB[row + bx + x] - meanB;
            varA += da * da;
            varB += db * db;
            covar += da * db;
          }
        }
        final n = (blockSize * blockSize) - 1;
        varA /= n;
        varB /= n;
        covar /= n;

        final num = (2 * meanA * meanB + c1) * (2 * covar + c2);
        final den = (meanA * meanA + meanB * meanB + c1) * (varA + varB + c2);

        sumSsim += (den != 0 ? num / den : 1.0);
        count++;
      }
    }

    if (count == 0) return 1.0;
    return (sumSsim / count).clamp(0.0, 1.0);
  }

  /// PSNR calculation between two images
  static double calculatePsnr(img.Image imgA, img.Image imgB) {
    final w = math.min(imgA.width, imgB.width);
    final h = math.min(imgA.height, imgB.height);

    final aResized = (imgA.width == w && imgA.height == h)
        ? imgA
        : img.copyResize(imgA, width: w, height: h);
    final bResized = (imgB.width == w && imgB.height == h)
        ? imgB
        : img.copyResize(imgB, width: w, height: h);

    double sumSqDiff = 0.0;
    int count = 0;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final pA = aResized.getPixel(x, y);
        final pB = bResized.getPixel(x, y);

        final dr = (pA.r - pB.r).toDouble();
        final dg = (pA.g - pB.g).toDouble();
        final db = (pA.b - pB.b).toDouble();

        sumSqDiff += (dr * dr + dg * dg + db * db) / 3.0;
        count++;
      }
    }

    if (count == 0) return 100.0;
    final mse = sumSqDiff / count;
    if (mse <= 0.0001) return 100.0;

    final psnr = 10.0 * (math.log(255.0 * 255.0 / mse) / math.ln10);
    return psnr.clamp(0.0, 100.0);
  }

  /// Perceptual dHash difference to check if videos are truly the same content
  static int calculateDHashDistance(img.Image imgA, img.Image imgB) {
    final aSmall = img.copyResize(imgA, width: 9, height: 8);
    final bSmall = img.copyResize(imgB, width: 9, height: 8);

    int dist = 0;
    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
        final bitA =
            aSmall.getPixel(x + 1, y).luminance >
            aSmall.getPixel(x, y).luminance;
        final bitB =
            bSmall.getPixel(x + 1, y).luminance >
            bSmall.getPixel(x, y).luminance;
        if (bitA != bitB) dist++;
      }
    }
    return dist;
  }

  /// Effective resolution and upscaling detection
  /// Detects if an image's high frequency energy drops off prematurely relative to its declared dimensions
  static String detectEffectiveResolution({
    required int declaredWidth,
    required int declaredHeight,
    required double sharpness,
    required double blockiness,
  }) {
    // If declared resolution is 1080p or higher but sharpness is very low (< 45)
    // while blockiness or blur is high, it is characteristic of bicubic/bilinear upscaled video
    final totalPixels = declaredWidth * declaredHeight;
    final isDeclared1080pPlus = totalPixels >= 1920 * 1080 * 0.9;
    final isDeclared4k = totalPixels >= 3840 * 2160 * 0.9;

    if (isDeclared4k && sharpness < 60.0) {
      return '1920x1080 (Upscaled to 4K)';
    }

    if (isDeclared1080pPlus && sharpness < 35.0) {
      return '1280x720 (Upscaled to 1080p)';
    }

    return '${declaredWidth}x$declaredHeight (Native)';
  }
}
