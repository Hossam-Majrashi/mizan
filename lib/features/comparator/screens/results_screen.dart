import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mizan/core/l10n/app_localizations.dart';

import '../models/comparison_result.dart';
import '../models/video_item.dart';
import '../widgets/comparison_table_view.dart';
import '../widgets/frame_inspection_viewer.dart';
import '../widgets/verdict_card.dart';

class ResultsScreen extends StatelessWidget {
  final ComparisonVerdict verdict;
  final VideoItem videoA;
  final VideoItem videoB;

  const ResultsScreen({
    super.key,
    required this.verdict,
    required this.videoA,
    required this.videoB,
  });

  void _copyReport(BuildContext context, AppLocalizations loc) {
    final text = verdict.toFormattedText(
      fileAName: videoA.fileName,
      fileBName: videoB.fileName,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(loc.msgReportCopied)));
  }

  void _copyJson(BuildContext context, AppLocalizations loc) {
    final jsonStr = verdict.toJsonString(
      fileAName: videoA.fileName,
      fileBName: videoB.fileName,
    );
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(loc.msgJsonSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.verdictTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all_outlined),
            tooltip: loc.btnCopyReport,
            onPressed: () => _copyReport(context, loc),
          ),
          IconButton(
            icon: const Icon(Icons.data_object),
            tooltip: loc.btnSaveJson,
            onPressed: () => _copyJson(context, loc),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Verdict Top Card
          VerdictCard(verdict: verdict),
          const SizedBox(height: 20),

          // Frame Inspection Viewer
          FrameInspectionViewer(
            samplePairs: verdict.samplePairs,
            videoA: videoA,
            videoB: videoB,
          ),
          const SizedBox(height: 20),

          // Detailed Comparison Table
          ComparisonTableView(
            metrics: verdict.metrics,
            videoA: videoA,
            videoB: videoB,
          ),
          const SizedBox(height: 24),

          // Bottom Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyReport(context, loc),
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(loc.btnCopyReport),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyJson(context, loc),
                  icon: const Icon(Icons.code, size: 18),
                  label: Text(loc.btnSaveJson),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
