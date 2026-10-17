import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/comparator/models/video_item.dart';
import '../../features/comparator/screens/results_screen.dart';
import '../../features/comparator/services/comparison_orchestrator.dart';
import '../../features/comparator/services/video_probe_service.dart';
import '../../features/comparator/widgets/video_slot_card.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/services/settings_service.dart';

import 'package:mizan/core/l10n/app_localizations.dart';

class DesktopHomeScreen extends StatefulWidget {
  final SettingsService settingsService;

  const DesktopHomeScreen({super.key, required this.settingsService});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  VideoItem? _videoA;
  VideoItem? _videoB;
  bool _isAnalyzing = false;
  double _progress = 0.0;
  String _currentStage = '';
  ComparisonOrchestrator? _currentOrchestrator;

  Future<void> _pickVideo(String slotId) async {
    final loc = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        final name = result.files.first.name;
        if (path != null) {
          _loadVideo(slotId, path, name);
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(loc.errPermission)));
      }
    }
  }

  Future<void> _loadVideo(String slotId, String path, String fileName) async {
    final loc = AppLocalizations.of(context)!;
    try {
      final probed = await VideoProbeService.probeVideo(
        id: slotId,
        filePath: path,
        fileName: fileName,
      );
      setState(() {
        if (slotId == 'A') {
          _videoA = probed;
        } else {
          _videoB = probed;
        }
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(loc.errCorrupt)));
      }
    }
  }

  void _swapVideos() {
    setState(() {
      final temp = _videoA;
      _videoA = _videoB;
      _videoB = temp;
    });
  }

  void _clearSlot(String slotId) {
    setState(() {
      if (slotId == 'A') {
        _videoA = null;
      } else {
        _videoB = null;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _videoA = null;
      _videoB = null;
    });
  }

  Future<void> _startComparison() async {
    if (_videoA == null || _videoB == null) return;
    final loc = AppLocalizations.of(context)!;

    if (_videoA!.path.isNotEmpty && _videoA!.path == _videoB!.path) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loc.errSameFile)));
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _progress = 0.0;
      _currentStage = loc.stageProbing;
    });

    final orchestrator = ComparisonOrchestrator();
    _currentOrchestrator = orchestrator;

    try {
      final verdict = await orchestrator.runComparison(
        videoA: _videoA!,
        videoB: _videoB!,
        analysisDepth: widget.settingsService.analysisDepth,
        tolerance: widget.settingsService.tolerance,
        onProgress: (prog, stageKey) {
          if (mounted) {
            setState(() {
              _progress = prog;
              _currentStage = _getStageText(loc, stageKey);
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              verdict: verdict,
              videoA: _videoA!,
              videoB: _videoB!,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        final msg = e.toString().contains('Cancelled')
            ? loc.analysisCancelled
            : loc.errCorrupt;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  String _getStageText(AppLocalizations loc, String key) {
    switch (key) {
      case 'stageProbing':
        return loc.stageProbing;
      case 'stageExtracting':
        return loc.stageExtracting;
      case 'stageComparing':
        return loc.stageComparing;
      case 'stageFinalizing':
        return loc.stageFinalizing;
      default:
        return loc.analyzingTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final canCompare = _videoA != null && _videoB != null && !_isAnalyzing;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icon/app_icon.png', width: 32, height: 32),
            const SizedBox(width: 12),
            Text(loc.appTitle),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                loc.appTagline,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.accentTeal,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (_videoA != null || _videoB != null)
            TextButton.icon(
              onPressed: !_isAnalyzing ? _clearAll : null,
              icon: const Icon(Icons.clear_all, size: 18),
              label: Text(loc.btnClearAll),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: loc.settingsTitle,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SettingsScreen(settingsService: widget.settingsService),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              children: [
                // Two Slots Side-by-Side
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Video A (Left)
                      Expanded(
                        child: VideoSlotCard(
                          slotId: 'A',
                          title: loc.slotATitle,
                          item: _videoA,
                          onPick: () => _pickVideo('A'),
                          onClear: () => _clearSlot('A'),
                          onFileDropped: (path) =>
                              _loadVideo('A', path, path.split('/').last),
                        ),
                      ),
                      // Center Swap Action
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton.filledTonal(
                              onPressed:
                                  (_videoA != null || _videoB != null) &&
                                      !_isAnalyzing
                                  ? _swapVideos
                                  : null,
                              icon: const Icon(Icons.swap_horiz, size: 24),
                              tooltip: loc.btnSwapVideos,
                            ),
                          ],
                        ),
                      ),
                      // Video B (Right)
                      Expanded(
                        child: VideoSlotCard(
                          slotId: 'B',
                          title: loc.slotBTitle,
                          item: _videoB,
                          onPick: () => _pickVideo('B'),
                          onClear: () => _clearSlot('B'),
                          onFileDropped: (path) =>
                              _loadVideo('B', path, path.split('/').last),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bottom Control Center
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tune,
                            size: 18,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${loc.labelAnalysisDepth}: ${widget.settingsService.analysisDepth.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 240,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: canCompare ? _startComparison : null,
                          icon: const Icon(Icons.compare_arrows, size: 22),
                          label: Text(
                            loc.btnCompare,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Desktop Progress Modal Overlay
          if (_isAnalyzing)
            Container(
              color: AppColors.darkPageBackground.withValues(alpha: 0.85),
              child: Center(
                child: Container(
                  width: 480,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentTeal, width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        loc.analyzingTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 8,
                          color: AppColors.accentTeal,
                          backgroundColor: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentStage,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.85,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () {
                          _currentOrchestrator?.cancel();
                        },
                        child: Text(loc.btnCancel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
