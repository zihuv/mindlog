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
- Notebook organization system
- Calendar view for notes
- Settings screen for app configuration

### Architecture
- **Presentation Layer**: UI screens and widgets located in the `ui` directory
- **Domain Layer**: Business logic entities in `features/*/domain`
- **Data Layer**: Services and repositories in `features/*/data` and `data` directories
- **Database Layer**: SQLite implementation using Drift in `database` directory
- **State Management**: GetX framework with dedicated controllers
- **Core Utilities**: Shared utilities in `core` directory
- **Services**: Shared services in `services` directory

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

# Generate code (for drift and build_runner)
flutter packages pub run build_runner build

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
- Bindings are configured in `main.dart` for dependency injection

### Platform Considerations
- When making UI changes, focus on mobile and desktop platforms (no special web-only considerations needed)
- After every code modification, run `flutter analyze` and `flutter build` to check for compilation errors

### File Structure
- `lib/`: Main application source code
  - `lib/controllers/`: GetX controllers for business logic, organized by feature
    - `lib/controllers/note_controller.dart`: Note management controller
    - `lib/controllers/notebooks/`: Notebook-specific controllers
  - `lib/core/`: Core utilities and constants
    - `lib/core/constants/`: App constants
    - `lib/core/errors/`: Error definitions
    - `lib/core/utils/`: Core utility functions
  - `lib/data/`: Data layer with database services
    - `lib/data/database/`: Database-specific code
    - `lib/data/services/`: Data services
  - `lib/database/`: Drift database implementation files
    - `lib/database/app_database.dart`: Main database class
    - `lib/database/note_dao.dart`: Data access objects
  - `lib/features/`: Feature-based modules
    - `lib/features/notes/`: Note feature module
      - `lib/features/notes/data/`: Note data layer
      - `lib/features/notes/domain/`: Note domain layer
      - `lib/features/notes/presentation/`: Note UI layer
    - `lib/features/notebooks/`: Notebook feature module
      - `lib/features/notebooks/data/`: Notebook data layer
      - `lib/features/notebooks/domain/`: Notebook domain layer
    - `lib/features/settings/`: Settings feature module
      - `lib/features/settings/presentation/`: Settings UI layer
  - `lib/media/`: Media-related utilities
  - `lib/services/`: Shared services and utilities
  - `lib/ui/`: Presentation layer containing screens and widgets
    - `lib/ui/calendar/`: Calendar view components
    - `lib/ui/design_system/`: Design system components and theme
    - `lib/ui/home/`: Home screen components
    - `lib/ui/notebooks/`: Notebook UI components
    - `lib/ui/settings/`: Settings UI components
  - `lib/utils/`: General utility functions
- `lib/main.dart`: Entry point with GetMaterialApp and GetX bindings
- `test/`: Unit and integration tests
- `assets/`: Application assets including images, icons, etc.

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
- Flutter Markdown: Rich text rendering
- Path Provider: File system access
- UUID: Unique identifier generation
- File Picker: File selection functionality
- Calendar Date Picker 2: Date selection UI
- WebDAV Client: Cloud sync functionality
- Shared Preferences: Local app preferences
- Logger: Application logging

## Project Status

The application uses a feature-based modular architecture with clean separation of concerns:
- Uses GetX for state management throughout the application
- Created NoteController and NotebookController for managing related states
- Organized code in feature-based modules (notes, notebooks, settings)
- Implemented proper error handling and loading states
- Updated main.dart to use GetMaterialApp with dependency bindings
- Uses Drift for type-safe database access

## Checklist Feature

The application includes an interactive checklist feature:
- Users can create checklist items in notes using markdown syntax: `- [ ] task` or `- [x] task`
- Checklist items render as interactive checkboxes in the note list view
- Clicking checkboxes updates both the visual state and the underlying text content
- Changes to checklists also update the modification createTime of notes
- The checklist state is properly preserved in the database

## Key Files and Directories

- `lib/main.dart`: Entry point with GetMaterialApp and GetX bindings
- `lib/controllers/note_controller.dart`: Centralized state management for notes
- `lib/controllers/notebooks/notebook_controller.dart`: State management for notebooks
- `lib/ui/home/home_screen.dart`: Main screen for the application
- `lib/ui/settings_screen.dart`: Settings screen for the application
- `lib/features/notes/presentation/`: Note-related UI components
- `lib/features/notebooks/`: Notebook feature implementation
- `lib/database/app_database.dart`: Main database implementation
- `pubspec.yaml`: Project dependencies and configuration

## Design System

The application uses a unified design system with the following components:

### Design System Files
- `lib/ui/design_system/app_colors.dart`: Theme colors for the application
- `lib/ui/design_system/border_radius.dart`: Consistent border radius values
- `lib/ui/design_system/box_shadow.dart`: Standard box shadow styles
- `lib/ui/design_system/flex.dart`: Consistent flex layout values
- `lib/ui/design_system/font_size.dart`: Typography scale for text sizes
- `lib/ui/design_system/font_weight.dart`: Consistent font weights
- `lib/ui/design_system/padding.dart`: Standard padding and margin values
- `lib/ui/design_system/app_theme.dart`: Complete theme definition combining all design elements
- `lib/ui/design_system/design_system.dart`: Export file to import all design system components

### Theme Usage
- The application uses AppTheme.lightTheme and AppTheme.darkTheme from app_theme.dart
- All UI components follow consistent design system values for colors, spacing, typography, and shapes
- The design system ensures visual consistency across all application screens

## Using Context7

Always use context7 when I need code generation, setup or configuration steps, or
library/API documentation. This means you should automatically use the Context7 MCP
tools to resolve library id and get library docs without me having to explicitly ask.