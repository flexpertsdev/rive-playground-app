# Animation Specifications

## Measurement Parameters

### Length Measurements
| Parameter | Min Value | Max Value | Description |
|-----------|-----------|-----------|-------------|
| Bone Length | 0 cm | 6 cm | Fat pad depth |
| Body Length | 0.9 cm | 27.9 cm | Shaft length |
| Glans Length | 1.7 cm | 9.3 cm | Glans length |
| Glans Deep | 0 cm | 0.9 cm | Glans roundness |

### Girth Measurements (All shaft measurements)
| Parameter | Min Value | Max Value |
|-----------|-----------|-----------|
| Non-bone Shaft | 1.2 cm | 6.7 cm |
| Lower Shaft | 1.2 cm | 6.7 cm |
| Middle Shaft | 1.2 cm | 6.7 cm |
| Upper Shaft | 1.2 cm | 6.7 cm |
| Upper2 Shaft | 1.2 cm | 6.7 cm |

### Glans Measurements
| Parameter | View | Min Value | Max Value |
|-----------|------|-----------|-----------|
| Glans Corona | TOP | 1.2 cm | 8.3 cm |
| Glans Base | TOP | 1.2 cm | 7.3 cm |
| Glans Middle | TOP | 1 cm | 7.2 cm |
| Glans Corona | SIDE | Combined: 1.1 cm | Combined: 7.6 cm |
| Glans Bottom | SIDE | See corona | See corona |

### Curvature & Rotation
| Parameter | Range | Description |
|-----------|-------|-------------|
| Dorsal Curve | 0-5 | Upward curvature |
| Ventral Curve | 0-5 | Downward curvature |
| Left Curve | 0-5 | Left curvature |
| Right Curve | 0-5 | Right curvature |
| Rotation | -180° to +180° | Axial rotation |

### Visual Features
| Parameter | Type | Description |
|-----------|------|-------------|
| Circumcision | Toggle | Circumcised/Uncircumcised |
| Erection State | Range | Flaccid to Erect |
| Foreskin Coverage | Percentage | When uncircumcised |

## Animation States

### Primary States
1. **Flaccid**: Default relaxed state
2. **Semi-Erect**: Partial tumescence
3. **Erect**: Full erection
4. **Stretched**: Manual stretch measurement

### Measurement Modes
1. **Bone Pressed**: Include fat pad measurement
2. **Non-Bone Pressed**: Surface measurement only
3. **Stretched Flaccid**: Maximum stretch length

## Interactive Features

### User Interactions
- **Drag**: Adjust individual parameters
- **Pinch**: Zoom in/out
- **Rotate**: 3D rotation (if implemented)
- **Tap**: Show/hide measurements
- **Long Press**: Access context menu

### Visual Feedback
- **Hover Effects**: Highlight interactive areas
- **Selection State**: Show active parameter
- **Transition Animations**: Smooth morphing between states
- **Measurement Lines**: Dynamic rulers and guides

## Performance Requirements

### Target Metrics
- **Frame Rate**: 60 FPS minimum
- **Load Time**: < 2 seconds for animation
- **Response Time**: < 100ms for user input
- **Memory Usage**: < 50MB for animation assets

### Optimization Strategies
- Level of Detail (LOD) for zoom levels
- Efficient state machine design
- Minimal bone count in rig
- Texture atlasing for UI elements