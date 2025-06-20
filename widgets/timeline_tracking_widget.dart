import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget for tracking and visualizing measurement changes over time
class TimelineTrackingWidget extends StatefulWidget {
  final String userId;
  final MeasurementType measurementType;
  
  const TimelineTrackingWidget({
    super.key,
    required this.userId,
    required this.measurementType,
  });
  
  @override
  State<TimelineTrackingWidget> createState() => _TimelineTrackingWidgetState();
}

class _TimelineTrackingWidgetState extends State<TimelineTrackingWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TimelineDataManager _dataManager = TimelineDataManager();
  TimeRange _selectedRange = TimeRange.month;
  ComparisonMode _comparisonMode = ComparisonMode.none;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTimelineData();
  }
  
  Future<void> _loadTimelineData() async {
    await _dataManager.loadUserData(widget.userId, widget.measurementType);
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Time range selector
        _buildTimeRangeSelector(),
        
        // Tab bar for different views
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Progress', icon: Icon(Icons.timeline)),
            Tab(text: 'Statistics', icon: Icon(Icons.analytics)),
            Tab(text: 'Milestones', icon: Icon(Icons.flag)),
          ],
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProgressView(),
              _buildStatisticsView(),
              _buildMilestonesView(),
            ],
          ),
        ),
        
        // Comparison controls
        if (_comparisonMode != ComparisonMode.none)
          _buildComparisonControls(),
      ],
    );
  }
  
  Widget _buildTimeRangeSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SegmentedButton<TimeRange>(
        segments: const [
          ButtonSegment(value: TimeRange.week, label: Text('Week')),
          ButtonSegment(value: TimeRange.month, label: Text('Month')),
          ButtonSegment(value: TimeRange.quarter, label: Text('Quarter')),
          ButtonSegment(value: TimeRange.year, label: Text('Year')),
          ButtonSegment(value: TimeRange.all, label: Text('All')),
        ],
        selected: {_selectedRange},
        onSelectionChanged: (Set<TimeRange> ranges) {
          setState(() {
            _selectedRange = ranges.first;
            _dataManager.setTimeRange(_selectedRange);
          });
        },
      ),
    );
  }
  
  Widget _buildProgressView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Main progress chart
          Expanded(
            flex: 3,
            child: _buildProgressChart(),
          ),
          
          // Progress summary
          SizedBox(
            height: 100,
            child: _buildProgressSummary(),
          ),
          
          // Interactive timeline
          SizedBox(
            height: 80,
            child: _buildInteractiveTimeline(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressChart() {
    final data = _dataManager.getChartData(_selectedRange);
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)} cm',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = _dataManager.getDateFromValue(value);
                return Text(
                  _formatDateForRange(date, _selectedRange),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          // Main measurement line
          LineChartBarData(
            spots: data.mainData,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
          
          // Goal line if set
          if (data.goalLine != null)
            LineChartBarData(
              spots: data.goalLine!,
              isCurved: false,
              color: Colors.green,
              barWidth: 2,
              dashArray: [5, 5],
              dotData: const FlDotData(show: false),
            ),
          
          // Comparison data if enabled
          if (_comparisonMode != ComparisonMode.none && data.comparisonData != null)
            LineChartBarData(
              spots: data.comparisonData!,
              isCurved: true,
              color: Colors.orange,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final measurement = _dataManager.getMeasurementAt(barSpot.x);
                return LineTooltipItem(
                  '${measurement.value.toStringAsFixed(2)} cm\n${_formatDate(measurement.date)}',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildProgressSummary() {
    final summary = _dataManager.getProgressSummary(_selectedRange);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryItem(
              'Start',
              '${summary.startValue.toStringAsFixed(1)} cm',
              Icons.play_arrow,
            ),
            _buildSummaryItem(
              'Current',
              '${summary.currentValue.toStringAsFixed(1)} cm',
              Icons.adjust,
            ),
            _buildSummaryItem(
              'Change',
              '${summary.totalChange > 0 ? '+' : ''}${summary.totalChange.toStringAsFixed(1)} cm',
              summary.totalChange > 0 ? Icons.trending_up : Icons.trending_down,
              color: summary.totalChange > 0 ? Colors.green : Colors.red,
            ),
            _buildSummaryItem(
              'Rate',
              '${summary.changeRate.toStringAsFixed(2)} cm/month',
              Icons.speed,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
  
  Widget _buildInteractiveTimeline() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Handle timeline scrubbing
        _dataManager.scrubTimeline(details.localPosition.dx);
      },
      child: CustomPaint(
        painter: TimelinePainter(
          measurements: _dataManager.measurements,
          selectedDate: _dataManager.selectedDate,
          timeRange: _selectedRange,
        ),
        child: Container(),
      ),
    );
  }
  
  Widget _buildStatisticsView() {
    final stats = _dataManager.getStatistics(_selectedRange);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          'Average Growth',
          '${stats.averageGrowth.toStringAsFixed(2)} cm/month',
          Icons.trending_up,
        ),
        _buildStatCard(
          'Best Period',
          '${stats.bestPeriod.growth.toStringAsFixed(2)} cm in ${stats.bestPeriod.duration.inDays} days',
          Icons.emoji_events,
        ),
        _buildStatCard(
          'Consistency',
          '${(stats.consistency * 100).toStringAsFixed(0)}%',
          Icons.calendar_today,
        ),
        _buildStatCard(
          'Projected Goal',
          stats.projectedGoalDate != null
              ? 'Reach goal by ${_formatDate(stats.projectedGoalDate!)}'
              : 'Set a goal to see projection',
          Icons.flag,
        ),
        
        // Distribution chart
        SizedBox(
          height: 200,
          child: _buildDistributionChart(stats),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDistributionChart(TimelineStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Growth Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: stats.distribution.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Theme.of(context).primaryColor,
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()} cm');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMilestonesView() {
    final milestones = _dataManager.getMilestones();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        return _buildMilestoneCard(milestone);
      },
    );
  }
  
  Widget _buildMilestoneCard(Milestone milestone) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: milestone.achieved
              ? Colors.green
              : Colors.grey,
          child: Icon(
            milestone.achieved ? Icons.check : Icons.lock,
            color: Colors.white,
          ),
        ),
        title: Text(milestone.title),
        subtitle: Text(milestone.description),
        trailing: milestone.achieved
            ? Text(
                _formatDate(milestone.achievedDate!),
                style: const TextStyle(color: Colors.green),
              )
            : Text(
                '${milestone.progress.toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
  
  Widget _buildComparisonControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const Text('Compare with: '),
          const SizedBox(width: 8),
          DropdownButton<ComparisonMode>(
            value: _comparisonMode,
            items: const [
              DropdownMenuItem(value: ComparisonMode.none, child: Text('None')),
              DropdownMenuItem(value: ComparisonMode.previousPeriod, child: Text('Previous Period')),
              DropdownMenuItem(value: ComparisonMode.yearAgo, child: Text('Year Ago')),
              DropdownMenuItem(value: ComparisonMode.average, child: Text('Community Average')),
            ],
            onChanged: (value) {
              setState(() {
                _comparisonMode = value!;
                _dataManager.setComparisonMode(_comparisonMode);
              });
            },
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _formatDateForRange(DateTime date, TimeRange range) {
    switch (range) {
      case TimeRange.week:
        return '${date.day}/${date.month}';
      case TimeRange.month:
        return '${date.day}';
      case TimeRange.quarter:
      case TimeRange.year:
        return '${date.month}/${date.year}';
      case TimeRange.all:
        return '${date.year}';
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _dataManager.dispose();
    super.dispose();
  }
}

/// Data models and managers
class TimelineDataManager {
  List<Measurement> measurements = [];
  DateTime? selectedDate;
  
  Future<void> loadUserData(String userId, MeasurementType type) async {
    // Load data from database
  }
  
  void setTimeRange(TimeRange range) {
    // Filter data by time range
  }
  
  void setComparisonMode(ComparisonMode mode) {
    // Load comparison data
  }
  
  ChartData getChartData(TimeRange range) {
    // Process data for chart display
    return ChartData(
      mainData: [],
      goalLine: null,
      comparisonData: null,
    );
  }
  
  Measurement getMeasurementAt(double x) {
    // Get measurement at chart position
    return Measurement(
      date: DateTime.now(),
      value: 0,
      type: MeasurementType.length,
    );
  }
  
  DateTime getDateFromValue(double value) {
    // Convert chart value to date
    return DateTime.now();
  }
  
  ProgressSummary getProgressSummary(TimeRange range) {
    // Calculate progress summary
    return ProgressSummary(
      startValue: 0,
      currentValue: 0,
      totalChange: 0,
      changeRate: 0,
    );
  }
  
  TimelineStatistics getStatistics(TimeRange range) {
    // Calculate statistics
    return TimelineStatistics(
      averageGrowth: 0,
      bestPeriod: GrowthPeriod(growth: 0, duration: Duration.zero),
      consistency: 0,
      projectedGoalDate: null,
      distribution: {},
    );
  }
  
  List<Milestone> getMilestones() {
    // Get user milestones
    return [];
  }
  
  void scrubTimeline(double position) {
    // Handle timeline scrubbing
  }
  
  void dispose() {
    // Cleanup
  }
}

/// Data classes
class Measurement {
  final DateTime date;
  final double value;
  final MeasurementType type;
  
  Measurement({
    required this.date,
    required this.value,
    required this.type,
  });
}

class ChartData {
  final List<FlSpot> mainData;
  final List<FlSpot>? goalLine;
  final List<FlSpot>? comparisonData;
  
  ChartData({
    required this.mainData,
    this.goalLine,
    this.comparisonData,
  });
}

class ProgressSummary {
  final double startValue;
  final double currentValue;
  final double totalChange;
  final double changeRate;
  
  ProgressSummary({
    required this.startValue,
    required this.currentValue,
    required this.totalChange,
    required this.changeRate,
  });
}

class TimelineStatistics {
  final double averageGrowth;
  final GrowthPeriod bestPeriod;
  final double consistency;
  final DateTime? projectedGoalDate;
  final Map<int, int> distribution;
  
  TimelineStatistics({
    required this.averageGrowth,
    required this.bestPeriod,
    required this.consistency,
    this.projectedGoalDate,
    required this.distribution,
  });
}

class GrowthPeriod {
  final double growth;
  final Duration duration;
  
  GrowthPeriod({
    required this.growth,
    required this.duration,
  });
}

class Milestone {
  final String title;
  final String description;
  final bool achieved;
  final DateTime? achievedDate;
  final double progress;
  
  Milestone({
    required this.title,
    required this.description,
    required this.achieved,
    this.achievedDate,
    required this.progress,
  });
}

/// Enums
enum TimeRange { week, month, quarter, year, all }
enum ComparisonMode { none, previousPeriod, yearAgo, average }
enum MeasurementType { length, girth, volume }

/// Custom painter for timeline
class TimelinePainter extends CustomPainter {
  final List<Measurement> measurements;
  final DateTime? selectedDate;
  final TimeRange timeRange;
  
  TimelinePainter({
    required this.measurements,
    required this.selectedDate,
    required this.timeRange,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw timeline visualization
  }
  
  @override
  bool shouldRepaint(TimelinePainter oldDelegate) {
    return measurements != oldDelegate.measurements ||
           selectedDate != oldDelegate.selectedDate;
  }
}