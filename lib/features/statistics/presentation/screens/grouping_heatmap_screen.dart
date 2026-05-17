import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../session_logger/presentation/providers/session_providers.dart';
import '../../../session_logger/domain/models/training_session.dart';
import '../../../session_logger/domain/models/arrow.dart';

/// Grouping heatmap visualization showing arrow distribution on target face
class GroupingHeatmapScreen extends ConsumerStatefulWidget {
  const GroupingHeatmapScreen({super.key});

  @override
  ConsumerState<GroupingHeatmapScreen> createState() => _GroupingHeatmapScreenState();
}

class _GroupingHeatmapScreenState extends ConsumerState<GroupingHeatmapScreen> {
  String? _selectedSessionId;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grouping Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
            tooltip: 'Info',
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return _buildEmptyState();
          }

          // Get all arrows from selected session or all sessions
          final arrows = _selectedSessionId != null
              ? sessions
                  .where((s) => s.id == _selectedSessionId)
                  .expand((s) => s.ends)
                  .expand((e) => e.arrows)
                  .toList()
              : sessions
                  .expand((s) => s.ends)
                  .expand((e) => e.arrows)
                  .toList();

          return Column(
            children: [
              _buildSessionSelector(sessions),
              Expanded(
                child: arrows.isEmpty
                    ? _buildEmptyState()
                    : _buildHeatmap(arrows),
              ),
              _buildStatistics(arrows),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No arrow data yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Log sessions to see grouping analysis',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSelector(List<TrainingSession> sessions) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Text('Session: '),
            Expanded(
              child: DropdownButton<String?>(
                value: _selectedSessionId,
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Sessions'),
                  ),
                  ...sessions.map((session) => DropdownMenuItem(
                        value: session.id,
                        child: Text(
                          '${session.location} - ${session.date.month}/${session.date.day}',
                        ),
                      )),
                ],
                onChanged: (value) {
                  setState(() => _selectedSessionId = value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap(List<Arrow> arrows) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          elevation: 4,
          child: CustomPaint(
            painter: HeatmapPainter(arrows: arrows),
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics(List<Arrow> arrows) {
    if (arrows.isEmpty) return const SizedBox.shrink();

    // Calculate grouping metrics
    final avgX = arrows.map((a) => a.x).reduce((a, b) => a + b) / arrows.length;
    final avgY = arrows.map((a) => a.y).reduce((a, b) => a + b) / arrows.length;

    final deviations = arrows.map((a) {
      final dx = a.x - avgX;
      final dy = a.y - avgY;
      return math.sqrt(dx * dx + dy * dy);
    }).toList();

    final avgDeviation = deviations.reduce((a, b) => a + b) / deviations.length;
    final maxDeviation = deviations.reduce(math.max);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grouping Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(
                  'Total Arrows',
                  arrows.length.toString(),
                  Icons.sports_baseball,
                ),
                _buildMetric(
                  'Avg Deviation',
                  '${avgDeviation.toStringAsFixed(1)} cm',
                  Icons.center_focus_weak,
                ),
                _buildMetric(
                  'Max Spread',
                  '${maxDeviation.toStringAsFixed(1)} cm',
                  Icons.open_in_full,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGroupingQuality(avgDeviation),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupingQuality(double avgDeviation) {
    String quality;
    Color color;

    if (avgDeviation < 5) {
      quality = 'Excellent';
      color = Colors.green;
    } else if (avgDeviation < 10) {
      quality = 'Good';
      color = Colors.blue;
    } else if (avgDeviation < 15) {
      quality = 'Fair';
      color = Colors.orange;
    } else {
      quality = 'Needs Work';
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(Icons.assessment, color: color),
          const SizedBox(width: 12),
          Text(
            'Grouping Quality: $quality',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grouping Analysis'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What is Grouping?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Grouping measures how consistently your arrows land in the same area. '
                'Tight grouping indicates consistent technique, even if not centered.',
              ),
              SizedBox(height: 16),
              Text(
                'Metrics:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Average Deviation: Distance from group center'),
              Text('• Max Spread: Furthest arrow from center'),
              SizedBox(height: 16),
              Text(
                'Quality Ratings:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Excellent: < 5cm'),
              Text('• Good: 5-10cm'),
              Text('• Fair: 10-15cm'),
              Text('• Needs Work: > 15cm'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for arrow heatmap visualization
class HeatmapPainter extends CustomPainter {
  final List<Arrow> arrows;

  HeatmapPainter({required this.arrows});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;

    // Draw target rings (FITA/WA style)
    _drawTargetRings(canvas, center, radius);

    // Draw center crosshair
    _drawCrosshair(canvas, center);

    // Calculate scale (convert cm to pixels)
    final scale = radius / 61.0; // 61cm = FITA target radius

    // Draw arrows with heat effect
    _drawArrows(canvas, center, scale);

    // Draw group center
    if (arrows.isNotEmpty) {
      _drawGroupCenter(canvas, center, scale);
    }

    // Draw legend
    _drawLegend(canvas, size);
  }

  void _drawTargetRings(Canvas canvas, Offset center, double radius) {
    final ringColors = [
      Colors.amber[100]!, // X/10 (gold)
      Colors.amber[200]!,
      Colors.red[200]!,   // 9/8 (red)
      Colors.red[300]!,
      Colors.blue[200]!,  // 7/6 (blue)
      Colors.blue[300]!,
      Colors.black,       // 5/4 (black)
      Colors.grey[800]!,
      Colors.grey[300]!,  // 3/2 (white)
      Colors.grey[200]!,
    ];

    // Draw rings from outside to inside
    for (int i = 10; i >= 1; i--) {
      final ringRadius = radius * (i / 10);
      final paint = Paint()
        ..color = ringColors[10 - i]
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, ringRadius, paint);

      // Draw ring border
      final borderPaint = Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, ringRadius, borderPaint);
    }
  }

  void _drawCrosshair(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(center.dx - 15, center.dy),
      Offset(center.dx + 15, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 15),
      Offset(center.dx, center.dy + 15),
      paint,
    );
  }

  void _drawArrows(Canvas canvas, Offset center, double scale) {
    for (int i = 0; i < arrows.length; i++) {
      final arrow = arrows[i];
      final pos = Offset(
        center.dx + (arrow.x * scale),
        center.dy - (arrow.y * scale), // Invert Y for screen coords
      );

      // Draw heat circle (larger, transparent)
      final heatPaint = Paint()
        ..color = Colors.red.withOpacity(0.1)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 20, heatPaint);

      // Draw arrow marker
      final arrowPaint = Paint()
        ..color = Colors.red.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 6, arrowPaint);

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(pos, 6, borderPaint);

      // Draw arrow number
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          pos.dx - textPainter.width / 2,
          pos.dy - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawGroupCenter(Canvas canvas, Offset center, double scale) {
    final avgX = arrows.map((a) => a.x).reduce((a, b) => a + b) / arrows.length;
    final avgY = arrows.map((a) => a.y).reduce((a, b) => a + b) / arrows.length;

    final groupCenter = Offset(
      center.dx + (avgX * scale),
      center.dy - (avgY * scale),
    );

    // Draw group center marker
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawCircle(groupCenter, 8, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(groupCenter, 8, borderPaint);

    // Draw crosshair
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(groupCenter.dx - 6, groupCenter.dy),
      Offset(groupCenter.dx + 6, groupCenter.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(groupCenter.dx, groupCenter.dy - 6),
      Offset(groupCenter.dx, groupCenter.dy + 6),
      crossPaint,
    );
  }

  void _drawLegend(Canvas canvas, Size size) {
    final legendY = size.height - 40;

    // Target center
    final centerPaint = Paint()
      ..color = Colors.red.withOpacity(0.5);
    canvas.drawCircle(Offset(20, legendY), 4, centerPaint);

    final centerText = TextPainter(
      text: const TextSpan(
        text: 'Target Center',
        style: TextStyle(fontSize: 10, color: Colors.black87),
      ),
      textDirection: TextDirection.ltr,
    );
    centerText.layout();
    centerText.paint(canvas, Offset(30, legendY - 6));

    // Group center
    final groupPaint = Paint()
      ..color = Colors.green;
    canvas.drawCircle(Offset(140, legendY), 4, groupPaint);

    final groupText = TextPainter(
      text: const TextSpan(
        text: 'Group Center',
        style: TextStyle(fontSize: 10, color: Colors.black87),
      ),
      textDirection: TextDirection.ltr,
    );
    groupText.layout();
    groupText.paint(canvas, Offset(150, legendY - 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
