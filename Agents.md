# AI Rules for Flutter - MOSA Project

## Persona & Tools
* **Role:** Senior Flutter Developer. Focus: Beautiful, performant, maintainable code.
* **Explanation:** Explain Dart features (null safety, streams, futures) for new users.
* **Tools:** ALWAYS run `dart format`. Use `dart fix` for cleanups. Use `flutter analyze` with `flutter_lints` to catch errors early.
* **Dependencies:** Add with `flutter pub add`. Use `pub dev search` for discovery. Explain why a package is needed.

## Architecture & Structure
* **Entry:** Standard `lib/main.dart`.
* **Layers:** Presentation (Widgets), Domain (Logic), Data (Repo/API).
* **Features:** Group by feature (e.g., `lib/features/login/`) for scalable apps.
* **SOLID:** Strictly enforced.
* **State Management:**
  * **Pattern:** Separate UI state (ephemeral) from App state.
  * **Native First:** Use `ValueNotifier`, `ChangeNotifier`.
  * **THIS PROJECT USES:** Riverpod (flutter_riverpod) + Provider - These are explicitly allowed for this project.
  * **DI:** Manual constructor injection or `provider` package.

## Code Style & Quality
* **Naming:** `PascalCase` (Types), `camelCase` (Members), `snake_case` (Files).
* **Conciseness:** Functions <20 lines. Avoid verbosity.
* **Null Safety:** NO `!` operator. Use `?` and flow analysis (e.g. `if (x != null)`).
* **Async:** Use `async/await` for Futures. Catch all errors with `try-catch`.
* **Logging:** Use `dart:developer` `log()` locally. NEVER use `print`.

## Flutter Best Practices
* **Build Methods:** Keep pure and fast. No side effects. No network calls.
* **Isolates:** Use `compute()` for heavy tasks like JSON parsing.
* **Lists:** `ListView.builder` or `SliverList` for performance.
* **Immutability:** `const` constructors everywhere possible. `StatelessWidget` preference.
* **Composition:** Break complex builds into private `class MyWidget extends StatelessWidget`.
* **Notifications & Feedback:** - NEVER use `ScaffoldMessenger.of(context).showSnackBar()`.
    - ALWAYS use the custom toast utility from `lib/utils/toast.dart` for all user notifications (success, error, or info messages).
    - Ensure the appropriate toast type is used to maintain UI consistency across the MOSA project.

### Documentation & Localization
- **Language:** All code comments, documentation, and commit messages MUST be in **Vietnamese**.
- **User Interface:** UI Strings (labels, hints) should be centralized for future localization (l10n).

### Financial Data Handling
- **Models:** Store currency values as `double`.
- **Formatting:** Use the `intl` package to format numbers and currency based on user locale.
- **Safety:** Always provide default values (e.g., `0.0`) for financial fields in `fromMap`.

### Best Practices for MOSA
- **Icons:** Prefer `Material Icons` or `FontAwesome`.
- **Spans:** Use `RichText` or `Text.rich` for mixed style amounts (e.g., different color for negative balance).
- **Navigation:** Use named routes via `GoRouter` for all screen transitions.

### Enum Implementation Rules
- **Documentation:** Mọi giá trị Enum phải có doc comment `///` bằng tiếng Việt.
- **Safe Conversion:** Luôn có hàm static `fromId` hoặc `fromString` để xử lý dữ liệu từ Database.
- **Default Fallback:** Nếu dữ liệu từ DB không khớp, phải trả về một giá trị mặc định (ví dụ: `.unknown` hoặc `.active`) thay vì để crash.

#### Example
```dart
enum DebtStatus {
  /// Nợ mới tạo hoặc chưa thanh toán
  active,
  /// Đã trả một phần
  partial,
  /// Đã thanh toán xong hoàn toàn
  paid,
  /// Trạng thái không xác định (dùng để bắt lỗi DB)
  unknown;

  /// Chuyển từ String trong Database sang Enum
  static DebtStatus fromString(String? value) {
    return DebtStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DebtStatus.unknown,
    );
  }
}

## Routing (GoRouter)
Use `go_router` exclusively for deep linking and web support.

```dart
final _router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => Home()),
  GoRoute(path: 'details/:id', builder: (_, s) => Detail(id: s.pathParameters['id']!)),
]);
MaterialApp.router(routerConfig: _router);
```

## Data (JSON)
Use `json_serializable` with `fieldRename: FieldRename.snake` for complex models.

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final String name;
  User({required this.name});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

## Visual Design (Material 3)
* **Aesthetics:** Premium, custom look. "Wow" the user. Avoid default blue.
* **Theme:** Use `ThemeData` with `ColorScheme.fromSeed`.
* **Modes:** Support Light & Dark modes (`ThemeMode.system`).
* **Typography:** `google_fonts`. Define a consistent Type Scale.
* **Layout:** `LayoutBuilder` for responsiveness. `OverlayPortal` for popups.
* **Components:** Use `ThemeExtension` for custom tokens (colors/sizes).

## Testing
* **Tools:** `flutter test` (Unit), `flutter_test` (Widget), `integration_test` (E2E).
* **Mocks:** Prefer Fakes. Use `mockito` sparingly.
* **Pattern:** Arrange-Act-Assert.
* **Assertions:** Use `package:checks`.

## Accessibility (A11Y)
* **Contrast:** 4.5:1 minimum for text.
* **Semantics:** Label all interactive elements specifically.
* **Scale:** Test dynamic font sizes (up to 200%).
* **Screen Readers:** Verify with TalkBack/VoiceOver.

---

# MOSA Project Specific Rules

## UI & Component Rules (MOSA Specific)
* **Main Layout:** ALWAYS use the custom `CommonScaffold` widget (located in `lib/widgets/common_scaffold.dart`) for all new screens. 
    - DO NOT use the default Flutter `Scaffold` unless there is a specific technical reason.
    - `CommonScaffold` provides consistent padding, app bars, and background colors for the MOSA project.
* **Reuse:** Check `lib/widgets/` for existing common widgets before creating new UI components to ensure visual consistency.

## Project Overview
- **Name:** MOSA - Money Saving Application
- **Type:** Flutter mobile app for personal finance tracking
- **Database:** SQLite via sqflite package
- **Navigation:** GoRouter

## Build Commands

### Build APK
```bash
flutter build apk --debug      # Debug APK
flutter build apk --release   # Release APK
```

### Build iOS (macOS only)
```bash
flutter build ios --release
```

### Build Web
```bash
flutter build web
```

## Lint & Analysis Commands

### Run Analyzer
```bash
flutter analyze               # Run full analyzer
flutter analyze --fix         # Auto-fix issues
dart format .                 # Format entire project
dart format <file.dart>       # Format specific file
```

## Test Commands

### Run All Tests
```bash
flutter test                  # Run all tests
flutter test .               # Alternative (current directory)
```

### Run Single Test File
```bash
flutter test test/widget_test.dart
flutter test path/to/test_file.dart
```

### Run Tests by Pattern
```bash
flutter test --name "test_name_pattern"
flutter test --name "Transaction"


```

### Run Tests in Directory
```bash
flutter test test/unit/
flutter test test/widget/
```

### Coverage
```bash
flutter test --coverage
```

---

## Code Style Guidelines (MOSA Specific)

### Imports
- Use absolute imports: `package:mosa/...`
- Order: dart -> flutter -> external packages -> internal packages
- Use `show`/`hide` for selective imports

```dart
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import 'package:mosa/models/transaction.dart';
import 'package:mosa/providers/transaction_provider.dart';
```

### File Naming
- **Files:** `snake_case.dart` (e.g., `transaction_service.dart`, `debt_provider.dart`)
- **Enums:** `PascalCase` with values in `camelCase` (e.g., `DebtType.lent`, `DebtStatus.paid`)

### State Management - Riverpod Pattern

#### AsyncNotifier Pattern (for CRUD operations)
```dart
class DebtNotifier extends AsyncNotifier<List<Debt>> {
  DatabaseService get _databaseService => ref.read(databaseServiceProvider);

  @override
  Future<List<Debt>> build() async {
    return await _databaseService.getAllDebt();
  }

  Future<void> createDebt(Debt debt) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final id = await _databaseService.createDebt(debt);
      final newDebt = debt.copyWith(id: id);
      return [newDebt, ...state.requireValue];
    });
  }
}

final debtProvider = AsyncNotifierProvider<DebtNotifier, List<Debt>>(DebtNotifier.new);
```

#### Provider for filtered data
```dart
final debtByPersonProvider = Provider.family<List<Debt>, int>((ref, personId) {
  final debts = ref.watch(debtProvider).value ?? [];
  return debts.where((debt) => debt.personId == personId).toList();
});

final totalDebtProvider = Provider<Map<String, double>>((ref) {
  final debts = ref.watch(debtProvider).value ?? [];
  // Calculate totals
  return {'lent': totalLent, 'borrowed': totalBorrowed};
});
```

#### ChangeNotifier Pattern (Provider)
```dart
class WalletProvider extends ChangeNotifier {
  List<Wallet> _wallets = [];
  
  Future<void> loadWallets() async {
    _wallets = await databaseService.getWallets();
    notifyListeners();
  }
}
```

### Model Patterns

#### With copyWith, fromMap, toMap
```dart
class Debt {
  final int? id;
  final int personId;
  final double amount;
  final double paidAmount;
  final DebtType type;
  final DebtStatus status;

  Debt({
    this.id,
    required this.personId,
    required this.amount,
    this.paidAmount = 0,
    required this.type,
    required this.status,
  });

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] as int?,
      personId: map['personId'] as int,
      amount: (map['amount'] as num).toDouble(),
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? 0,
      type: DebtType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      status: DebtStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'personId': personId,
    'amount': amount,
    'paidAmount': paidAmount,
    'type': type.toString().split('.').last,
    'status': status.toString().split('.').last,
  };

  Debt copyWith({int? id, double? paidAmount, DebtStatus? status}) {
    return Debt(
      id: id ?? this.id,
      personId: personId,
      amount: amount,
      paidAmount: paidAmount ?? this.paidAmount,
      type: type,
      status: status ?? this.status,
    );
  }
}
```

### Error Handling
```dart
try {
  final result = await databaseService.getAllDebt();
} catch (e, stackTrace) {
  log('Error loading debts: $e', name: 'debt_provider');
  state = AsyncError(e, stackTrace);
  rethrow;
}
```

---

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── transaction.dart
│   ├── debt.dart
│   ├── person.dart
│   ├── category.dart
│   ├── wallets.dart
│   └── enums.dart
├── providers/               # State management
│   ├── transaction_provider.dart
│   ├── debt_provider.dart
│   ├── person_provider.dart
│   ├── wallet_provider.dart
│   └── ...
├── services/                # Business logic & database
│   ├── database_service.dart
│   ├── transaction_service.dart
│   └── ...
├── screens/                 # Page widgets by feature
│   ├── home/
│   ├── transaction/
│   ├── wallet/
│   ├── debt/
│   └── ...
├── widgets/                 # Reusable UI components
├── router/                  # GoRouter configuration
├── config/                  # App configuration
├── data/                    # Static data (icons, categories)
└── utils/                   # Constants, helpers, extensions
    ├── constants.dart       # Database schema, table names
    ├── app_colors.dart
    └── ...
```

---

## Database Schema

- Tables defined in `lib/utils/constants.dart`
- Database version: Check `AppConstants.dbVersion`
- **IMPORTANT:** Update version when making schema changes
- Access through `DatabaseService` singleton

### Debt/Person Management Features
- **Debt:** Tracks lent/borrowed money with status tracking
- **Person:** People involved in debt transactions
- Debt types: `DebtType.lent` (cho vay), `DebtType.borrowed` (đi vay)
- Debt status: `DebtStatus.active`, `DebtStatus.partial`, `DebtStatus.paid`

---

## Development Workflow

1. Database migrations MUST update `AppConstants.dbVersion`
2. New screens need corresponding route entries in `lib/router/`
3. Riverpod providers: use `ref.read()` for one-time reads, `ref.watch()` for reactive
4. Provider updates must call `notifyListeners()`

---

## Commands Reference Summary

| Command | Description |
|---------|-------------|
| `flutter build apk --debug` | Build debug APK |
| `flutter build apk --release` | Build release APK |
| `flutter analyze` | Run analyzer |
| `flutter analyze --fix` | Auto-fix issues |
| `dart format .` | Format code |
| `flutter test` | Run all tests |
| `flutter test test/file.dart` | Run single test file |
| `flutter test --name "pattern"` | Run tests by pattern |
| `dart run build_runner build --delete-conflicting-outputs` | Build runner for code gen |

---

## Progress Log & Established Patterns

Phần này ghi lại các tính năng đã hoàn thiện và các quy tắc/mẫu code mới được thiết lập trong quá trình phát triển.

### ✅ Các Tính Năng Đã Hoàn Thiện

| Tính năng | Mô tả | Files liên quan |
|-----------|-------|-----------------|
| **Chuyển đổi Giao diện (Theme Switching)** | Light/Dark/System mode với persistence qua `SharedPreferences` | `lib/config/app_theme.dart`, `lib/providers/theme_provider.dart`, `lib/screens/setting/setting_screen.dart` |
| **Push Notifications (Local + FCM)** | Nhắc nhở nợ đến hạn, cảnh báo ngân sách, thông báo thanh toán | `lib/utils/notification_helper.dart`, `lib/services/fcm_service.dart`, `lib/providers/fcm_provider.dart` |
| **Debt Timeline (Lịch sử nợ)** | Timeline tổng hợp theo người, gộp Debt khởi tạo + các giao dịch thanh toán/thu nợ | `lib/providers/debt_history_provider.dart` |
| **Refactoring Provider tên** | Đổi tên `currentTransactionByTypeProvider` → `activeTransactionTypeProvider` | `lib/providers/transaction_provider.dart` |
| **Category Navigation** | Refactor dùng `activeTransactionTypeProvider` thay vì query param để xác định tab hiển thị | `lib/screens/category/` |
| **Debt Provider CRUD** | Đầy đủ create/update/delete với cập nhật UI tức thì, bao gồm tích hợp notification | `lib/providers/debt_provider.dart` |
| **Build Fix: desugar_jdk_libs** | Nâng cấp `desugar_jdk_libs` lên 2.1.4 để tương thích `flutter_local_notifications` v21+ | `android/app/build.gradle.kts` |

---

### 📐 Quy Tắc & Mẫu Code Mới

#### Theme Management
- **ThemeProvider** dùng `AsyncNotifier<ThemeMode>` với persistence qua `SharedPreferences`.
- `main.dart` dùng `ConsumerWidget`, đọc `themeProvider` để truyền `themeMode` vào `MaterialApp.router`.
- UI chọn theme dùng `showModalBottomSheet` với `RadioListTile<ThemeMode>` bên trong `Consumer`.
- `AppTheme` class tập trung định nghĩa `lightTheme` và `darkTheme` trong `lib/config/app_theme.dart`.

```dart
// Đọc theme trong build()
final themeMode = ref.watch(themeProvider).value ?? ThemeMode.system;
// Cập nhật theme
ref.read(themeProvider.notifier).updateThemeMode(ThemeMode.dark);
```

#### Local Notifications (`flutter_local_notifications` v21+)
- **BREAKING:** `show()` và `zonedSchedule()` dùng **named parameters** (`id:`, `title:`, `body:`, `notificationDetails:`).
- `uiLocalNotificationDateInterpretation` đã bị xóa khỏi `zonedSchedule()`.
- Luôn wrap `zonedSchedule` với try-catch để fallback từ `AndroidScheduleMode.exactAllowWhileIdle` → `inexactAllowWhileIdle`.
- Timezone: dùng `tz.TZDateTime` với location `'Asia/Ho_Chi_Minh'`.
- Khởi tạo `NotificationHelper.initialize()` trong `main()` trước `runApp()`.

```dart
// ✅ Cú pháp đúng cho v21+
await _notifications.show(
  id: notificationId,
  title: title,
  body: body,
  notificationDetails: details,
);
```

#### Debt Timeline Pattern
- `personDebtTimelineProvider` là `FutureProvider.family<List<dynamic>, int>` nhận `personId`.
- Gộp `List<Debt>` + `List<TransactionModel>` thành một timeline, lọc bỏ các `TransactionType.lend` và `TransactionType.borrowing` (đã có Debt object đại diện).
- Sắp xếp timeline theo ngày descending.
- Sau mọi thao tác CRUD trên `DebtNotifier`, gọi `ref.invalidate(personDebtTimelineProvider(personId))` để đồng bộ UI.

```dart
// Invalidate timeline sau mỗi mutation
ref.invalidate(personDebtTimelineProvider(debt.personId));
```

#### Provider Naming Convention
- Provider dùng thì hiện tại mô tả trạng thái đang active, KHÔNG dùng "current": `activeTransactionTypeProvider` ✅ thay vì `currentTransactionByTypeProvider` ❌.

#### Android Build Configuration
- `desugar_jdk_libs` phải >= **2.1.4** khi dùng `flutter_local_notifications` v21+.
- Cập nhật trong `android/app/build.gradle.kts` tại khối `dependencies`.

