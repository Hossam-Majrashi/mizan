import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

import 'package:mizan/core/l10n/app_localizations.dart';

import '../models/comparison_result.dart';
import '../models/video_item.dart';

class ComparisonTableView extends StatelessWidget {
  final ComparisonMetrics metrics;
  final VideoItem videoA;
  final VideoItem videoB;

  const ComparisonTableView({
    super.key,
    required this.metrics,
    required this.videoA,
    required this.videoB,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
          Text(
            loc.sectionComparisonTable,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    loc.colMetric,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    videoA.fileName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.videoAColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    videoB.fileName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.videoBColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    loc.colWinner,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Rows
          _buildRow(
            theme,
            loc,
            label: loc.metricEffectiveResolution,
            valA: metrics.effectiveResolutionA,
            valB: metrics.effectiveResolutionB,
            winner: metrics.effectiveResWinner,
          ),
          _buildRow(
            theme,
            loc,
            label: loc.metricSharpness,
            valA: metrics.sharpnessA.toStringAsFixed(1),
            valB: metrics.sharpnessB.toStringAsFixed(1),
            winner: metrics.sharpnessWinner,
          ),
          _buildRow(
            theme,
            loc,
            label: loc.metricArtifacts,
            valA: metrics.artifactsA.toStringAsFixed(2),
            valB: metrics.artifactsB.toStringAsFixed(2),
            winner: metrics.artifactsWinner,
          ),
          _buildRow(
            theme,
            loc,
            label: loc.metricNoise,
            valA: metrics.noiseA.toStringAsFixed(2),
            valB: metrics.noiseB.toStringAsFixed(2),
            winner: metrics.noiseWinner,
          ),
          _buildRow(
            theme,
            loc,
            label: loc.metricSsim,
            valA: metrics.avgSsim.toStringAsFixed(4),
            valB: metrics.avgSsim.toStringAsFixed(4),
            winner: 'tie',
          ),
          _buildRow(
            theme,
            loc,
            label: loc.metricPsnr,
            valA: '${metrics.avgPsnr.toStringAsFixed(1)} dB',
            valB: '${metrics.avgPsnr.toStringAsFixed(1)} dB',
            winner: 'tie',
          ),
          _buildRow(
            theme,
            loc,
            label: loc.metricFramerate,
            valA: '${metrics.uniqueFpsA.toStringAsFixed(1)} fps',
            valB: '${metrics.uniqueFpsB.toStringAsFixed(1)} fps',
            winner: metrics.fpsWinner,
          ),
          _buildRow(
            theme,
            loc,
            label: loc.metricFrameDuplicates,
            valA: '${metrics.duplicatesA}',
            valB: '${metrics.duplicatesB}',
            winner: metrics.duplicatesWinner,
          ),
          _buildRow(
            theme,
            loc,
            label: loc.metricBitrate,
            valA: '${(metrics.videoBitrateA / 1000).toStringAsFixed(0)} kbps',
            valB: '${(metrics.videoBitrateB / 1000).toStringAsFixed(0)} kbps',
            winner: metrics.bitrateWinner,
          ),
          _buildRow(
            theme,
            loc,
            label: loc.metricCodec,
            valA: metrics.videoCodecA,
            valB: metrics.videoCodecB,
            winner: metrics.codecWinner,
          ),
          _buildRow(
            theme,
            loc,
            label: loc.metricBitDepth,
            valA: '${metrics.bitDepthA}-bit',
            valB: '${metrics.bitDepthB}-bit',
            winner: metrics.bitDepthWinner,
          ),
          _buildRow(
            theme,
            loc,
            label: loc.metricAudio,
            valA: metrics.audioInfoA,
            valB: metrics.audioInfoB,
            winner: metrics.audioWinner,
          ),
          _buildRow(
            theme,
            loc,
            label: loc.metricFileSize,
            valA: videoA.formattedSize,
            valB: videoB.formattedSize,
            winner: 'info',
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    ThemeData theme,
    AppLocalizations loc, {
    required String label,
    required String valA,
    required String valB,
    required String winner,
  }) {
    Color winnerColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    String winnerText = loc.tagTie;

    if (winner == 'A') {
      winnerColor = AppColors.videoAColor;
      winnerText = 'A';
    } else if (winner == 'B') {
      winnerColor = AppColors.videoBColor;
      winnerText = 'B';
    } else if (winner == 'info') {
      winnerColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
      winnerText = loc.tagInfoOnly;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valA,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valB,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: winnerColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  winnerText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: winnerColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
