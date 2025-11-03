# MOSA - Money Saving Application

## Project Overview
MOSA is a Flutter-based mobile application for tracking personal finances. Key characteristics:
- Material Design 3 with custom theming
- State management using Provider pattern
- Local SQLite database for persistence
- GoRouter for navigation

## Architecture & Components

### Data Layer
- Models are in `lib/models/` - see `transaction.dart` for the pattern
- SQLite database managed through `DatabaseService` in `lib/services/database_service.dart`
- Data access follows Repository pattern via Provider classes in `lib/providers/`

### UI Layer
- Screens organized by feature in `lib/screens/`
- Reusable widgets in `lib/widgets/`
- Navigation routes defined in `lib/router/app_router.dart`
- Consistent styling using `lib/utils/app_colors.dart`

## Key Patterns

### State Management
- Use `Provider` for app-wide state management
- Example: `TransactionProvider` manages transaction CRUD operations
- Local screen state should use `StatefulWidget`

### Database Operations
- All database access through `DatabaseService` singleton
- Tables and schema defined in `lib/utils/constants.dart`
- Transaction operations:
  ```dart
  // Example: Get transactions
  final db = DatabaseService();
  final transactions = await db.getTransactions();
  ```

### Navigation
- Route definitions in `lib/router/app_routes.dart`
- Use `context.go()` for navigation
- Route parameters passed through GoRouter

## Development Workflow

### Setup
1. Install Flutter SDK and dependencies:
   ```
   flutter pub get
   ```
2. Run the app:
   ```
   flutter run
   ```

### Common Tasks
- Database migrations should update `AppConstants.dbVersion`
- New screens need corresponding route entries
- Provider updates must notify listeners via `notifyListeners()`

## Testing
- Widget tests in `test/widget_test.dart`
- Test data utilities in `lib/utils/test_data.dart`