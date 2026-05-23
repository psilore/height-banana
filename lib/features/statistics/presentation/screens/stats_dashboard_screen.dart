import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../session_logger/presentation/providers/session_providers.dart';
import '../../../session_logger/domain/models/training_session.dart';

/// Statistics dashboard showing score trends and performance analytics
class StatsDashboardScreen extends ConsumerWidget {
  const StatsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) => _buildDashboard(context, sessions),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, List<TrainingSession> sessions) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_chart, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No training data yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start logging sessions to see statistics',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(sessions),
          const SizedBox(height: 24),
          _buildScoreTrendChart(sessions),
          const SizedBox(height: 24),
          _buildAveragesByDistance(sessions),
          const SizedBox(height: 24),
          _buildScoreDistribution(sessions),
          const SizedBox(height: 24),
          _buildRecentSessions(sessions),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(List<TrainingSession> sessions) {
    final totalArrows = sessions.fold<int>(
      0,
      (sum, session) => sum + session.totalArrows,
    );

    final totalScore = sessions.fold<int>(
      0,
      (sum, session) => sum + session.totalScore,
    );

    final averageScore = totalArrows > 0 ? totalScore / totalArrows : 0.0;

    final bestSession = sessions.reduce((a, b) =>
        a.averageScore > b.averageScore ? a : b,);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Sessions',
            sessions.length.toString(),
            Icons.event,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Arrows',
            totalArrows.toString(),
            Icons.sports_baseball,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Avg Score',
            averageScore.toStringAsFixed(1),
            Icons.show_chart,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Best Avg',
            bestSession.averageScore.toStringAsFixed(1),
            Icons.emoji_events,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreTrendChart(List<TrainingSession> sessions) {
    final sortedSessions = List<TrainingSession>.from(sessions)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = sortedSessions.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.averageScore,
      );
    }).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Score Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < sortedSessions.length) {
                            final date = sortedSessions[index].date;
                            return Text(
                              '${date.month}/${date.day}',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAveragesByDistance(List<TrainingSession> sessions) {
    final distanceGroups = <double, List<double>>{};

    for (var session in sessions) {
      distanceGroups.putIfAbsent(session.distanceMeters, () => [])
          .add(session.averageScore);
    }

    final distances = distanceGroups.keys.toList()..sort();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Average by Distance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...distances.map((distance) {
              final scores = distanceGroups[distance]!;
              final avg = scores.reduce((a, b) => a + b) / scores.length;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${distance.toInt()}m'),
                        Text(
                          avg.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: avg / 10,
                      backgroundColor: Colors.grey[200],
                      minHeight: 8,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDistribution(List<TrainingSession> sessions) {
    final scoreCount = <String, int>{};

    for (var session in sessions) {
      for (var end in session.ends) {
        for (var arrow in end.arrows) {
          scoreCount[arrow.score] = (scoreCount[arrow.score] ?? 0) + 1;
        }
      }
    }

    final scores = ['X', '10', '9', '8', '7', '6', '5', '4', '3', '2', '1', 'M'];
    final data = scores.map((score) {
      final count = scoreCount[score] ?? 0;
      return BarChartGroupData(
        x: scores.indexOf(score),
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: _getScoreColor(score),
            width: 16,
          ),
        ],
      );
    }).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Score Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: data,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < scores.length) {
                            return Text(
                              scores[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions(List<TrainingSession> sessions) {
    final recentSessions = List<TrainingSession>.from(sessions)
      ..sort((a, b) => b.date.compareTo(a.date))
      ..take(5);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...recentSessions.map((session) => ListTile(
              leading: CircleAvatar(
                child: Text('${session.date.day}'),
              ),
              title: Text(session.location),
              subtitle: Text('${session.distanceMeters}m • ${session.bowType}'),
              trailing: Text(
                session.averageScore.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(String score) {
    if (score == 'X' || score == '10') return Colors.amber[700]!;
    if (score == '9' || score == '8') return Colors.red[700]!;
    if (score == '7' || score == '6') return Colors.blue[700]!;
    if (score == '5' || score == '4') return Colors.black;
    return Colors.grey[600]!;
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: const Text('Filter options coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
