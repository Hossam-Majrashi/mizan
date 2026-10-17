import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size);

  // Background gradient: sleek dark slate (#1A1C20 to #0E1013)
  for (int y = 0; y < size; y++) {
    final t = y / size;
    final r = (26 * (1 - t) + 14 * t).round();
    final g = (28 * (1 - t) + 16 * t).round();
    final b = (32 * (1 - t) + 19 * t).round();
    for (int x = 0; x < size; x++) {
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  // Draw rounded outer frame border with cyan/teal accent (#00E5FF)
  void drawThickCircle(
    int cx,
    int cy,
    int radius,
    int thickness,
    img.Color color,
  ) {
    for (int r = radius - thickness ~/ 2; r <= radius + thickness ~/ 2; r++) {
      img.drawCircle(image, x: cx, y: cy, radius: r, color: color);
    }
  }

  // Center coordinates
  const cx = size ~/ 2;
  const cy = size ~/ 2;

  // Outer subtle ring (safe zone guide, 400px radius)
  final ringColor = img.ColorRgba8(0, 229, 255, 60);
  drawThickCircle(cx, cy, 400, 6, ringColor);

  // Precision Scale Stand (Vertical pillar)
  final pillarColor = img.ColorRgba8(230, 235, 245, 240);
  final cyanAccent = img.ColorRgba8(0, 229, 255, 255);
  final emeraldAccent = img.ColorRgba8(0, 230, 118, 255);
  final goldAccent = img.ColorRgba8(255, 215, 64, 255);

  // Base of the balance scale
  img.fillRect(
    image,
    x1: cx - 180,
    y1: cy + 240,
    x2: cx + 180,
    y2: cy + 280,
    color: pillarColor,
  );
  img.fillRect(
    image,
    x1: cx - 120,
    y1: cy + 210,
    x2: cx + 120,
    y2: cy + 240,
    color: pillarColor,
  );

  // Central Vertical Column
  img.fillRect(
    image,
    x1: cx - 18,
    y1: cy - 180,
    x2: cx + 18,
    y2: cy + 210,
    color: pillarColor,
  );

  // Center Pivot Fulcrum
  img.fillCircle(image, x: cx, y: cy - 160, radius: 42, color: goldAccent);
  img.fillCircle(image, x: cx, y: cy - 160, radius: 24, color: pillarColor);

  // Horizontal Balance Beam (angled slightly or perfectly balanced)
  // Perfectly balanced to signify precision
  img.fillRect(
    image,
    x1: cx - 320,
    y1: cy - 170,
    x2: cx + 320,
    y2: cy - 150,
    color: pillarColor,
  );

  // Left scale cords & pan (Video A slot - Cyan)
  img.drawLine(
    image,
    x1: cx - 280,
    y1: cy - 150,
    x2: cx - 350,
    y2: cy + 20,
    color: cyanAccent,
  );
  img.drawLine(
    image,
    x1: cx - 280,
    y1: cy - 150,
    x2: cx - 210,
    y2: cy + 20,
    color: cyanAccent,
  );
  img.drawLine(
    image,
    x1: cx - 360,
    y1: cy + 20,
    x2: cx - 200,
    y2: cy + 20,
    color: cyanAccent,
  );
  // Video A Pan (Displaying 4x4 Pixel Grid to signify pixel-level analysis)
  for (int r = 0; r < 3; r++) {
    for (int c = 0; c < 3; c++) {
      final px = cx - 335 + c * 30;
      final py = cy - 60 + r * 24;
      final alpha = ((r + c) % 2 == 0) ? 240 : 160;
      img.fillRect(
        image,
        x1: px,
        y1: py,
        x2: px + 24,
        y2: py + 20,
        color: img.ColorRgba8(0, 229, 255, alpha),
      );
    }
  }

  // Right scale cords & pan (Video B slot - Emerald)
  img.drawLine(
    image,
    x1: cx + 280,
    y1: cy - 150,
    x2: cx + 210,
    y2: cy + 20,
    color: emeraldAccent,
  );
  img.drawLine(
    image,
    x1: cx + 280,
    y1: cy - 150,
    x2: cx + 350,
    y2: cy + 20,
    color: emeraldAccent,
  );
  img.drawLine(
    image,
    x1: cx + 200,
    y1: cy + 20,
    x2: cx + 360,
    y2: cy + 20,
    color: emeraldAccent,
  );
  // Video B Pan (Displaying higher-density pixel grid)
  for (int r = 0; r < 4; r++) {
    for (int c = 0; c < 4; c++) {
      final px = cx + 225 + c * 22;
      final py = cy - 70 + r * 20;
      final alpha = ((r + c) % 2 == 0) ? 255 : 180;
      img.fillRect(
        image,
        x1: px,
        y1: py,
        x2: px + 18,
        y2: py + 16,
        color: img.ColorRgba8(0, 230, 118, alpha),
      );
    }
  }

  // Output assets directory
  final dir = Directory('assets/icon');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  // Save 1024x1024 Master PNG
  final pngBytes = img.encodePng(image);
  File('assets/icon/app_icon.png').writeAsBytesSync(pngBytes);
  // print('Saved assets/icon/app_icon.png');

  // Also write SVG source
  const svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#1A1C20"/>
      <stop offset="100%" stop-color="#0E1013"/>
    </linearGradient>
  </defs>
  <rect width="1024" height="1024" rx="220" fill="url(#bg)"/>
  <circle cx="512" cy="512" r="400" stroke="#00E5FF" stroke-opacity="0.25" stroke-width="6" fill="none"/>
  <!-- Base -->
  <rect x="332" y="752" width="360" height="40" rx="10" fill="#E6EBF5"/>
  <rect x="392" y="722" width="240" height="30" rx="8" fill="#E6EBF5"/>
  <!-- Central Column -->
  <rect x="494" y="332" width="36" height="390" rx="6" fill="#E6EBF5"/>
  <!-- Pivot -->
  <circle cx="512" cy="352" r="42" fill="#FFD740"/>
  <circle cx="512" cy="352" r="24" fill="#E6EBF5"/>
  <!-- Horizontal Beam -->
  <rect x="192" y="342" width="640" height="20" rx="8" fill="#E6EBF5"/>
  <!-- Left Side: Video A -->
  <line x1="232" y1="362" x2="162" y2="532" stroke="#00E5FF" stroke-width="6"/>
  <line x1="232" y1="362" x2="302" y2="532" stroke="#00E5FF" stroke-width="6"/>
  <line x1="152" y1="532" x2="312" y2="532" stroke="#00E5FF" stroke-width="8" stroke-linecap="round"/>
  <!-- Right Side: Video B -->
  <line x1="792" y1="362" x2="722" y2="532" stroke="#00E676" stroke-width="6"/>
  <line x1="792" y1="362" x2="862" y2="532" stroke="#00E676" stroke-width="6"/>
  <line x1="712" y1="532" x2="872" y2="532" stroke="#00E676" stroke-width="8" stroke-linecap="round"/>
</svg>''';
  File('assets/icon/app_icon.svg').writeAsStringSync(svg);
  // print('Saved assets/icon/app_icon.svg');

  // Generate web/favicon.png and icons
  final sizes = {
    'web/favicon.png': 32,
    'web/icons/Icon-192.png': 192,
    'web/icons/Icon-512.png': 512,
    'web/icons/Icon-maskable-192.png': 192,
    'web/icons/Icon-maskable-512.png': 512,
  };
  for (final entry in sizes.entries) {
    final resized = img.copyResize(
      image,
      width: entry.value,
      height: entry.value,
    );
    File(entry.key).writeAsBytesSync(img.encodePng(resized));
  }

  // Generate Android mipmap icons
  final androidMipmaps = {
    'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
    'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
    'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
    'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
  };
  for (final entry in androidMipmaps.entries) {
    final file = File(entry.key);
    file.parent.createSync(recursive: true);
    final resized = img.copyResize(
      image,
      width: entry.value,
      height: entry.value,
    );
    file.writeAsBytesSync(img.encodePng(resized));
  }
  // print('All icon sizes successfully generated!');
}
