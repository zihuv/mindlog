# MindLog - Personal Journal and Reflection App

## Project Overview

MindLog is a Flutter-based personal journal and reflection application that allows users to create, manage, and organize their notes with features like tagging, checklists, and media attachments. The application uses GetX for state management and dependency injection, with a clean architecture that separates data, domain (business logic), and presentation layers.

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
- WebDAV sync for cloud storage

### Architecture
- **Presentation Layer**: UI screens and widgets located in the `presentation` directory
- **Business Layer**: Business logic services in `data/services` (NoteBusinessService, etc.)
- **Data Layer**: Models, repositories and services in `data` directory
- **Database Layer**: SQLite implementation using Drift in `data/database` directory
- **State Management**: GetX framework with dedicated controllers
- **Core Utilities**: Shared utilities in `core` directory
- **Design System**: Theme and design components in `core/design_system`

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
  - `lib/presentation/`: Presentation layer containing screens, widgets and controllers
    - `lib/presentation/controllers/`: GetX controllers for business logic
      - `lib/presentation/controllers/note_controller.dart`: Note management controller
      - `lib/presentation/controllers/notebook_controller.dart`: Notebook management controller
    - `lib/presentation/routes/`: GetX routing configuration
      - `lib/presentation/routes/app_pages.dart`: App pages configuration
      - `lib/presentation/routes/app_routes.dart`: App routes definition
    - `lib/presentation/views/`: UI screens organized by feature
      - `lib/presentation/views/home/`: Home screen components
      - `lib/presentation/views/note/`: Note-related screens
      - `lib/presentation/views/notebooks/`: Notebook screens
      - `lib/presentation/views/calendar/`: Calendar view components
      - `lib/presentation/views/settings/`: Settings screens
    - `lib/presentation/widgets/`: Reusable UI components
      - `lib/presentation/widgets/common/`: Common reusable widgets
      - `lib/presentation/widgets/note/`: Note-specific widgets
      - `lib/presentation/widgets/notebooks/`: Notebook-specific widgets
  - `lib/core/`: Core utilities and constants
    - `lib/core/design_system/`: Design system components and theme
  - `lib/data/`: Data layer with models, repositories and services
    - `lib/data/database/`: Database-specific code
      - `lib/data/database/app_database.dart`: Main database class
      - `lib/data/database/note_dao.dart`: Data access objects
    - `lib/data/models/`: Data models
      - `lib/data/models/note.dart`: Note model
      - `lib/data/models/notebook.dart`: Notebook model
    - `lib/data/repositories/`: Data repositories
      - `lib/data/repositories/note_database_repository.dart`: Note database operations
      - `lib/data/repositories/note_storage_repository.dart`: Note file storage operations
      - `lib/data/repositories/notebook_database_repository.dart`: Notebook database operations
      - `lib/data/repositories/notebook_storage_repository.dart`: Notebook file storage operations
    - `lib/data/services/`: Business services
      - `lib/data/services/note_service.dart`: Note CRUD operations
      - `lib/data/services/notebook_service.dart`: Notebook CRUD operations
      - `lib/data/services/note_business_service.dart`: Business logic layer
      - `lib/data/services/combined_note_service.dart`: High-level note service combining business logic and media operations
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
- Archive: Archive handling for import/export

## Project Status

The application uses a feature-based modular architecture with clean separation of concerns:
- Uses GetX for state management throughout the application
- Created NoteController and NotebookController for managing related states
- Organized code in a layered architecture (presentation, business, data)
- Implemented proper error handling and loading states
- Updated main.dart to use GetMaterialApp with dependency bindings
- Uses Drift for type-safe database access

## Checklist Feature

The application includes an interactive checklist feature:
- Users can create checklist items in notes using markdown syntax: `- [ ] task` or `- [x] task`
- Checklist items render as interactive checkboxes in the note list view
- Clicking checkboxes updates both the visual state and the underlying text content
- Changes to checklists also update the modification updateTime of notes
- The checklist state is properly preserved in the database

## Notebook Types

The application supports different types of notebooks:
- Standard notebooks: Traditional note-taking
- Checklist notebooks: For task management
- Timer notebooks: For time tracking (planned feature)

## Media Management

The application handles media attachments through:
- MediaUtil class for generating unique filenames
- Separate storage for images, videos, and audio files
- Proper cleanup of orphaned media files
- UUID-based naming to prevent conflicts

## Cloud Sync (WebDAV)

- WebDAV client for cloud synchronization
- Save note with cloud data preserved (ID, createTime, updateTime)
- Sync operations maintain data integrity across devices

## Design System

The application uses a unified design system with the following components:

### Design System Files
- `lib/core/design_system/app_colors.dart`: Theme colors for the application
- `lib/core/design_system/border_radius.dart`: Consistent border radius values
- `lib/core/design_system/box_shadow.dart`: Standard box shadow styles
- `lib/core/design_system/flex.dart`: Consistent flex layout values
- `lib/core/design_system/font_size.dart`: Typography scale for text sizes
- `lib/core/design_system/font_weight.dart`: Consistent font weights
- `lib/core/design_system/padding.dart`: Standard padding and margin values
- `lib/core/design_system/app_theme.dart`: Complete theme definition combining all design elements
- `lib/core/design_system/design_system.dart`: Export file to import all design system components

### Theme Usage
- The application uses AppTheme.lightTheme and AppTheme.darkTheme from app_theme.dart
- All UI components follow consistent design system values for colors, spacing, typography, and shapes
- The design system ensures visual consistency across all application screens

## Using Context7

Always use context7 when I need code generation, setup or configuration steps, or
library/API documentation. This means you should automatically use the Context7 MCP
tools to resolve library id and get library docs without me having to explicitly ask.