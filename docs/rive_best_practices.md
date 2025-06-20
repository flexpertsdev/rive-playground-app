# Rive Animation Best Practices

## Animation Design Guidelines

### 1. State Machine Architecture
- Use a single state machine called 'MeasurementStateMachine'
- Keep states minimal and purpose-driven
- Use blend states for smooth transitions
- Implement clear entry/exit conditions

### 2. Input Organization
```
Inputs/
├── Measurements/
│   ├── Lengths/
│   ├── Girths/
│   └── Curvatures/
├── Visual/
│   ├── ViewMode (top/side)
│   ├── ZoomLevel
│   └── Highlights/
└── States/
    ├── ErectionLevel
    ├── MeasurementMode
    └── ComparisonMode
```

### 3. Performance Optimization
- **Bone Count**: Keep under 30 bones for mobile performance
- **Mesh Density**: Use adaptive mesh density based on zoom level
- **Animation Curves**: Prefer linear interpolation for measurements
- **State Transitions**: Limit to 200ms for responsive feel

### 4. Input Naming Convention
- Use snake_case for all inputs: `body_length`, `glans_girth`
- Prefix view-specific inputs: `top_rotation`, `side_curve`
- Group related inputs: `shaft_lower`, `shaft_middle`, `shaft_upper`

## Flutter Integration Best Practices

### 1. Loading Strategy
```dart
// Cache controller for reuse
class RiveAnimationCache {
  static final Map<String, RiveFile> _cache = {};
  
  static Future<RiveFile> loadAnimation(String url) async {
    if (_cache.containsKey(url)) {
      return _cache[url]!;
    }
    
    final file = await RiveFile.network(url);
    _cache[url] = file;
    return file;
  }
}
```

### 2. State Management Pattern
```dart
// Use ChangeNotifier for reactive updates
class AnimationStateManager extends ChangeNotifier {
  final Map<String, double> _parameters = {};
  
  void updateParameter(String key, double value) {
    if (_parameters[key] != value) {
      _parameters[key] = value;
      _debouncedNotify();
    }
  }
  
  // Debounce updates for performance
  Timer? _debounceTimer;
  void _debouncedNotify() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 16), notifyListeners);
  }
}
```

### 3. Input Binding
```dart
// Efficient input binding with caching
void bindInputs(StateMachineController controller, Map<String, double> values) {
  final inputs = <String, SMIInput>{};
  
  // Cache inputs on first access
  for (final entry in values.entries) {
    inputs[entry.key] ??= controller.findInput<double>(entry.key);
    inputs[entry.key]?.value = entry.value;
  }
}
```

## Measurement Accuracy

### 1. Calibration System
- Implement reference markers for known sizes
- Use percentage-based scaling (0-100%)
- Apply non-linear scaling for realistic proportions
- Account for perspective distortion

### 2. Visual Feedback
- Highlight active measurement area
- Show measurement guides/rulers
- Display confidence intervals
- Animate measurement changes

### 3. Error Handling
```dart
// Validate measurement ranges
double validateMeasurement(String parameter, double value) {
  final range = measurementRanges[parameter];
  if (range == null) return value;
  
  return value.clamp(range.min, range.max);
}

// Graceful degradation
Widget buildAnimation() {
  return FutureBuilder<RiveFile>(
    future: loadAnimation(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return FallbackVisualization();
      }
      return RiveAnimation(snapshot.data!);
    },
  );
}
```

## User Experience

### 1. Interactive Zones
- Define clear touch targets (min 44x44 pixels)
- Implement hover states for desktop
- Add visual feedback for interactions
- Support multi-touch gestures

### 2. Accessibility
- Provide semantic labels for screen readers
- Support keyboard navigation
- Implement high contrast mode
- Add haptic feedback for key actions

### 3. Progressive Disclosure
- Start with simple mode (grouped parameters)
- Allow switching to advanced mode
- Remember user preferences
- Provide contextual help

## Testing Strategy

### 1. Unit Tests
```dart
test('Measurement conversion accuracy', () {
  final converter = MeasurementConverter();
  
  // Test edge cases
  expect(converter.percentageToActual('body_length', 0), 0.9);
  expect(converter.percentageToActual('body_length', 100), 27.9);
  
  // Test mid-range
  expect(converter.percentageToActual('body_length', 50), closeTo(14.4, 0.1));
});
```

### 2. Widget Tests
```dart
testWidgets('Animation responds to parameter changes', (tester) async {
  await tester.pumpWidget(TestableAnimationWidget());
  
  // Change parameter
  await tester.drag(find.byKey(Key('body_length_slider')), Offset(100, 0));
  await tester.pump();
  
  // Verify animation updated
  final animation = tester.widget<RiveAnimation>(find.byType(RiveAnimation));
  expect(animation.controller.getInputValue('body_length'), 75.0);
});
```

### 3. Performance Tests
- Measure frame rate during parameter changes
- Test memory usage with extended sessions
- Verify smooth transitions
- Check load times on various devices