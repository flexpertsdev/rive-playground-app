import 'package:flutter/material.dart';
import 'simple_rive_demo.dart';
import 'interactive_character_demo.dart';
import 'physics_game_demo.dart';
import 'animated_charts_demo.dart';
import 'gesture_animation_demo.dart';
import 'morphing_shapes_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rive Animation Playground',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rive Animation Playground'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Welcome to Rive Playground!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Explore interactive animations and effects',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            _buildDemoGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoGrid(BuildContext context) {
    final demos = [
      DemoItem(
        title: 'Simple Rive Demo',
        description: 'Basic Rive animation with controls',
        icon: Icons.animation,
        color: Colors.blue,
        page: const SimpleRiveDemo(),
      ),
      DemoItem(
        title: 'Interactive Character',
        description: 'Character with emotions and gestures',
        icon: Icons.face,
        color: Colors.green,
        page: const InteractiveCharacterDemo(),
      ),
      DemoItem(
        title: 'Physics Playground',
        description: 'Interactive physics simulation',
        icon: Icons.sports_basketball,
        color: Colors.orange,
        page: const PhysicsGameDemo(),
      ),
      DemoItem(
        title: 'Animated Charts',
        description: 'Dynamic data visualization',
        icon: Icons.bar_chart,
        color: Colors.purple,
        page: const AnimatedChartsDemo(),
      ),
      DemoItem(
        title: 'Gesture Controls',
        description: 'Drag, pinch, and rotate animations',
        icon: Icons.touch_app,
        color: Colors.red,
        page: const GestureAnimationDemo(),
      ),
      DemoItem(
        title: 'Morphing Shapes',
        description: 'Smooth shape transitions',
        icon: Icons.auto_awesome,
        color: Colors.pink,
        page: const MorphingShapesDemo(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: demos.length,
      itemBuilder: (context, index) {
        final demo = demos[index];
        return _buildDemoCard(context, demo);
      },
    );
  }

  Widget _buildDemoCard(BuildContext context, DemoItem demo) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => demo.page),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                demo.color.withOpacity(0.1),
                demo.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                demo.icon,
                size: 40,
                color: demo.color,
              ),
              const SizedBox(height: 10),
              Text(
                demo.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                demo.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DemoItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget page;

  DemoItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.page,
  });
}