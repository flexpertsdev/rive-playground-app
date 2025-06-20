import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Improved measurement widget with better state management and performance
class ImprovedMeasurementWidget extends StatefulWidget {
  const ImprovedMeasurementWidget({super.key});

  @override
  State<ImprovedMeasurementWidget> createState() => _ImprovedMeasurementWidgetState();
}

class _ImprovedMeasurementWidgetState extends State<ImprovedMeasurementWidget>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _updateController;
  late RiveAnimationController _riveController;
  
  // State management
  final MeasurementState _measurementState = MeasurementState();
  
  // Performance optimization
  DateTime _lastUpdate = DateTime.now();
  static const _updateThreshold = Duration(milliseconds: 16); // 60 FPS
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _measurementState.addListener(_onStateChanged);
  }
  
  void _initializeControllers() {
    _updateController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _riveController = OneShotAnimation(
      'idle',
      autoplay: true,
    );
  }
  
  void _onStateChanged() {
    // Throttle updates for performance
    final now = DateTime.now();
    if (now.difference(_lastUpdate) < _updateThreshold) {
      return;
    }
    _lastUpdate = now;
    
    // Smooth animation update
    _updateController.forward(from: 0);
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animation display
        Expanded(
          child: AnimatedBuilder(
            animation: _updateController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Rive animation
                  _buildRiveAnimation(),
                  
                  // Measurement overlay
                  if (_measurementState.showMeasurements)
                    _buildMeasurementOverlay(),
                  
                  // Interactive guides
                  if (_measurementState.showGuides)
                    _buildInteractiveGuides(),
                ],
              );
            },
          ),
        ),
        
        // Control panel
        _buildControlPanel(),
      ],
    );
  }
  
  Widget _buildRiveAnimation() {
    return RiveAnimation.asset(
      'assets/animations/improved_measurement.riv',
      controllers: [_riveController],
      onInit: _onRiveInit,
      fit: BoxFit.contain,
    );
  }
  
  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      'MeasurementStateMachine',
    );
    
    if (controller != null) {
      artboard.addController(controller);
      _bindMeasurementInputs(controller);
    }
  }
  
  void _bindMeasurementInputs(StateMachineController controller) {
    // Bind measurement parameters to Rive inputs
    for (final param in _measurementState.parameters.entries) {
      final input = controller.findInput<double>(param.key);
      if (input != null) {
        input.value = param.value.percentage;
      }
    }
  }
  
  Widget _buildMeasurementOverlay() {
    return CustomPaint(
      painter: MeasurementOverlayPainter(
        measurements: _measurementState.parameters,
        unit: _measurementState.unit,
      ),
    );
  }
  
  Widget _buildInteractiveGuides() {
    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onScaleUpdate: _handleScaleUpdate,
      child: CustomPaint(
        painter: InteractiveGuidesPainter(
          activeParameter: _measurementState.activeParameter,
        ),
      ),
    );
  }
  
  void _handlePanUpdate(DragUpdateDetails details) {
    // Handle drag to adjust parameters
    if (_measurementState.activeParameter != null) {
      _measurementState.adjustParameterByDelta(
        _measurementState.activeParameter!,
        details.delta.dy / -200, // Convert to percentage
      );
    }
  }
  
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    // Handle pinch to zoom
    _measurementState.zoomLevel = details.scale.clamp(0.5, 3.0);
  }
  
  Widget _buildControlPanel() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Mode selector
          _buildModeSelector(),
          
          // Parameter controls
          Expanded(
            child: _buildParameterControls(),
          ),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }
  
  Widget _buildModeSelector() {
    return SegmentedButton<MeasurementMode>(
      segments: const [
        ButtonSegment(
          value: MeasurementMode.simple,
          label: Text('Simple'),
          icon: Icon(Icons.dashboard),
        ),
        ButtonSegment(
          value: MeasurementMode.advanced,
          label: Text('Advanced'),
          icon: Icon(Icons.tune),
        ),
        ButtonSegment(
          value: MeasurementMode.comparison,
          label: Text('Compare'),
          icon: Icon(Icons.compare_arrows),
        ),
      ],
      selected: {_measurementState.mode},
      onSelectionChanged: (Set<MeasurementMode> modes) {
        setState(() {
          _measurementState.mode = modes.first;
        });
      },
    );
  }
  
  Widget _buildParameterControls() {
    return ListView(
      children: _measurementState.visibleParameters.map((param) {
        return _ParameterSlider(
          parameter: param,
          onChanged: (value) {
            _measurementState.updateParameter(param.key, value);
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: _saveCurrentState,
          tooltip: 'Save measurement',
        ),
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: _showHistory,
          tooltip: 'View history',
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareResults,
          tooltip: 'Share results',
        ),
      ],
    );
  }
  
  void _saveCurrentState() {
    _measurementState.saveSnapshot();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Measurement saved')),
    );
  }
  
  void _showHistory() {
    // Navigate to history view
  }
  
  void _shareResults() {
    // Share functionality
  }
  
  @override
  void dispose() {
    _updateController.dispose();
    _measurementState.removeListener(_onStateChanged);
    _measurementState.dispose();
    super.dispose();
  }
}

/// Parameter slider widget
class _ParameterSlider extends StatelessWidget {
  final MeasurementParameter parameter;
  final ValueChanged<double> onChanged;
  
  const _ParameterSlider({
    required this.parameter,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                parameter.displayName,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                parameter.formattedValue,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Slider(
            value: parameter.percentage,
            onChanged: onChanged,
            min: 0,
            max: 100,
            divisions: 100,
          ),
        ],
      ),
    );
  }
}

/// Measurement state management
class MeasurementState extends ChangeNotifier {
  final Map<String, MeasurementParameter> parameters = {};
  MeasurementMode mode = MeasurementMode.simple;
  MeasurementUnit unit = MeasurementUnit.metric;
  bool showMeasurements = true;
  bool showGuides = false;
  String? activeParameter;
  double zoomLevel = 1.0;
  
  List<MeasurementParameter> get visibleParameters {
    // Return parameters based on current mode
    return parameters.values.where((param) {
      if (mode == MeasurementMode.simple) {
        return param.isSimpleMode;
      }
      return true;
    }).toList();
  }
  
  void updateParameter(String key, double percentage) {
    if (parameters.containsKey(key)) {
      parameters[key]!.percentage = percentage;
      notifyListeners();
    }
  }
  
  void adjustParameterByDelta(String key, double delta) {
    if (parameters.containsKey(key)) {
      final param = parameters[key]!;
      param.percentage = (param.percentage + delta).clamp(0, 100);
      notifyListeners();
    }
  }
  
  void saveSnapshot() {
    // Save current state to database
  }
}

/// Measurement parameter model
class MeasurementParameter {
  final String key;
  final String displayName;
  final double minValue;
  final double maxValue;
  final bool isSimpleMode;
  double percentage;
  
  MeasurementParameter({
    required this.key,
    required this.displayName,
    required this.minValue,
    required this.maxValue,
    required this.isSimpleMode,
    this.percentage = 50,
  });
  
  double get actualValue {
    return minValue + (maxValue - minValue) * (percentage / 100);
  }
  
  String get formattedValue {
    return '${actualValue.toStringAsFixed(1)} cm';
  }
}

/// Enums
enum MeasurementMode { simple, advanced, comparison }
enum MeasurementUnit { metric, imperial }

/// Custom painters
class MeasurementOverlayPainter extends CustomPainter {
  final Map<String, MeasurementParameter> measurements;
  final MeasurementUnit unit;
  
  MeasurementOverlayPainter({
    required this.measurements,
    required this.unit,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw measurement overlays
  }
  
  @override
  bool shouldRepaint(MeasurementOverlayPainter oldDelegate) {
    return measurements != oldDelegate.measurements ||
           unit != oldDelegate.unit;
  }
}

class InteractiveGuidesPainter extends CustomPainter {
  final String? activeParameter;
  
  InteractiveGuidesPainter({
    required this.activeParameter,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw interactive guides
  }
  
  @override
  bool shouldRepaint(InteractiveGuidesPainter oldDelegate) {
    return activeParameter != oldDelegate.activeParameter;
  }
}