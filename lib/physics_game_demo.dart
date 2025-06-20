import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide LinearGradient, RadialGradient;
import 'dart:math' as math;

class PhysicsGameDemo extends StatefulWidget {
  const PhysicsGameDemo({super.key});

  @override
  State<PhysicsGameDemo> createState() => _PhysicsGameDemoState();
}

class _PhysicsGameDemoState extends State<PhysicsGameDemo> with TickerProviderStateMixin {
  final List<Ball> _balls = [];
  late AnimationController _animationController;
  int _score = 0;
  double _gravity = 0.5;
  double _bounce = 0.8;
  bool _isPaused = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    _animationController.addListener(_updatePhysics);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _updatePhysics() {
    if (_isPaused) return;
    
    setState(() {
      for (final ball in _balls) {
        ball.velocity = Offset(ball.velocity.dx, ball.velocity.dy + _gravity);
        
        ball.position += ball.velocity;
        
        final screenSize = MediaQuery.of(context).size;
        final gameHeight = screenSize.height * 0.6;
        final gameWidth = screenSize.width;
        
        if (ball.position.dx - ball.radius < 0 || ball.position.dx + ball.radius > gameWidth) {
          ball.velocity = Offset(-ball.velocity.dx * _bounce, ball.velocity.dy);
          ball.position = Offset(
            ball.position.dx.clamp(ball.radius, gameWidth - ball.radius),
            ball.position.dy,
          );
        }
        
        if (ball.position.dy + ball.radius > gameHeight) {
          ball.velocity = Offset(ball.velocity.dx, -ball.velocity.dy * _bounce);
          ball.position = Offset(ball.position.dx, gameHeight - ball.radius);
          
          if (ball.velocity.dy.abs() < 1) {
            ball.velocity = Offset(ball.velocity.dx, 0);
          }
        }
        
        if (ball.position.dy - ball.radius < 0) {
          ball.velocity = Offset(ball.velocity.dx, ball.velocity.dy.abs());
          ball.position = Offset(ball.position.dx, ball.radius);
        }
      }
      
      _checkCollisions();
    });
  }
  
  void _checkCollisions() {
    for (int i = 0; i < _balls.length; i++) {
      for (int j = i + 1; j < _balls.length; j++) {
        final ball1 = _balls[i];
        final ball2 = _balls[j];
        
        final distance = (ball1.position - ball2.position).distance;
        final minDistance = ball1.radius + ball2.radius;
        
        if (distance < minDistance) {
          final normal = (ball2.position - ball1.position) / distance;
          final relativeVelocity = ball2.velocity - ball1.velocity;
          final velocityAlongNormal = relativeVelocity.dx * normal.dx + relativeVelocity.dy * normal.dy;
          
          if (velocityAlongNormal > 0) continue;
          
          final restitution = _bounce;
          final impulse = 2 * velocityAlongNormal / 2;
          final impulseVector = normal * impulse * restitution;
          
          ball1.velocity += impulseVector;
          ball2.velocity -= impulseVector;
          
          final overlap = minDistance - distance;
          final separation = normal * (overlap / 2);
          ball1.position -= separation;
          ball2.position += separation;
        }
      }
    }
  }
  
  void _addBall(Offset position) {
    setState(() {
      final random = math.Random();
      final color = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.pink,
        Colors.teal,
      ][random.nextInt(7)];
      
      _balls.add(Ball(
        position: position,
        velocity: Offset(
          (random.nextDouble() - 0.5) * 10,
          random.nextDouble() * -10 - 5,
        ),
        radius: random.nextDouble() * 20 + 15,
        color: color,
      ));
      
      _score += 10;
    });
  }
  
  void _clearBalls() {
    setState(() {
      _balls.clear();
      _score = 0;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Physics Playground'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Score: $_score',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTapDown: (details) {
                _addBall(details.localPosition);
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.cyan.shade50,
                      Colors.cyan.shade100,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size.infinite,
                      painter: BallsPainter(balls: _balls),
                    ),
                    if (_balls.isEmpty)
                      const Center(
                        child: Text(
                          'Tap to add balls!',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                            fontWeight: FontWeight.w300,
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
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gravity', style: TextStyle(fontWeight: FontWeight.bold)),
                          Slider(
                            value: _gravity,
                            min: 0,
                            max: 2,
                            divisions: 20,
                            label: _gravity.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() {
                                _gravity = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bounce', style: TextStyle(fontWeight: FontWeight.bold)),
                          Slider(
                            value: _bounce,
                            min: 0,
                            max: 1,
                            divisions: 10,
                            label: _bounce.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() {
                                _bounce = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isPaused = !_isPaused;
                        });
                      },
                      icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                      label: Text(_isPaused ? 'Play' : 'Pause'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _clearBalls,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        for (final ball in _balls) {
                          ball.velocity = Offset(
                            (math.Random().nextDouble() - 0.5) * 20,
                            -math.Random().nextDouble() * 20 - 10,
                          );
                        }
                      },
                      icon: const Icon(Icons.rocket_launch),
                      label: const Text('Boost!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Balls: ${_balls.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Ball {
  Offset position;
  Offset velocity;
  final double radius;
  final Color color;
  
  Ball({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
  });
}

class BallsPainter extends CustomPainter {
  final List<Ball> balls;
  
  BallsPainter({required this.balls});
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final ball in balls) {
      final paint = Paint()
        ..color = ball.color
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(ball.position, ball.radius, paint);
      
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      
      final highlightOffset = Offset(
        ball.position.dx - ball.radius * 0.3,
        ball.position.dy - ball.radius * 0.3,
      );
      
      canvas.drawCircle(highlightOffset, ball.radius * 0.3, highlightPaint);
      
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
      canvas.drawCircle(
        Offset(ball.position.dx + 2, ball.position.dy + 2),
        ball.radius,
        shadowPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(BallsPainter oldDelegate) => true;
}