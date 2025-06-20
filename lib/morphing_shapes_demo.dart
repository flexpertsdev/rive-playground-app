import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide LinearGradient, RadialGradient;
import 'dart:math' as math;

class MorphingShapesDemo extends StatefulWidget {
  const MorphingShapesDemo({super.key});

  @override
  State<MorphingShapesDemo> createState() => _MorphingShapesDemoState();
}

class _MorphingShapesDemoState extends State<MorphingShapesDemo> with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _rotationController;
  late AnimationController _colorController;
  
  late Animation<double> _morphAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;
  
  ShapeType _currentShape = ShapeType.circle;
  ShapeType _targetShape = ShapeType.square;
  
  bool _autoPlay = false;
  double _morphSpeed = 1.0;
  
  @override
  void initState() {
    super.initState();
    
    _morphController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _colorController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);
    
    _updateColorAnimation();
    
    _morphController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _autoPlay) {
        _selectNextShape();
      }
    });
  }
  
  @override
  void dispose() {
    _morphController.dispose();
    _rotationController.dispose();
    _colorController.dispose();
    super.dispose();
  }
  
  void _updateColorAnimation() {
    _colorAnimation = ColorTween(
      begin: _getShapeColor(_currentShape),
      end: _getShapeColor(_targetShape),
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOut,
    ));
  }
  
  Color _getShapeColor(ShapeType shape) {
    switch (shape) {
      case ShapeType.circle:
        return Colors.blue;
      case ShapeType.square:
        return Colors.red;
      case ShapeType.triangle:
        return Colors.green;
      case ShapeType.hexagon:
        return Colors.purple;
      case ShapeType.star:
        return Colors.orange;
      case ShapeType.heart:
        return Colors.pink;
    }
  }
  
  void _morphToShape(ShapeType shape) {
    if (shape == _currentShape) return;
    
    setState(() {
      _targetShape = shape;
      _updateColorAnimation();
    });
    
    _morphController.duration = Duration(milliseconds: (2000 / _morphSpeed).round());
    _morphController.forward(from: 0).then((_) {
      setState(() {
        _currentShape = _targetShape;
      });
    });
  }
  
  void _selectNextShape() {
    const shapes = ShapeType.values;
    final currentIndex = shapes.indexOf(_currentShape);
    final nextIndex = (currentIndex + 1) % shapes.length;
    _morphToShape(shapes[nextIndex]);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Morphing Shapes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.indigo.shade50,
                    Colors.purple.shade50,
                  ],
                ),
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _morphAnimation,
                    _rotationAnimation,
                    _colorAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _autoPlay ? _rotationAnimation.value : 0,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: CustomPaint(
                          painter: MorphingShapePainter(
                            progress: _morphAnimation.value,
                            fromShape: _currentShape,
                            toShape: _targetShape,
                            color: _colorAnimation.value ?? Colors.blue,
                          ),
                        ),
                      ),
                    );
                  },
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
                  'Select Shape',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ShapeType.values.map((shape) {
                    return _buildShapeButton(shape);
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Morph Speed:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: _morphSpeed,
                        min: 0.5,
                        max: 2.0,
                        divisions: 15,
                        label: '${_morphSpeed.toStringAsFixed(1)}x',
                        onChanged: (value) {
                          setState(() {
                            _morphSpeed = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Auto Play', style: TextStyle(fontWeight: FontWeight.bold)),
                    Switch(
                      value: _autoPlay,
                      onChanged: (value) {
                        setState(() {
                          _autoPlay = value;
                          if (value && _morphController.status == AnimationStatus.dismissed) {
                            _selectNextShape();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildShapeButton(ShapeType shape) {
    final isSelected = _targetShape == shape || (_currentShape == shape && _morphController.status == AnimationStatus.dismissed);
    final color = _getShapeColor(shape);
    
    return GestureDetector(
      onTap: () => _morphToShape(shape),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: CustomPaint(
            size: const Size(30, 30),
            painter: ShapeIconPainter(
              shape: shape,
              color: isSelected ? color : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

enum ShapeType {
  circle,
  square,
  triangle,
  hexagon,
  star,
  heart,
}

class MorphingShapePainter extends CustomPainter {
  final double progress;
  final ShapeType fromShape;
  final ShapeType toShape;
  final Color color;
  
  MorphingShapePainter({
    required this.progress,
    required this.fromShape,
    required this.toShape,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    
    final path = _getMorphingPath(size, progress);
    
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
    
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, highlightPaint);
  }
  
  Path _getMorphingPath(Size size, double progress) {
    final fromPath = _getShapePath(fromShape, size);
    final toPath = _getShapePath(toShape, size);
    
    return _lerpPath(fromPath, toPath, progress);
  }
  
  Path _getShapePath(ShapeType shape, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    
    switch (shape) {
      case ShapeType.circle:
        return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
        
      case ShapeType.square:
        return Path()..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
          const Radius.circular(10),
        ));
        
      case ShapeType.triangle:
        return Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx - radius * 0.866, center.dy + radius * 0.5)
          ..lineTo(center.dx + radius * 0.866, center.dy + radius * 0.5)
          ..close();
          
      case ShapeType.hexagon:
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * math.pi / 3) - math.pi / 2;
          final x = center.dx + radius * math.cos(angle);
          final y = center.dy + radius * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        return path..close();
        
      case ShapeType.star:
        final path = Path();
        for (int i = 0; i < 10; i++) {
          final angle = (i * math.pi / 5) - math.pi / 2;
          final r = i.isEven ? radius : radius * 0.5;
          final x = center.dx + r * math.cos(angle);
          final y = center.dy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        return path..close();
        
      case ShapeType.heart:
        final path = Path();
        path.moveTo(center.dx, center.dy + radius * 0.6);
        path.cubicTo(
          center.dx - radius * 1.2, center.dy,
          center.dx - radius * 1.2, center.dy - radius * 0.6,
          center.dx - radius * 0.6, center.dy - radius * 0.6,
        );
        path.cubicTo(
          center.dx - radius * 0.3, center.dy - radius * 0.9,
          center.dx, center.dy - radius * 0.6,
          center.dx, center.dy - radius * 0.3,
        );
        path.cubicTo(
          center.dx, center.dy - radius * 0.6,
          center.dx + radius * 0.3, center.dy - radius * 0.9,
          center.dx + radius * 0.6, center.dy - radius * 0.6,
        );
        path.cubicTo(
          center.dx + radius * 1.2, center.dy - radius * 0.6,
          center.dx + radius * 1.2, center.dy,
          center.dx, center.dy + radius * 0.6,
        );
        return path;
    }
  }
  
  Path _lerpPath(Path from, Path to, double t) {
    final fromMetrics = from.computeMetrics().toList();
    final toMetrics = to.computeMetrics().toList();
    
    final path = Path();
    
    if (fromMetrics.isNotEmpty && toMetrics.isNotEmpty) {
      final fromMetric = fromMetrics.first;
      final toMetric = toMetrics.first;
      
      const steps = 100;
      for (int i = 0; i <= steps; i++) {
        final distance = i / steps;
        
        final fromTangent = fromMetric.getTangentForOffset(fromMetric.length * distance);
        final toTangent = toMetric.getTangentForOffset(toMetric.length * distance);
        
        if (fromTangent != null && toTangent != null) {
          final x = fromTangent.position.dx + (toTangent.position.dx - fromTangent.position.dx) * t;
          final y = fromTangent.position.dy + (toTangent.position.dy - fromTangent.position.dy) * t;
          
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
      }
      path.close();
    }
    
    return path;
  }
  
  @override
  bool shouldRepaint(MorphingShapePainter oldDelegate) => true;
}

class ShapeIconPainter extends CustomPainter {
  final ShapeType shape;
  final Color color;
  
  ShapeIconPainter({
    required this.shape,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = _getShapePath(shape, size);
    canvas.drawPath(path, paint);
  }
  
  Path _getShapePath(ShapeType shape, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    
    final painter = MorphingShapePainter(
      progress: 0,
      fromShape: shape,
      toShape: shape,
      color: color,
    );
    
    return painter._getShapePath(shape, size);
  }
  
  @override
  bool shouldRepaint(ShapeIconPainter oldDelegate) =>
      shape != oldDelegate.shape || color != oldDelegate.color;
}