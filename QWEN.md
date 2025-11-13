# MindLog - Personal Journal and Reflection App

## Project Overview

MindLog is a Flutter-based personal journal and reflection application that allows users to create, manage, and organize their notes with features like tagging, checklists, and media attachments. The application uses GetX for state management and dependency injection, with a clean architecture that separates data, domain, and presentation layers.

### Key Features
- Create and edit notes with rich text content
- Tagging system for organizing notes
- Interactive checklists within notes
- Media attachment support (images, videos, audio)
- Search functionality for notes
- Local database storage using Drift (SQLite)

### Architecture
- **Presentation Layer**: UI screens and widgets located in the `ui` directory
- **Domain Layer**: Business logic entities in `features/memos/domain`
- **Data Layer**: Services and repositories in `data` directory
- **Database Layer**: SQLite implementation using Drift in `database` directory
- **State Management**: GetX framework with dedicated controllers

## Building and Running

### Prerequisites
- Flutter SDK
- Dart SDK

### Setup and Installation
1. Clone the repository
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Run the application with `flutter run`

### Key Commands
```bash
# Install dependencies
flutter pub get

# Run the application
flutter run

# Run tests
flutter test

# Build for Android
flutter build apk

# Build for iOS
flutter build ios

# Analyze code
flutter analyze

# Format code
flutter format .
```

## Development Conventions

### State Management
- Uses GetX for state management with reactive programming
- Controllers inherit from GetxController
- Reactive variables use `.obs` property
- Views use `Obx()` or `GetBuilder` for state updates

### Platform Considerations
- When making UI changes, focus on mobile and desktop platforms (no special web-only considerations needed)
- After every code modification, run `flutter analyze` and `flutter build` to check for compilation errors

### File Structure
- `lib/ui/`: Presentation layer containing screens and widgets
- `lib/controllers/`: GetX controllers for business logic
- `lib/data/`: Data layer with services and repositories
- `lib/features/`: Domain layer with business entities
- `lib/database/`: Database implementation using Drift
- `lib/providers/` (deprecated): Old Provider-based state management (removed)

### Testing
- Unit tests located in `test/` directory
- Follows Flutter's standard testing practices
- Uses GetX-specific testing utilities where applicable

## Key Dependencies

- Flutter SDK
- GetX: State management, dependency injection, and navigation
- Drift: Type-safe database access
- SQLite3: Local data storage
- Image Picker: Media attachment functionality
- Equatable: Value-based object comparison
- Intl: Internationalization support

## Project Status

The application has been migrated from Provider to GetX for state management. The migration includes:
- Replaced Provider with GetX throughout the application
- Created NoteController for managing note-related state
- Updated UI screens to use GetX reactive programming
- Implemented proper error handling and loading states
- Updated main.dart to use GetMaterialApp and bindings
- Removed the providers directory and provider dependency

## Checklist Feature

The application includes an interactive checklist feature:
- Users can create checklist items in notes using markdown syntax: `- [ ] task` or `- [x] task`
- Checklist items render as interactive checkboxes in the note list view
- Clicking checkboxes updates both the visual state and the underlying text content
- Changes to checklists also update the modification time of notes
- The checklist state is properly preserved in the database

## Key Files and Directories

- `lib/main.dart`: Entry point with GetMaterialApp and GetX bindings
- `lib/controllers/note_controller.dart`: Centralized state management for notes
- `lib/ui/note_list_screen.dart`: Main screen for viewing and managing notes
- `lib/ui/note_detail_screen.dart`: Screen for creating and editing individual notes
- `lib/data/services/combined_note_service.dart`: Data service layer
- `pubspec.yaml`: Project dependencies and configuration