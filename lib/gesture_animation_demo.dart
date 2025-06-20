import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide LinearGradient, RadialGradient;
import 'dart:math' as math;

class GestureAnimationDemo extends StatefulWidget {
  const GestureAnimationDemo({super.key});

  @override
  State<GestureAnimationDemo> createState() => _GestureAnimationDemoState();
}

class _GestureAnimationDemoState extends State<GestureAnimationDemo> with TickerProviderStateMixin {
  Offset _position = Offset.zero;
  double _rotation = 0;
  double _scale = 1;
  Color _color = Colors.blue;
  
  Offset _velocity = Offset.zero;
  late AnimationController _inertiaController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _showTrail = true;
  final List<TrailPoint> _trail = [];
  
  @override
  void initState() {
    super.initState();
    _inertiaController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));
    
    _inertiaController.addListener(_updateInertia);
  }
  
  @override
  void dispose() {
    _inertiaController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _updateInertia() {
    if (_velocity.distance > 0.1) {
      setState(() {
        _position += _velocity * (1 - _inertiaController.value);
        
        if (_showTrail) {
          _trail.add(TrailPoint(
            position: _position,
            color: _color.withOpacity(0.5 * (1 - _inertiaController.value)),
            size: 20 * _scale * (1 - _inertiaController.value * 0.5),
          ));
          
          if (_trail.length > 50) {
            _trail.removeAt(0);
          }
        }
      });
    }
  }
  
  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
      _velocity = details.delta;
      
      if (_showTrail) {
        _trail.add(TrailPoint(
          position: _position,
          color: _color.withOpacity(0.5),
          size: 20 * _scale,
        ));
        
        if (_trail.length > 50) {
          _trail.removeAt(0);
        }
      }
    });
  }
  
  void _handlePanEnd(DragEndDetails details) {
    _velocity = details.velocity.pixelsPerSecond / 100;
    _inertiaController.forward(from: 0);
  }
  
  void _handleDoubleTap() {
    _pulseController.forward(from: 0).then((_) {
      _pulseController.reverse();
    });
    
    setState(() {
      _color = [
        Colors.blue,
        Colors.red,
        Colors.green,
        Colors.purple,
        Colors.orange,
        Colors.pink,
      ][(_color == Colors.pink ? 0 : _color.value + 1) % 6];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture-Controlled Animation'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              onDoubleTap: _handleDoubleTap,
              onScaleUpdate: (details) {
                setState(() {
                  _scale = (_scale * details.scale).clamp(0.5, 3.0);
                  _rotation += details.rotation;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      Colors.grey.shade100,
                      Colors.grey.shade300,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    if (_showTrail)
                      CustomPaint(
                        size: Size.infinite,
                        painter: TrailPainter(trail: _trail),
                      ),
                    Center(
                      child: Transform.translate(
                        offset: _position,
                        child: Transform.rotate(
                          angle: _rotation,
                          child: Transform.scale(
                            scale: _scale * (_pulseAnimation.value),
                            child: _buildAnimatedShape(),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestures:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('• Drag to move'),
                            Text('• Pinch to scale'),
                            Text('• Rotate with two fingers'),
                            Text('• Double tap to change color'),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Show Trail',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: _showTrail,
                      onChanged: (value) {
                        setState(() {
                          _showTrail = value;
                          if (!value) _trail.clear();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _position = Offset.zero;
                          _rotation = 0;
                          _scale = 1;
                          _trail.clear();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _trail.clear();
                        });
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Trail'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Scale: ${_scale.toStringAsFixed(1)}x',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Rotation: ${(_rotation * 180 / math.pi).toStringAsFixed(0)}°',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
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
  
  Widget _buildAnimatedShape() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: CustomPaint(
        painter: ShapePainter(color: _color),
      ),
    );
  }
}

class TrailPoint {
  final Offset position;
  final Color color;
  final double size;
  
  TrailPoint({
    required this.position,
    required this.color,
    required this.size,
  });
}

class TrailPainter extends CustomPainter {
  final List<TrailPoint> trail;
  
  TrailPainter({required this.trail});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < trail.length; i++) {
      final opacity = i / trail.length;
      final paint = Paint()
        ..color = trail[i].color.withOpacity(opacity * 0.5)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        center + trail[i].position,
        trail[i].size * (i / trail.length),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(TrailPainter oldDelegate) => true;
}

class ShapePainter extends CustomPainter {
  final Color color;
  
  ShapePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    const points = 6;
    final radius = size.width * 0.3;
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < points; i++) {
      final angle = (i * 2 * math.pi / points) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(ShapePainter oldDelegate) => color != oldDelegate.color;
}