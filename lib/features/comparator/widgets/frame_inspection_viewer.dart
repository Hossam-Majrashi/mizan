import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

import 'package:mizan/core/l10n/app_localizations.dart';

import '../models/comparison_result.dart';
import '../models/video_item.dart';

class FrameInspectionViewer extends StatefulWidget {
  final List<FrameSamplePair> samplePairs;
  final VideoItem videoA;
  final VideoItem videoB;

  const FrameInspectionViewer({
    super.key,
    required this.samplePairs,
    required this.videoA,
    required this.videoB,
  });

  @override
  State<FrameInspectionViewer> createState() => _FrameInspectionViewerState();
}

class _FrameInspectionViewerState extends State<FrameInspectionViewer> {
  int _currentIndex = 0;
  bool _isSplitSlider = false;
  double _splitRatio = 0.5;

  @override
  Widget build(BuildContext context) {
    if (widget.samplePairs.isEmpty) return const SizedBox.shrink();

    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentPair = widget.samplePairs[_currentIndex];

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                loc.sectionFrameInspection,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Toggle between Side by Side and Split Slider
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment<bool>(
                    value: false,
                    label: Text(loc.viewSideBySide),
                    icon: const Icon(Icons.view_column_outlined, size: 16),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text(loc.viewSlider),
                    icon: const Icon(Icons.compare_arrows, size: 16),
                  ),
                ],
                selected: {_isSplitSlider},
                onSelectionChanged: (set) {
                  setState(() {
                    _isSplitSlider = set.first;
                  });
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Timestamp & Navigation header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.sampleTimestamp(currentPair.formattedTimestamp),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _currentIndex > 0
                        ? () => setState(() => _currentIndex--)
                        : null,
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                    tooltip: loc.btnPrevious,
                  ),
                  Text(
                    '${_currentIndex + 1} / ${widget.samplePairs.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _currentIndex < widget.samplePairs.length - 1
                        ? () => setState(() => _currentIndex++)
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    tooltip: loc.btnNextSample,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            loc.zoomHint,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          // Interactive View
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 280,
              color: AppColors.darkPageBackground,
              child: _isSplitSlider
                  ? _buildSplitSliderView(currentPair)
                  : _buildSideBySideView(currentPair),
            ),
          ),
          if (_isSplitSlider) ...[
            const SizedBox(height: 10),
            Slider(
              value: _splitRatio,
              min: 0.05,
              max: 0.95,
              activeColor: AppColors.accentTeal,
              onChanged: (val) {
                setState(() {
                  _splitRatio = val;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSideBySideView(FrameSamplePair pair) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 6.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(pair.frameABytes, fit: BoxFit.contain),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkPageBackground.withValues(
                        alpha: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.videoAColor),
                    ),
                    child: Text(
                      'Video A: ${widget.videoA.fileName}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.videoAColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(width: 2, color: AppColors.accentTeal),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(pair.frameBBytes, fit: BoxFit.contain),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkPageBackground.withValues(
                        alpha: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.videoBColor),
                    ),
                    child: Text(
                      'Video B: ${widget.videoB.fileName}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.videoBColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitSliderView(FrameSamplePair pair) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final splitX = w * _splitRatio;

        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 6.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Bottom Layer: Video B (Emerald)
              Image.memory(
                pair.frameBBytes,
                fit: BoxFit.contain,
                width: w,
                height: h,
              ),
              // Top Layer: Video A (Cyan) clipped to splitX
              ClipRect(
                clipper: _SplitClipper(splitX),
                child: Image.memory(
                  pair.frameABytes,
                  fit: BoxFit.contain,
                  width: w,
                  height: h,
                ),
              ),
              // Split Line
              Positioned(
                left: splitX - 1.5,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: AppColors.accentTeal),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SplitClipper extends CustomClipper<Rect> {
  final double splitX;

  _SplitClipper(this.splitX);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, splitX, size.height);
  }

  @override
  bool shouldReclip(_SplitClipper oldClipper) => oldClipper.splitX != splitX;
}
