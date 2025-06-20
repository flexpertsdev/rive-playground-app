import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide LinearGradient, RadialGradient;
import 'dart:math' as math;

class InteractiveCharacterDemo extends StatefulWidget {
  const InteractiveCharacterDemo({super.key});

  @override
  State<InteractiveCharacterDemo> createState() => _InteractiveCharacterDemoState();
}

class _InteractiveCharacterDemoState extends State<InteractiveCharacterDemo> {
  StateMachineController? _controller;
  SMITrigger? _happyTrigger;
  SMITrigger? _sadTrigger;
  SMITrigger? _waveTrigger;
  SMITrigger? _jumpTrigger;
  SMINumber? _lookX;
  SMINumber? _lookY;
  SMIBool? _isExcited;

  String _currentEmotion = 'neutral';
  bool _isLoading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Character'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade100,
                    Colors.blue.shade50,
                  ],
                ),
              ),
              child: Center(
                child: _buildCharacterAnimation(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
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
              child: _buildControls(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterAnimation() {
    if (_error != null) {
      return _buildPlaceholderCharacter();
    }

    if (_isLoading) {
      return _buildPlaceholderCharacter();
    }

    return MouseRegion(
      onHover: (event) {
        if (_lookX != null && _lookY != null) {
          final box = context.findRenderObject() as RenderBox;
          final localPosition = box.globalToLocal(event.position);
          final size = box.size;
          
          _lookX!.value = (localPosition.dx / size.width - 0.5) * 2;
          _lookY!.value = (localPosition.dy / size.height - 0.5) * 2;
        }
      },
      child: GestureDetector(
        onTap: () {
          _waveTrigger?.fire();
        },
        child: SizedBox(
          width: 300,
          height: 300,
          child: _buildPlaceholderCharacter(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCharacter() {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CustomPaint(
        painter: CharacterPainter(
          emotion: _currentEmotion,
          isExcited: _isExcited?.value ?? false,
        ),
      ),
    );
  }

  Widget _buildControls() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            'Character Controls',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          const Text(
            'Emotions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildEmotionButton(
                'Happy',
                Icons.sentiment_very_satisfied,
                Colors.green,
                () {
                  setState(() => _currentEmotion = 'happy');
                  _happyTrigger?.fire();
                },
              ),
              _buildEmotionButton(
                'Sad',
                Icons.sentiment_very_dissatisfied,
                Colors.blue,
                () {
                  setState(() => _currentEmotion = 'sad');
                  _sadTrigger?.fire();
                },
              ),
              _buildEmotionButton(
                'Excited',
                Icons.celebration,
                Colors.orange,
                () {
                  setState(() {
                    _currentEmotion = 'excited';
                    _isExcited?.value = true;
                  });
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _isExcited?.value = false;
                      });
                    }
                  });
                },
              ),
              _buildEmotionButton(
                'Wave',
                Icons.waving_hand,
                Colors.purple,
                () {
                  _waveTrigger?.fire();
                },
              ),
              _buildEmotionButton(
                'Jump',
                Icons.arrow_upward,
                Colors.red,
                () {
                  _jumpTrigger?.fire();
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              children: [
                Icon(Icons.touch_app, size: 30, color: Colors.grey),
                SizedBox(height: 5),
                Text(
                  'Move mouse over character to make it look around',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 5),
                Text(
                  'Tap on character to wave',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      'CharacterStateMachine',
    );
    
    if (controller != null) {
      artboard.addController(controller);
      _controller = controller;
      
      _happyTrigger = controller.findInput<bool>('happy') as SMITrigger?;
      _sadTrigger = controller.findInput<bool>('sad') as SMITrigger?;
      _waveTrigger = controller.findInput<bool>('wave') as SMITrigger?;
      _jumpTrigger = controller.findInput<bool>('jump') as SMITrigger?;
      _lookX = controller.findInput<double>('lookX') as SMINumber?;
      _lookY = controller.findInput<double>('lookY') as SMINumber?;
      _isExcited = controller.findInput<bool>('isExcited') as SMIBool?;
      
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class CharacterPainter extends CustomPainter {
  final String emotion;
  final bool isExcited;
  
  CharacterPainter({
    required this.emotion,
    required this.isExcited,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    
    final facePaint = Paint()
      ..color = Colors.yellow.shade300
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, facePaint);
    
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final leftEye = Offset(center.dx - radius * 0.3, center.dy - radius * 0.2);
    final rightEye = Offset(center.dx + radius * 0.3, center.dy - radius * 0.2);
    
    if (emotion == 'happy' || isExcited) {
      final eyePath = Path();
      eyePath.moveTo(leftEye.dx - 10, leftEye.dy);
      eyePath.quadraticBezierTo(leftEye.dx, leftEye.dy + 10, leftEye.dx + 10, leftEye.dy);
      canvas.drawPath(eyePath, eyePaint..style = PaintingStyle.stroke..strokeWidth = 3);
      
      final rightEyePath = Path();
      rightEyePath.moveTo(rightEye.dx - 10, rightEye.dy);
      rightEyePath.quadraticBezierTo(rightEye.dx, rightEye.dy + 10, rightEye.dx + 10, rightEye.dy);
      canvas.drawPath(rightEyePath, eyePaint);
    } else {
      canvas.drawCircle(leftEye, 5, eyePaint);
      canvas.drawCircle(rightEye, 5, eyePaint);
    }
    
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final mouthPath = Path();
    final mouthStart = Offset(center.dx - radius * 0.3, center.dy + radius * 0.2);
    final mouthEnd = Offset(center.dx + radius * 0.3, center.dy + radius * 0.2);
    
    if (emotion == 'happy' || isExcited) {
      mouthPath.moveTo(mouthStart.dx, mouthStart.dy);
      mouthPath.quadraticBezierTo(
        center.dx, center.dy + radius * 0.5,
        mouthEnd.dx, mouthEnd.dy,
      );
    } else if (emotion == 'sad') {
      mouthPath.moveTo(mouthStart.dx, mouthStart.dy + 10);
      mouthPath.quadraticBezierTo(
        center.dx, center.dy + radius * 0.1,
        mouthEnd.dx, mouthEnd.dy + 10,
      );
    } else {
      mouthPath.moveTo(mouthStart.dx, mouthStart.dy);
      mouthPath.lineTo(mouthEnd.dx, mouthEnd.dy);
    }
    
    canvas.drawPath(mouthPath, mouthPaint);
    
    if (isExcited) {
      final sparkPaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.fill;
      
      for (int i = 0; i < 5; i++) {
        final angle = (i * 72) * 3.14159 / 180;
        final sparkX = center.dx + (radius + 20) * math.cos(angle);
        final sparkY = center.dy + (radius + 20) * math.sin(angle);
        canvas.drawCircle(Offset(sparkX, sparkY), 5, sparkPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(CharacterPainter oldDelegate) {
    return emotion != oldDelegate.emotion || isExcited != oldDelegate.isExcited;
  }
}