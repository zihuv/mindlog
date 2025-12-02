# MindLog Build Configuration
# This file contains default settings for the build script

# Default output directories (on Desktop, single directory for both platforms)
DESKTOP_PATH="$HOME/Desktop"
OUTPUT_DIR="$DESKTOP_PATH/MindLog-Builds"
ANDROID_OUTPUT_DIR="$OUTPUT_DIR"
MACOS_OUTPUT_DIR="$OUTPUT_DIR"

# Default build mode (debug or release)
BUILD_MODE="release"

# Whether to install macOS app to Applications folder by default (true or false)
INSTALL_TO_APPS=false

# Default target platform (all, android, or macos)
TARGET_PLATFORM="all"

# Additional build arguments (if needed)
ANDROID_BUILD_ARGS="--split-per-abi"
MACOS_BUILD_ARGS=""