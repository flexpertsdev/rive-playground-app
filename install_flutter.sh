#!/bin/bash

echo "🚀 Flutter Installation Helper"
echo "=============================="
echo ""

# Check if Flutter is already installed
if [ -d "$HOME/development/flutter" ]; then
    echo "✅ Flutter directory already exists at ~/development/flutter"
    echo "   Running flutter doctor to check installation..."
    $HOME/development/flutter/bin/flutter doctor
    exit 0
fi

echo "Flutter not found at ~/development/flutter"
echo ""
echo "📥 To install Flutter, follow these steps:"
echo ""
echo "1. Download Flutter SDK:"
echo "   For Apple Silicon (M1/M2/M3) Macs:"
echo "   curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.32.4-stable.zip"
echo ""
echo "   For Intel Macs:"
echo "   curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.32.4-stable.zip"
echo ""
echo "2. Extract to development folder:"
echo "   unzip flutter_macos_*_3.32.4-stable.zip -d ~/development/"
echo ""
echo "3. Reload your terminal configuration:"
echo "   source ~/.zshenv"
echo ""
echo "4. Verify installation:"
echo "   flutter doctor"
echo ""
echo "📌 Note: Your PATH is already configured in ~/.zshenv"