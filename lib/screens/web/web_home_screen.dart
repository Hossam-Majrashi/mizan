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

class WebHomeScreen extends StatefulWidget {
  final SettingsService settingsService;

  const WebHomeScreen({super.key, required this.settingsService});

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
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
        final path = result.files.first.path ?? result.files.first.name;
        final name = result.files.first.name;
        _loadVideo(slotId, path, name);
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
            Image.asset('assets/icon/app_icon.png', width: 30, height: 30),
            const SizedBox(width: 10),
            Text(loc.appTitle),
          ],
        ),
        actions: [
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
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;

          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 40 : 16,
                  vertical: 20,
                ),
                children: [
                  // Web Notice Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.accentTeal.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.accentTeal,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            loc.webDecodingNotice,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Slots (Row if wide, Column if narrow)
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 80,
                          ),
                          child: IconButton.filledTonal(
                            onPressed:
                                (_videoA != null || _videoB != null) &&
                                    !_isAnalyzing
                                ? _swapVideos
                                : null,
                            icon: const Icon(Icons.swap_horiz, size: 24),
                            tooltip: loc.btnSwapVideos,
                          ),
                        ),
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
                    )
                  else ...[
                    VideoSlotCard(
                      slotId: 'A',
                      title: loc.slotATitle,
                      item: _videoA,
                      onPick: () => _pickVideo('A'),
                      onClear: () => _clearSlot('A'),
                      onFileDropped: (path) =>
                          _loadVideo('A', path, path.split('/').last),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed:
                              (_videoA != null || _videoB != null) &&
                                  !_isAnalyzing
                              ? _swapVideos
                              : null,
                          icon: const Icon(Icons.swap_vert, size: 18),
                          label: Text(loc.btnSwapVideos),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    VideoSlotCard(
                      slotId: 'B',
                      title: loc.slotBTitle,
                      item: _videoB,
                      onPick: () => _pickVideo('B'),
                      onClear: () => _clearSlot('B'),
                      onFileDropped: (path) =>
                          _loadVideo('B', path, path.split('/').last),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Compare Action Button
                  Center(
                    child: SizedBox(
                      width: isWide ? 320 : double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: canCompare ? _startComparison : null,
                        icon: const Icon(Icons.compare_arrows, size: 22),
                        label: Text(
                          loc.btnCompare,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentTeal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),

              // Web Progress Modal Overlay
              if (_isAnalyzing)
                Container(
                  color: AppColors.darkPageBackground.withValues(alpha: 0.85),
                  child: Center(
                    child: Container(
                      width: 440,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accentTeal,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            loc.analyzingTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: _progress,
                            color: AppColors.accentTeal,
                            backgroundColor: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _currentStage,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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
          );
        },
      ),
    );
  }
}
