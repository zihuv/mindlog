# MindLog

MindLog is a simple note-taking app with markdown support and tag functionality built with Flutter.

## Features

- Create, edit, and delete notes
- Markdown support with checkboxes
- Filter notes by tags using the tag filter bar
- Pin important notes
- Privacy settings for notes


## Building

### Automated Build Process

For convenience, we provide a build script that can handle building for both Android and macOS. The output files will be placed in a single directory on your desktop (`~/Desktop/MindLog-Builds/`):

```bash
# Show help for the build script
./build_app.sh --help

# Build both Android and macOS apps (output to desktop)
./build_app.sh

# Build only Android app
./build_app.sh --platform android

# Build macOS app and install to Applications folder
./build_app.sh --install-macos

# Build in debug mode
./build_app.sh --debug
```

See `BUILD.md` for full documentation of the build script.

### Manual Building

If you prefer to build manually:

For Android:
```bash
flutter build apk --split-per-abi
```
Use: app-arm64-v8a-release.apk

For macOS:
```bash
flutter build macos
```