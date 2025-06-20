import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide LinearGradient, RadialGradient;
import 'dart:math' as math;

class AnimatedChartsDemo extends StatefulWidget {
  const AnimatedChartsDemo({super.key});

  @override
  State<AnimatedChartsDemo> createState() => _AnimatedChartsDemoState();
}

class _AnimatedChartsDemoState extends State<AnimatedChartsDemo> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  ChartType _currentChart = ChartType.bar;
  List<DataPoint> _data = [];
  List<DataPoint> _targetData = [];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    
    _generateRandomData();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _generateRandomData() {
    final random = math.Random();
    final oldData = List<DataPoint>.from(_data);
    
    _targetData = List.generate(
      7,
      (index) => DataPoint(
        label: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
        value: random.nextDouble() * 100,
        color: [
          Colors.red,
          Colors.orange,
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.indigo,
          Colors.purple,
        ][index],
      ),
    );
    
    _animation.addListener(() {
      setState(() {
        if (oldData.isEmpty) {
          _data = _targetData;
        } else {
          _data = List.generate(
            7,
            (index) => DataPoint(
              label: _targetData[index].label,
              value: oldData[index].value + 
                (_targetData[index].value - oldData[index].value) * _animation.value,
              color: _targetData[index].color,
            ),
          );
        }
      });
    });
    
    _animationController.forward(from: 0);
  }
  
  void _switchChartType(ChartType type) {
    setState(() {
      _currentChart = type;
    });
    _animationController.forward(from: 0);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Charts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.shade50,
                    Colors.blue.shade50,
                  ],
                ),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _buildChart(),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Chart Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildChartTypeButton(
                      'Bar',
                      Icons.bar_chart,
                      ChartType.bar,
                    ),
                    _buildChartTypeButton(
                      'Line',
                      Icons.show_chart,
                      ChartType.line,
                    ),
                    _buildChartTypeButton(
                      'Pie',
                      Icons.pie_chart,
                      ChartType.pie,
                    ),
                    _buildChartTypeButton(
                      'Radar',
                      Icons.radar,
                      ChartType.radar,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _generateRandomData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Generate New Data'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChart() {
    return LayoutBuilder(
      key: ValueKey(_currentChart),
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: ChartPainter(
            data: _data,
            chartType: _currentChart,
            animation: _animation,
          ),
        );
      },
    );
  }
  
  Widget _buildChartTypeButton(String label, IconData icon, ChartType type) {
    final isSelected = _currentChart == type;
    return GestureDetector(
      onTap: () => _switchChartType(type),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade700,
              size: 30,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ChartType { bar, line, pie, radar }

class DataPoint {
  final String label;
  final double value;
  final Color color;
  
  DataPoint({
    required this.label,
    required this.value,
    required this.color,
  });
}

class ChartPainter extends CustomPainter {
  final List<DataPoint> data;
  final ChartType chartType;
  final Animation<double> animation;
  
  ChartPainter({
    required this.data,
    required this.chartType,
    required this.animation,
  }) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    
    switch (chartType) {
      case ChartType.bar:
        _drawBarChart(canvas, size);
        break;
      case ChartType.line:
        _drawLineChart(canvas, size);
        break;
      case ChartType.pie:
        _drawPieChart(canvas, size);
        break;
      case ChartType.radar:
        _drawRadarChart(canvas, size);
        break;
    }
  }
  
  void _drawBarChart(Canvas canvas, Size size) {
    final barWidth = size.width / (data.length * 2);
    final maxValue = data.map((d) => d.value).reduce(math.max);
    
    for (int i = 0; i < data.length; i++) {
      final x = barWidth + (i * barWidth * 2);
      final barHeight = (data[i].value / maxValue) * size.height * 0.8 * animation.value;
      final y = size.height - barHeight;
      
      final paint = Paint()
        ..color = data[i].color
        ..style = PaintingStyle.fill;
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - barWidth / 2, y, barWidth, barHeight),
        const Radius.circular(5),
      );
      
      canvas.drawRRect(rect, paint);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i].label,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 20),
      );
    }
  }
  
  void _drawLineChart(Canvas canvas, Size size) {
    final maxValue = data.map((d) => d.value).reduce(math.max);
    final pointSpacing = size.width / (data.length - 1);
    
    final linePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final path = Path();
    
    for (int i = 0; i < data.length; i++) {
      final x = i * pointSpacing;
      final y = size.height - (data[i].value / maxValue) * size.height * 0.8 * animation.value;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      final pointPaint = Paint()
        ..color = data[i].color
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), 6, pointPaint);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i].value.toStringAsFixed(0),
          style: const TextStyle(color: Colors.black, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - 20),
      );
    }
    
    canvas.drawPath(path, linePaint);
  }
  
  void _drawPieChart(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;
    final total = data.map((d) => d.value).reduce((a, b) => a + b);
    
    double startAngle = -math.pi / 2;
    
    for (final point in data) {
      final sweepAngle = (point.value / total) * 2 * math.pi * animation.value;
      
      final paint = Paint()
        ..color = point.color
        ..style = PaintingStyle.fill;
      
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..close();
      
      canvas.drawPath(path, paint);
      
      final labelAngle = startAngle + sweepAngle / 2;
      final labelRadius = radius * 0.7;
      final labelX = center.dx + labelRadius * math.cos(labelAngle);
      final labelY = center.dy + labelRadius * math.sin(labelAngle);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(point.value / total * 100).toStringAsFixed(0)}%',
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
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
      );
      
      startAngle += sweepAngle;
    }
  }
  
  void _drawRadarChart(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;
    final angleStep = (2 * math.pi) / data.length;
    
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (int i = 1; i <= 5; i++) {
      final gridRadius = radius * (i / 5);
      final path = Path();
      
      for (int j = 0; j < data.length; j++) {
        final angle = j * angleStep - math.pi / 2;
        final x = center.dx + gridRadius * math.cos(angle);
        final y = center.dy + gridRadius * math.sin(angle);
        
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      path.close();
      canvas.drawPath(path, gridPaint);
    }
    
    for (int i = 0; i < data.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }
    
    final dataPath = Path();
    const maxValue = 100.0;
    
    for (int i = 0; i < data.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final value = (data[i].value / maxValue) * radius * animation.value;
      final x = center.dx + value * math.cos(angle);
      final y = center.dy + value * math.sin(angle);
      
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    
    dataPath.close();
    
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(dataPath, fillPaint);
    
    final strokePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(dataPath, strokePaint);
  }
  
  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;
}