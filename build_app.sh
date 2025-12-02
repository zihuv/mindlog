#!/bin/bash

# MindLog Build Script
# This script builds the MindLog app for Android and macOS platforms
# Output files are placed on the desktop

set -e  # Exit immediately if a command exits with a non-zero status

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Default values - output to a single directory on Desktop
DESKTOP_PATH="$HOME/Desktop"
OUTPUT_DIR="$DESKTOP_PATH/MindLog-Builds"
ANDROID_OUTPUT_DIR="$OUTPUT_DIR"
MACOS_OUTPUT_DIR="$OUTPUT_DIR"
INSTALL_TO_APPS=false
BUILD_MODE="release"
TARGET_PLATFORM="all"  # all, android, macos

# Load configuration file if it exists
CONFIG_FILE="./build_config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -a, --android-output DIR    Output directory for Android APKs (default: ./build/android)"
    echo "  -m, --macos-output DIR      Output directory for macOS app (default: ./build/macos)"
    echo "  -i, --install-macos         Install macOS app to Applications folder and replace existing"
    echo "  -d, --debug                 Build in debug mode (default: release)"
    echo "  -p, --platform PLATFORM     Build platform: android, macos, or all (default: all)"
    echo "  -h, --help                  Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                          # Build Android and macOS apps with default settings"
    echo "  $0 --platform android       # Build only Android app"
    echo "  $0 --install-macos          # Build macOS app and install to Applications"
    echo "  $0 --debug                  # Build in debug mode"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--android-output)
            ANDROID_OUTPUT_DIR="$2"
            shift 2
            ;;
        -m|--macos-output)
            MACOS_OUTPUT_DIR="$2"
            shift 2
            ;;
        -i|--install-macos)
            INSTALL_TO_APPS=true
            shift
            ;;
        -d|--debug)
            BUILD_MODE="debug"
            shift
            ;;
        -p|--platform)
            TARGET_PLATFORM="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate platform parameter
if [[ "$TARGET_PLATFORM" != "all" && "$TARGET_PLATFORM" != "android" && "$TARGET_PLATFORM" != "macos" ]]; then
    print_error "Invalid platform: $TARGET_PLATFORM. Use 'android', 'macos', or 'all'."
    exit 1
fi

# Check if flutter is available
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_info "Starting build process for MindLog app"
print_info "Build mode: $BUILD_MODE"
print_info "Target platform: $TARGET_PLATFORM"

# Function to build Android APK
build_android() {
    print_info "Building Android app ($BUILD_MODE)..."

    # Create output directory if it doesn't exist
    mkdir -p "$ANDROID_OUTPUT_DIR"

    # Build Android app with split per ABI
    if [[ "$BUILD_MODE" == "debug" ]]; then
        flutter build apk --debug
    else
        flutter build apk --release --split-per-abi
    fi

    # Copy APKs to the specified output directory
    if [[ "$BUILD_MODE" == "debug" ]]; then
        if [[ -f "build/app/outputs/flutter-apk/app-debug.apk" ]]; then
            cp "build/app/outputs/flutter-apk/app-debug.apk" "$ANDROID_OUTPUT_DIR/mindlog-debug.apk"
            print_success "Debug APK copied to $ANDROID_OUTPUT_DIR/mindlog-debug.apk"
        else
            print_error "Debug APK not found"
            return 1
        fi
    else
        # Copy only the arm64-v8a APK for release with mindlog name
        if [[ -f "build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" ]]; then
            cp "build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" "$ANDROID_OUTPUT_DIR/mindlog.apk"
            print_success "Release APK (arm64-v8a) copied to $ANDROID_OUTPUT_DIR/mindlog.apk"
        else
            print_error "Release APK (arm64-v8a) not found"
            return 1
        fi
    fi
}

# Function to build macOS app
build_macos() {
    print_info "Building macOS app ($BUILD_MODE)..."

    # Create output directory if it doesn't exist
    mkdir -p "$MACOS_OUTPUT_DIR"

    # Build macOS app
    if [[ "$BUILD_MODE" == "debug" ]]; then
        flutter build macos --debug
    else
        flutter build macos --release
    fi

    # Find the built app bundle
    if [[ "$BUILD_MODE" == "debug" ]]; then
        APP_BUNDLE="build/macos/Build/Products/Debug/mindlog.app"
    else
        APP_BUNDLE="build/macos/Build/Products/Release/mindlog.app"
    fi

    if [[ -d "$APP_BUNDLE" ]]; then
        # Copy the app bundle to output directory with mindlog name
        if [[ "$BUILD_MODE" == "debug" ]]; then
            APP_NAME="mindlog-debug.app"
        else
            APP_NAME="mindlog.app"
        fi
        cp -R "$APP_BUNDLE" "$MACOS_OUTPUT_DIR/$APP_NAME"
        print_success "macOS app copied to $MACOS_OUTPUT_DIR/$APP_NAME"

        # Optionally install to Applications folder
        if [[ "$INSTALL_TO_APPS" == true ]]; then
            install_macos_to_apps
        fi
    else
        print_error "macOS app bundle not found at $APP_BUNDLE"
        return 1
    fi
}

# Function to install macOS app to Applications folder
install_macos_to_apps() {
    print_info "Installing macOS app to Applications folder..."

    # Define source and destination paths
    # Use the release app even if debug build was requested for installation
    if [[ "$BUILD_MODE" == "debug" ]]; then
        SOURCE_APP="$MACOS_OUTPUT_DIR/mindlog.app"
    else
        SOURCE_APP="$MACOS_OUTPUT_DIR/mindlog.app"
    fi
    DEST_APP="/Applications/mindlog.app"

    # Check if the app is currently running
    if pgrep -f "mindlog.app" > /dev/null; then
        print_warning "MindLog is currently running. Please quit the app before continuing."
        read -p "Press Enter to continue after quitting the app..."
    fi

    # Remove existing app if it exists
    if [[ -d "$DEST_APP" ]]; then
        print_info "Removing existing app from Applications folder..."
        rm -rf "$DEST_APP"
        if [[ $? -eq 0 ]]; then
            print_success "Old app removed from Applications folder"
        else
            print_error "Failed to remove old app from Applications folder"
            return 1
        fi
    fi

    # Copy new app to Applications folder
    sudo cp -R "$SOURCE_APP" "$DEST_APP"
    if [[ $? -eq 0 ]]; then
        print_success "App installed to Applications folder"
    else
        print_error "Failed to install app to Applications folder"
        return 1
    fi

    # Set appropriate permissions
    sudo chown -R "$USER:staff" "$DEST_APP"
    if [[ $? -eq 0 ]]; then
        print_success "Permissions set for app in Applications folder"
    else
        print_error "Failed to set permissions for app in Applications folder"
    fi
}

# Main build logic
if [[ "$TARGET_PLATFORM" == "all" || "$TARGET_PLATFORM" == "android" ]]; then
    build_android
fi

if [[ "$TARGET_PLATFORM" == "all" || "$TARGET_PLATFORM" == "macos" ]]; then
    build_macos
fi

print_success "Build process completed!"
print_info "Android output: $ANDROID_OUTPUT_DIR"
print_info "macOS output: $MACOS_OUTPUT_DIR"
if [[ "$INSTALL_TO_APPS" == true ]]; then
    print_info "macOS app installed to Applications folder"
fi
