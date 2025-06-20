#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Flutter Playground Setup & Run Script${NC}"
echo "========================================"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Flutter is already installed
if [ -d "$HOME/development/flutter/bin" ] && [ -f "$HOME/development/flutter/bin/flutter" ]; then
    echo -e "${GREEN}✅ Flutter is already installed!${NC}"
    echo ""
else
    echo -e "${YELLOW}📥 Installing Flutter...${NC}"
    echo ""
    
    # Create development directory
    mkdir -p ~/development
    
    # Detect Mac architecture
    if [[ $(uname -m) == 'arm64' ]]; then
        FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.24.3-stable.zip"
        echo "Detected Apple Silicon Mac (M1/M2/M3)"
    else
        FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.3-stable.zip"
        echo "Detected Intel Mac"
    fi
    
    # Download Flutter
    echo "Downloading Flutter SDK..."
    cd ~/development
    curl -# -O $FLUTTER_URL
    
    # Extract Flutter
    echo "Extracting Flutter..."
    unzip -q flutter_macos_*.zip
    
    # Clean up zip file
    rm flutter_macos_*.zip
    
    echo -e "${GREEN}✅ Flutter installed successfully!${NC}"
    echo ""
fi

# Update PATH for current session
export PATH=$HOME/development/flutter/bin:$PATH
export PATH=$HOME/.gem/bin:$PATH

# Verify Flutter installation
echo -e "${BLUE}🔍 Verifying Flutter installation...${NC}"
flutter --version
echo ""

# Navigate to playground
cd /Users/jos/Developer/Fenrir/rive_playground

# Get Flutter dependencies
echo -e "${BLUE}📦 Getting Flutter dependencies...${NC}"
flutter pub get
echo ""

# Show available devices
echo -e "${BLUE}📱 Available devices:${NC}"
flutter devices
echo ""

# Ask user which device to use
echo -e "${YELLOW}How would you like to run the app?${NC}"
echo "1) Web Browser (Chrome) - Recommended for quick start"
echo "2) iOS Simulator"
echo "3) Android Emulator"
echo "4) List all devices and let me choose"
echo ""
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo -e "${GREEN}🌐 Launching in Chrome...${NC}"
        flutter run -d chrome
        ;;
    2)
        echo -e "${GREEN}📱 Opening iOS Simulator and launching app...${NC}"
        open -a Simulator
        sleep 5  # Give simulator time to start
        flutter run
        ;;
    3)
        echo -e "${GREEN}🤖 Launching on Android emulator...${NC}"
        flutter run
        ;;
    4)
        echo -e "${BLUE}Available devices:${NC}"
        flutter devices
        echo ""
        read -p "Enter device ID from the list above: " device_id
        flutter run -d "$device_id"
        ;;
    *)
        echo -e "${RED}Invalid choice. Launching in Chrome by default...${NC}"
        flutter run -d chrome
        ;;
esac

echo ""
echo -e "${GREEN}✨ Setup complete!${NC}"
echo ""
echo -e "${YELLOW}Hot Reload: Press 'r' while the app is running${NC}"
echo -e "${YELLOW}Hot Restart: Press 'R' while the app is running${NC}"
echo -e "${YELLOW}Quit: Press 'q' while the app is running${NC}"