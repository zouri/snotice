# AGENTS.md

This file provides guidance for agentic coding assistants working in this Flutter/Dart repository.

## Build, Lint, and Test Commands

```bash
# Install dependencies
flutter pub get

# Code analysis (lint)
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/file_name_test.dart

# Run on specific platform
flutter run -d macos
flutter run -d linux
flutter run -d windows

# Build for release
flutter build macos --release
flutter build linux --release
flutter build windows --release
```

## Code Style Guidelines

### Imports
- Organize imports: package imports first, then relative imports using `../` prefix
- Separate groups with blank lines: Flutter/external packages, then internal imports
- Example:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../models/app_config.dart';
  import '../services/logger_service.dart';
  ```

### Naming Conventions
- **Classes**: PascalCase (e.g., `NotificationService`, `AppConfig`)
- **Variables/Methods**: camelCase (e.g., `port`, `allowedIPs`, `startServer()`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `defaultPort`, `appName`)
- **Private members**: Prefix with underscore `_` (e.g., `_logger`, `_config`)

### Formatting
- Use 2-space indentation
- Trailing commas in multi-line lists/function arguments
- Wrap long lines at 80 characters
- Use const constructors where possible

### Type Annotations
- Always annotate class fields with explicit types
- Annotate method parameters and return types (except simple cases)
- Use nullable types (`Type?`) appropriately
- Use `as Type?` for safe casting with null fallbacks

### Error Handling
- Wrap I/O operations in try-catch blocks
- Log errors using `logger.error()` method
- Rethrow exceptions when appropriate using `rethrow`
- Return early for error conditions in handlers
- Use `ResponseUtil` for HTTP error responses (see `lib/utils/response_util.dart`)

### Models and Serialization
- Implement `fromJson()` factory constructor for deserialization
- Implement `toJson()` method for serialization
- Implement `copyWith()` method for immutable updates
- Use nullable types with `??` operator for default values
- Example:
  ```dart
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      port: json['port'] as int? ?? 8080,
      allowedIPs: (json['allowedIPs'] as List<dynamic>?)
          ?.map((e) => e as String).toList() ?? [],
    );
  }
  ```

### Services
- Use dependency injection via constructor parameters
- Store dependencies as private final fields
- Use getter methods for computed properties
- Provide public APIs only for necessary operations
- Initialize async operations in `main()` before `runApp()`

### State Management (Provider)
- Extend `ChangeNotifier` for state providers
- Call `notifyListeners()` after state changes
- Use `Consumer<N>` widgets in UI for rebuilding
- Use `Provider.of<ProviderType>(context, listen: false)` for read-only access
- Use `context.mounted` check before showing dialogs/snackbars after async ops

### UI Components
- Extend `StatelessWidget` for static widgets, `StatefulWidget` for dynamic
- Use `const` constructors where possible
- Use `ScaffoldMessenger` for showing snacks and alerts
- Use `Navigator` for page transitions with `MaterialPageRoute`
- Use `Card`, `ListTile`, `ElevatedButton` from Material Design
- Use `SizedBox` for spacing

### Async/Await
- Mark async methods with `Future<T>` return type
- Use `await` for all async operations
- Initialize async resources in `main()` before UI starts
- Use `WidgetsFlutterBinding.ensureInitialized()` for plugin init

### HTTP API
- Use `shelf` and `shelf_router` for server implementation
- Use middleware for cross-cutting concerns (CORS, auth)
- Return consistent JSON responses using `ResponseUtil`
- Log all requests using `logger.request()` method
- Validate input using model validation methods

### Project Structure
- `lib/config/` - Configuration constants
- `lib/models/` - Data models with serialization
- `lib/services/` - Business logic and external integrations
- `lib/providers/` - State management (Provider pattern)
- `lib/ui/` - UI screens and widgets
- `lib/utils/` - Utility functions and helpers

### Testing
- Write unit tests in `test/` directory (not yet created)
- Use `flutter_test` framework
- Mock dependencies using `mockito`
- Test file naming: `filename_test.dart`

### Linting
- Follow `flutter_lints` rules (see `analysis_options.yaml`)
- Run `flutter analyze` before committing
- Fix all analyzer warnings and errors
