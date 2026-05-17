import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/detected_arrow.dart';
import '../../data/datasources/target_detection_service.dart';
import '../../data/datasources/arrow_detection_service.dart';
import '../../data/datasources/score_calculation_service.dart';
import '../../../session_logger/domain/models/arrow.dart';
import '../../../session_logger/domain/models/target_face.dart';
import '../../../session_logger/presentation/providers/session_providers.dart';

/// Screen showing analyzer results with detected arrows overlaid on target image.
/// Users can review, manually correct, and confirm scores before saving.
class AnalyzerResultScreen extends ConsumerStatefulWidget {
  final String imagePath;
  final String sessionId;
  final String endId;

  const AnalyzerResultScreen({
    super.key,
    required this.imagePath,
    required this.sessionId,
    required this.endId,
  });

  @override
  ConsumerState<AnalyzerResultScreen> createState() =>
      _AnalyzerResultScreenState();
}

class _AnalyzerResultScreenState extends ConsumerState<AnalyzerResultScreen> {
  bool _isAnalyzing = true;
  bool _isSaving = false;
  String? _errorMessage;
  List<DetectedArrow> _detectedArrows = [];
  TargetFace? _targetFace;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final targetDetectionService = ref.read(targetDetectionServiceProvider);
      final arrowDetectionService = ref.read(arrowDetectionServiceProvider);
      final scoreCalculationService = ref.read(scoreCalculationServiceProvider);

      // TODO: Load actual image and pass to detection services
      // For now, using mock data

      // Step 1: Detect target (get center and radius)
      final targetCenter = const Offset(0, 0); // Normalized coordinates
      final targetRadiusCm = 61.0; // FITA 122cm target radius

      // Step 2: Create target face configuration
      _targetFace = TargetFace.fita122cm();

      // Step 3: Detect arrows
      // TODO: Implement actual arrow detection
      // Mock detected arrows for demonstration
      _detectedArrows = [
        DetectedArrow(
          id: '1',
          position: const Offset(2.5, 3.0),
          confidence: 0.92,
          score: 'X',
        ),
        DetectedArrow(
          id: '2',
          position: const Offset(-5.0, 4.5),
          confidence: 0.88,
          score: '9',
        ),
        DetectedArrow(
          id: '3',
          position: const Offset(8.0, -6.0),
          confidence: 0.85,
          score: '8',
        ),
      ];

      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to analyze image: $e';
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _saveArrows() async {
    if (_detectedArrows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No arrows to save')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final sessionRepository = ref.read(sessionRepositoryProvider);

      // Convert DetectedArrows to domain Arrow models
      final arrows = _detectedArrows.map((detected) {
        return Arrow(
          id: detected.id,
          score: detected.score,
          x: detected.position.dx,
          y: detected.position.dy,
          timestamp: DateTime.now(),
        );
      }).toList();

      // TODO: Add arrows to the current end via repository
      // This requires updating the session with new end data
      // For now, showing success and navigating back

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved ${arrows.length} arrows successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to session detail or end logger
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  void _editArrow(DetectedArrow arrow) {
    showDialog(
      context: context,
      builder: (context) => _EditArrowDialog(
        arrow: arrow,
        onSave: (updatedArrow) {
          setState(() {
            final index = _detectedArrows.indexWhere((a) => a.id == arrow.id);
            if (index != -1) {
              _detectedArrows[index] = updatedArrow;
            }
          });
        },
      ),
    );
  }

  void _deleteArrow(DetectedArrow arrow) {
    setState(() {
      _detectedArrows.removeWhere((a) => a.id == arrow.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Arrow removed')),
    );
  }

  void _addManualArrow() {
    final newArrow = DetectedArrow(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      position: const Offset(0, 0),
      confidence: 1.0,
      score: 'X',
    );

    setState(() {
      _detectedArrows.add(newArrow);
    });

    _editArrow(newArrow);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Results'),
        actions: [
          if (!_isAnalyzing && _errorMessage == null)
            TextButton.icon(
              onPressed: _isSaving ? null : _saveArrows,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Save'),
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: !_isAnalyzing && _errorMessage == null
          ? FloatingActionButton(
              onPressed: _addManualArrow,
              tooltip: 'Add arrow manually',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isAnalyzing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing image...'),
            SizedBox(height: 8),
            Text(
              'Detecting target and arrows',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _analyzeImage,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Analysis'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _addManualArrow,
                icon: const Icon(Icons.edit),
                label: const Text('Enter Manually'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Image with overlay
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Captured image
                Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.contain,
                ),

                // Arrow markers overlay
                CustomPaint(
                  painter: ArrowOverlayPainter(
                    arrows: _detectedArrows,
                    targetFace: _targetFace,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Arrow list
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey[100],
            child: _buildArrowList(),
          ),
        ),
      ],
    );
  }

  Widget _buildArrowList() {
    if (_detectedArrows.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.radio_button_unchecked, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No arrows detected',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to add manually',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_detectedArrows.length} Arrows Detected',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Total: ${_calculateTotalScore()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _detectedArrows.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final arrow = _detectedArrows[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getScoreColor(arrow.score),
                  child: Text(
                    arrow.score,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  'Arrow ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Score: ${arrow.score} • '
                  'Position: (${arrow.position.dx.toStringAsFixed(1)}, '
                  '${arrow.position.dy.toStringAsFixed(1)}) cm • '
                  'Confidence: ${(arrow.confidence * 100).toStringAsFixed(0)}%',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _editArrow(arrow),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _deleteArrow(arrow),
                      tooltip: 'Delete',
                      color: Colors.red,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  int _calculateTotalScore() {
    return _detectedArrows.fold<int>(0, (sum, arrow) {
      final scoreValue = arrow.score == 'X'
          ? 10
          : arrow.score == 'M'
              ? 0
              : int.tryParse(arrow.score) ?? 0;
      return sum + scoreValue;
    });
  }

  Color _getScoreColor(String score) {
    if (score == 'X' || score == '10') return Colors.amber[700]!;
    if (score == '9' || score == '8') return Colors.red[700]!;
    if (score == '7' || score == '6') return Colors.blue[700]!;
    if (score == '5' || score == '4') return Colors.black;
    return Colors.grey[600]!;
  }
}

/// Dialog for editing arrow properties manually.
class _EditArrowDialog extends StatefulWidget {
  final DetectedArrow arrow;
  final Function(DetectedArrow) onSave;

  const _EditArrowDialog({
    required this.arrow,
    required this.onSave,
  });

  @override
  State<_EditArrowDialog> createState() => _EditArrowDialogState();
}

class _EditArrowDialogState extends State<_EditArrowDialog> {
  late String _selectedScore;
  late TextEditingController _xController;
  late TextEditingController _yController;

  @override
  void initState() {
    super.initState();
    _selectedScore = widget.arrow.score;
    _xController = TextEditingController(
      text: widget.arrow.position.dx.toStringAsFixed(1),
    );
    _yController = TextEditingController(
      text: widget.arrow.position.dy.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Arrow'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Score:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['X', '10', '9', '8', '7', '6', '5', '4', '3', '2', '1', 'M']
                  .map((score) => ChoiceChip(
                        label: Text(score),
                        selected: _selectedScore == score,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedScore = score);
                          }
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Position (cm from center):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _xController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'X',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _yController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Y',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final x = double.tryParse(_xController.text) ?? 0.0;
            final y = double.tryParse(_yController.text) ?? 0.0;

            final updatedArrow = widget.arrow.copyWith(
              score: _selectedScore,
              position: Offset(x, y),
            );

            widget.onSave(updatedArrow);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Custom painter for overlaying detected arrows on target image.
class ArrowOverlayPainter extends CustomPainter {
  final List<DetectedArrow> arrows;
  final TargetFace? targetFace;

  ArrowOverlayPainter({
    required this.arrows,
    this.targetFace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw target center point
    final centerPaint = Paint()
      ..color = Colors.red.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, centerPaint);

    // Draw each arrow marker
    for (var i = 0; i < arrows.length; i++) {
      final arrow = arrows[i];

      // Convert cm coordinates to pixel position
      // Assume target radius is approximately 30% of image width
      final scale = size.width * 0.3 / 61.0; // 61cm is FITA target radius
      final arrowPos = Offset(
        center.dx + (arrow.position.dx * scale),
        center.dy - (arrow.position.dy * scale), // Invert Y for screen coords
      );

      // Draw arrow marker
      final markerPaint = Paint()
        ..color = _getScoreColor(arrow.score)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(arrowPos, 12, markerPaint);

      // Draw white border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(arrowPos, 12, borderPaint);

      // Draw arrow number
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          arrowPos.dx - textPainter.width / 2,
          arrowPos.dy - textPainter.height / 2,
        ),
      );
    }
  }

  Color _getScoreColor(String score) {
    if (score == 'X' || score == '10') return Colors.amber[700]!;
    if (score == '9' || score == '8') return Colors.red[700]!;
    if (score == '7' || score == '6') return Colors.blue[700]!;
    if (score == '5' || score == '4') return Colors.black;
    return Colors.grey[600]!;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
