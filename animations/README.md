# Rive Animation Files

Place your `.riv` animation files in this directory.

## How to add your Rive animations:

1. Export your Rive animation as a `.riv` file from the Rive editor
2. Copy the file to this `animations/` directory
3. Update the code in `lib/simple_rive_demo.dart`:
   - Replace the placeholder animation with:
   ```dart
   return RiveAnimation.asset(
     'animations/your_animation.riv',
     fit: BoxFit.contain,
     onInit: _onRiveInit,
   );
   ```

## Example Rive animations you can use:

You can download free animations from:
- https://rive.app/community/
- https://rive.app/examples/

Or create your own using the Rive editor:
- https://rive.app/