import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

import 'package:mizan/core/l10n/app_localizations.dart';

import '../models/comparison_result.dart';

class VerdictCard extends StatelessWidget {
  final ComparisonVerdict verdict;

  const VerdictCard({super.key, required this.verdict});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    Color statusColor;
    String verdictTitleText;

    switch (verdict.verdictType) {
      case VerdictType.winnerA:
      case VerdictType.winnerB:
        statusColor = AppColors.accentEmerald;
        verdictTitleText = loc.verdictBestQuality(verdict.winnerFileName);
        break;
      case VerdictType.same:
        statusColor = AppColors.accentTeal;
        verdictTitleText = loc.verdictSameQuality;
        break;
      case VerdictType.mixed:
        statusColor = AppColors.accentAmber;
        verdictTitleText = loc.verdictMixedQuality;
        break;
    }

    String confidenceText;
    Color confidenceColor;
    switch (verdict.confidence) {
      case ConfidenceLevel.high:
        confidenceText = loc.confidenceHigh;
        confidenceColor = AppColors.accentEmerald;
        break;
      case ConfidenceLevel.medium:
        confidenceText = loc.confidenceMedium;
        confidenceColor = AppColors.accentAmber;
        break;
      case ConfidenceLevel.low:
        confidenceText = loc.confidenceLow;
        confidenceColor = AppColors.accentRed;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                verdict.verdictType == VerdictType.same
                    ? Icons.balance
                    : Icons.verified_outlined,
                color: statusColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  verdictTitleText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: confidenceColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: confidenceColor, width: 1),
                ),
                child: Text(
                  confidenceText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: confidenceColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            verdict.explanation,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          if (!verdict.metrics.isSameContent) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accentRed.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.accentRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.warningDifferentVideos,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accentRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (verdict.mixedDetails.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...verdict.mixedDetails.map(
              (detail) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_right,
                      size: 20,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        detail,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.85,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
