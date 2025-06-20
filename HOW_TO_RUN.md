# How to Run the Rive Playground

## Prerequisites

1. **Install Flutter**: If you haven't already, install Flutter from https://flutter.dev/docs/get-started/install
   - Make sure to follow all the setup steps for your operating system
   - Run `flutter doctor` to verify everything is installed correctly

2. **Install an IDE**: 
   - VS Code with Flutter extension (recommended for beginners)
   - Android Studio/IntelliJ with Flutter plugin
   - Or use command line

## Steps to Run

### 1. Open Terminal/Command Prompt

Navigate to the playground directory:
```bash
cd /Users/jos/Developer/Fenrir/rive_playground
```

### 2. Get Dependencies

Run this command to download all required packages:
```bash
flutter pub get
```

### 3. Run the App

#### Option A: Run on iOS Simulator (Mac only)
```bash
# Open iOS Simulator first
open -a Simulator

# Then run
flutter run
```

#### Option B: Run on Android Emulator
```bash
# Make sure Android emulator is running
# Then run
flutter run
```

#### Option C: Run on Physical Device
1. Connect your phone via USB
2. Enable Developer Mode on your phone
3. Run:
```bash
flutter run
```

#### Option D: Run on Web Browser
```bash
flutter run -d chrome
```

### 4. What You'll See

1. The app will launch with a welcome screen
2. Click "Simple Rive Demo" button
3. You'll see sliders to control:
   - Length (0.9 cm to 27.9 cm)
   - Girth (1.2 cm to 6.7 cm)
   - Toggle for showing measurements

## Adding Your Own Rive Animation

1. Create or download a `.riv` file
2. Place it in the `animations/` folder
3. Edit `lib/simple_rive_demo.dart`:
   - Find the `_buildPlaceholderAnimation()` method
   - Uncomment the RiveAnimation.asset code
   - Replace 'your_animation.riv' with your file name

## Troubleshooting

### "Flutter not found"
- Make sure Flutter is in your PATH
- Run: `export PATH="$PATH:[PATH_TO_FLUTTER]/flutter/bin"`

### "No devices found"
- Make sure you have a simulator/emulator running
- Or connect a physical device
- Run `flutter devices` to see available devices

### Build errors
- Run `flutter clean`
- Then `flutter pub get`
- Try running again

## Quick Commands Reference

```bash
# Check Flutter setup
flutter doctor

# List available devices
flutter devices

# Run with verbose output (for debugging)
flutter run -v

# Hot reload (while app is running)
r

# Hot restart (while app is running)
R

# Quit the app
q
```

## VS Code Quick Start

1. Open VS Code
2. File → Open Folder → Select `rive_playground`
3. Open `lib/main.dart`
4. Press F5 or click Run → Start Debugging
5. Select device when prompted

That's it! The app should now be running and you can interact with the demo.