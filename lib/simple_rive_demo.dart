import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flutter/services.dart';

class SimpleRiveDemo extends StatefulWidget {
  const SimpleRiveDemo({super.key});

  @override
  State<SimpleRiveDemo> createState() => _SimpleRiveDemoState();
}

class _SimpleRiveDemoState extends State<SimpleRiveDemo> {
  // Rive controller
  StateMachineController? _controller;
  
  // Input controls
  SMINumber? _lengthInput;
  SMINumber? _girthInput;
  SMIBool? _showMeasurements;
  
  // Current values
  double _lengthValue = 50;
  double _girthValue = 50;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Rive Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Rive Animation Container
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[100],
              child: Center(
                child: _buildRiveAnimation(),
              ),
            ),
          ),
          
          // Controls
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Adjust Parameters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Length Slider
                  _buildSlider(
                    label: 'Length',
                    value: _lengthValue,
                    actualValue: _percentageToLength(_lengthValue),
                    onChanged: (value) {
                      setState(() {
                        _lengthValue = value;
                        _lengthInput?.value = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Girth Slider
                  _buildSlider(
                    label: 'Girth',
                    value: _girthValue,
                    actualValue: _percentageToGirth(_girthValue),
                    onChanged: (value) {
                      setState(() {
                        _girthValue = value;
                        _girthInput?.value = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Toggle Measurements
                  SwitchListTile(
                    title: const Text('Show Measurements'),
                    value: _showMeasurements?.value ?? false,
                    onChanged: (value) {
                      setState(() {
                        _showMeasurements?.value = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRiveAnimation() {
    // For demo purposes, we'll use a simple shape animation
    // You can replace this with your actual Rive file
    return Stack(
      children: [
        // Placeholder animation or actual Rive file
        _buildPlaceholderAnimation(),
        
        // Measurement overlay
        if (_showMeasurements?.value ?? false)
          Positioned.fill(
            child: CustomPaint(
              painter: MeasurementPainter(
                length: _percentageToLength(_lengthValue),
                girth: _percentageToGirth(_girthValue),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildPlaceholderAnimation() {
    // This is a placeholder - replace with actual Rive animation
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CustomPaint(
        painter: PlaceholderShapePainter(
          lengthPercentage: _lengthValue,
          girthPercentage: _girthValue,
        ),
      ),
    );
    
    // To use actual Rive file, uncomment this:
    // return RiveAnimation.asset(
    //   'animations/your_animation.riv',
    //   fit: BoxFit.contain,
    //   onInit: _onRiveInit,
    // );
  }
  
  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      'StateMachine', // Your state machine name
    );
    
    if (controller != null) {
      artboard.addController(controller);
      _controller = controller;
      
      // Get inputs
      _lengthInput = controller.findInput<double>('length') as SMINumber?;
      _girthInput = controller.findInput<double>('girth') as SMINumber?;
      _showMeasurements = controller.findInput<bool>('show_measurements') as SMIBool?;
      
      // Set initial values
      _lengthInput?.value = _lengthValue;
      _girthInput?.value = _girthValue;
    }
  }
  
  Widget _buildSlider({
    required String label,
    required double value,
    required double actualValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              '${actualValue.toStringAsFixed(1)} cm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${value.round()}%',
          onChanged: onChanged,
        ),
      ],
    );
  }
  
  // Conversion functions (matching your specs)
  double _percentageToLength(double percentage) {
    // Body length: 0.9 cm to 27.9 cm
    return 0.9 + (27.9 - 0.9) * (percentage / 100);
  }
  
  double _percentageToGirth(double percentage) {
    // Girth: 1.2 cm to 6.7 cm
    return 1.2 + (6.7 - 1.2) * (percentage / 100);
  }
}

// Placeholder shape painter
class PlaceholderShapePainter extends CustomPainter {
  final double lengthPercentage;
  final double girthPercentage;
  
  PlaceholderShapePainter({
    required this.lengthPercentage,
    required this.girthPercentage,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final length = size.height * 0.6 * (lengthPercentage / 100);
    final width = size.width * 0.3 * (girthPercentage / 100);
    
    // Draw a simple shape
    final rect = Rect.fromCenter(
      center: center,
      width: width,
      height: length,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(width / 2)),
      paint,
    );
    
    // Draw outline
    paint
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(width / 2)),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(PlaceholderShapePainter oldDelegate) {
    return lengthPercentage != oldDelegate.lengthPercentage ||
           girthPercentage != oldDelegate.girthPercentage;
  }
}

// Measurement overlay painter
class MeasurementPainter extends CustomPainter {
  final double length;
  final double girth;
  
  MeasurementPainter({
    required this.length,
    required this.girth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw length measurement line
    final lengthStart = Offset(size.width * 0.7, size.height * 0.2);
    final lengthEnd = Offset(size.width * 0.7, size.height * 0.8);
    
    canvas.drawLine(lengthStart, lengthEnd, paint);
    
    // Length text
    textPainter.text = TextSpan(
      text: '${length.toStringAsFixed(1)} cm',
      style: const TextStyle(color: Colors.red, fontSize: 14),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.72, size.height * 0.5 - textPainter.height / 2),
    );
    
    // Draw girth measurement line
    final girthStart = Offset(size.width * 0.3, size.height * 0.9);
    final girthEnd = Offset(size.width * 0.7, size.height * 0.9);
    
    canvas.drawLine(girthStart, girthEnd, paint);
    
    // Girth text
    textPainter.text = TextSpan(
      text: '${girth.toStringAsFixed(1)} cm',
      style: const TextStyle(color: Colors.red, fontSize: 14),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.5 - textPainter.width / 2, size.height * 0.92),
    );
  }
  
  @override
  bool shouldRepaint(MeasurementPainter oldDelegate) {
    return length != oldDelegate.length || girth != oldDelegate.girth;
  }
}