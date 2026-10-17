import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

import 'package:mizan/core/l10n/app_localizations.dart';

import '../models/video_item.dart';

class VideoSlotCard extends StatelessWidget {
  final String slotId; // 'A' or 'B'
  final String title;
  final VideoItem? item;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final Function(String path) onFileDropped;

  const VideoSlotCard({
    super.key,
    required this.slotId,
    required this.title,
    required this.item,
    required this.onPick,
    required this.onClear,
    required this.onFileDropped,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isA = slotId == 'A';
    final accentColor = isA ? AppColors.videoAColor : AppColors.videoBColor;

    return DropTarget(
      onDrop: (detail) async {
        for (final item in detail.items) {
          if (item is DropFileItem) {
            final path = item.localPath ?? '';
            if (path.isNotEmpty) {
              onFileDropped(path);
              break;
            }
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item != null ? accentColor : theme.colorScheme.outline,
            width: item != null ? 1.8 : 1.0,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: item == null
            ? _buildEmptyState(context, loc, theme, accentColor)
            : _buildFilledState(context, loc, theme, accentColor),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations loc,
    ThemeData theme,
    Color accentColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Icon(
          Icons.video_file_outlined,
          size: 54,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.file_upload_outlined, size: 18),
          label: Text(loc.btnChooseVideo),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: AppColors.darkPageBackground,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          loc.dragAndDropHint,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilledState(
    BuildContext context,
    AppLocalizations loc,
    ThemeData theme,
    Color accentColor,
  ) {
    final video = item!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 20),
              tooltip: loc.btnClear,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Thumbnail or preview placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 110,
            color: AppColors.darkPageBackground,
            child: video.thumbnailBytes != null
                ? Image.memory(video.thumbnailBytes!, fit: BoxFit.cover)
                : Center(
                    child: Icon(
                      Icons.movie_outlined,
                      size: 40,
                      color: accentColor.withValues(alpha: 0.6),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          video.fileName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        // Metrics Badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildBadge(theme, loc.labelResolution, video.resolutionText),
            _buildBadge(theme, loc.labelDuration, video.formattedDuration),
            _buildBadge(theme, loc.labelSize, video.formattedSize),
            _buildBadge(theme, loc.labelCodec, video.videoCodec),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colorScheme.outline, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
