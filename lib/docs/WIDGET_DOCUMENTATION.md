# Custom Widgets Documentation

## TabBarScaffold

A reusable scaffold widget that combines AppBar with TabBar functionality for easy implementation of tabbed screens.

### Overview

`TabBarScaffold` provides a complete tabbed interface solution with:
- Customizable AppBar (title, leading widget, actions)
- Flexible TabBar with configurable styling
- Automatic tab synchronization
- Lifecycle management via `TickerProviderStateMixin`

### Basic Usage

```dart
TabBarScaffold(
  title: Text('My Tabs'),
  tabs: [
    Tab(text: 'Tab 1'),
    Tab(text: 'Tab 2'),
    Tab(text: 'Tab 3'),
  ],
  body: TabBarView(
    children: [
      FirstTabContent(),
      SecondTabContent(),
      ThirdTabContent(),
    ],
  ),
)
```

### Complete Example with All Parameters

```dart
TabBarScaffold(
  title: const Text('Category Selection'),
  leading: IconButton(
    onPressed: () => context.pop(),
    icon: const Icon(Icons.arrow_back),
  ),
  actions: const [
    Icon(Icons.search),
    SizedBox(width: 10),
    Icon(Icons.filter),
  ],
  tabs: const [
    Tab(text: 'Expenses'),
    Tab(text: 'Income'),
    Tab(text: 'Loans'),
  ],
  appBarBackgroundColor: AppColors.background,
  tabBarConfig: TabBarConfig.light(),
  initialIndex: 0,
  elevation: true,
  onTabChanged: (index) {
    print('Tab changed to: $index');
    // Trigger data loading or state updates
  },
  body: TabBarView(
    children: [
      ExpenseTabContent(),
      IncomeTabContent(),
      LoansTabContent(),
    ],
  ),
)
```

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `title` | Widget | Yes | - | Title widget for AppBar |
| `tabs` | List<Widget> | Yes | - | List of Tab widgets |
| `body` | Widget | Yes | - | Main content, typically TabBarView |
| `leading` | Widget? | No | null | Leading widget (back button, etc.) |
| `actions` | List<Widget>? | No | null | Action buttons in AppBar |
| `tabBarConfig` | TabBarConfig? | No | TabBarConfig.defaultConfig() | TabBar styling configuration |
| `appBarBackgroundColor` | Color? | No | theme.inversePrimary | AppBar background color |
| `onTabChanged` | ValueChanged<int>? | No | null | Callback when tab changes |
| `initialIndex` | int | No | 0 | Initial tab index |
| `elevation` | bool | No | true | Show AppBar shadow |
| `appBarHeight` | double? | No | null | Custom AppBar height |

### TabBarConfig

Configuration class for centralizing TabBar styling across the app.

#### Predefined Themes

```dart
// Default configuration (matches app styling)
TabBarConfig.defaultConfig()

// Light theme
TabBarConfig.light()

// Dark theme
TabBarConfig.dark()

// Custom configuration
TabBarConfig(
  indicatorColor: Colors.blue,
  indicatorSize: TabBarIndicatorSize.label,
  labelStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
  unselectedLabelStyle: TextStyle(color: Colors.grey),
  backgroundColor: Colors.white,
  indicatorWeight: 3.0,
)
```

#### Customization with copyWith

```dart
final customConfig = TabBarConfig.defaultConfig().copyWith(
  indicatorColor: AppColors.secondary,
  labelStyle: TextStyle(
    color: AppColors.secondary,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  ),
);

TabBarScaffold(
  // ... other parameters
  tabBarConfig: customConfig,
)
```

### Best Practices

#### 1. **Always use TabBarView as body**
```dart
// ✓ Correct
TabBarScaffold(
  tabs: [...],
  body: TabBarView(children: [...]),
)

// ✗ Wrong - won't sync properly
TabBarScaffold(
  tabs: [...],
  body: SingleChildScrollView(child: ...),
)
```

#### 2. **Match tab count with TabBarView children**
```dart
// ✓ Correct - 3 tabs, 3 children
TabBarScaffold(
  tabs: [Tab(text: 'A'), Tab(text: 'B'), Tab(text: 'C')],
  body: TabBarView(children: [ContentA(), ContentB(), ContentC()]),
)
```

#### 3. **Use onTabChanged for side effects**
```dart
TabBarScaffold(
  tabs: [...],
  onTabChanged: (index) {
    // Load data for the new tab
    _loadTabData(index);
    // Track analytics
    analytics.logTabSwitch(index);
  },
)
```

#### 4. **Extract tab content to separate widgets**
```dart
class MyTabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TabBarScaffold(
      title: Text('My Tabs'),
      tabs: [Tab(text: 'Tab 1'), Tab(text: 'Tab 2')],
      body: TabBarView(
        children: [
          _buildTab1Content(),
          _buildTab2Content(),
        ],
      ),
    );
  }

  Widget _buildTab1Content() => Center(child: Text('Tab 1'));
  Widget _buildTab2Content() => Center(child: Text('Tab 2'));
}
```

#### 5. **Reuse styling configuration**
```dart
// Create a constant config for consistency
const categoryTabConfig = TabBarConfig(
  indicatorColor: AppColors.primary,
  labelStyle: TextStyle(fontWeight: FontWeight.bold),
  unselectedLabelStyle: TextStyle(color: AppColors.textSecondary),
);

// Use in multiple screens
TabBarScaffold(
  tabBarConfig: categoryTabConfig,
  // ... other parameters
)
```

### Migration from CustomTabAppBar

The old `CustomTabAppBar` class is now an alias for `TabBarScaffold`. If you're using the old name:

**Before:**
```dart
CustomTabAppBar(
  title: Text('Title'),
  tabElement: [...],
  backgroundColor: Colors.white,
  child: TabBarView(...),
)
```

**After:**
```dart
TabBarScaffold(
  title: Text('Title'),
  tabs: [...],
  appBarBackgroundColor: Colors.white,
  body: TabBarView(...),
)
```

### Common Patterns

#### Pattern 1: Dynamic Tab Content
```dart
class DynamicTabScreen extends StatefulWidget {
  final List<String> tabNames;

  @override
  State<DynamicTabScreen> createState() => _DynamicTabScreenState();
}

class _DynamicTabScreenState extends State<DynamicTabScreen> {
  late List<int> tabIndexes;

  @override
  void initState() {
    super.initState();
    tabIndexes = List.generate(widget.tabNames.length, (i) => i);
  }

  @override
  Widget build(BuildContext context) {
    return TabBarScaffold(
      title: Text('Dynamic Tabs'),
      tabs: widget.tabNames.map((name) => Tab(text: name)).toList(),
      body: TabBarView(
        children: tabIndexes
            .map((index) => Center(child: Text('Tab ${index + 1}')))
            .toList(),
      ),
    );
  }
}
```

#### Pattern 2: Tab with State Management
```dart
class StateAwareTabScreen extends StatefulWidget {
  @override
  State<StateAwareTabScreen> createState() => _StateAwareTabScreenState();
}

class _StateAwareTabScreenState extends State<StateAwareTabScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return TabBarScaffold(
      title: Text('Tab $_currentTabIndex'),
      tabs: [
        Tab(text: 'Home'),
        Tab(text: 'Profile'),
        Tab(text: 'Settings'),
      ],
      onTabChanged: (index) {
        setState(() => _currentTabIndex = index);
      },
      body: TabBarView(
        children: [
          HomeTab(key: PageStorageKey('home')),
          ProfileTab(key: PageStorageKey('profile')),
          SettingsTab(key: PageStorageKey('settings')),
        ],
      ),
    );
  }
}
```

### Troubleshooting

#### Problem: Tabs not synchronizing
**Solution:** Ensure TabBarView is the direct child of `body` parameter, not wrapped in other widgets.

#### Problem: Animations not working
**Solution:** Verify the widget is using `TickerProviderStateMixin` (already handled internally).

#### Problem: Performance issues with many tabs
**Solution:** Use `PageStorageKey` for each tab content to preserve scroll position and reduce rebuild:
```dart
TabBarView(
  children: [
    FirstTab(key: PageStorageKey('tab1')),
    SecondTab(key: PageStorageKey('tab2')),
  ],
)
```

### Real-world Examples

#### Example 1: Category Selection (from CategoryScreen)
```dart
class CategoryScreen extends StatefulWidget {
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return TabBarScaffold(
      title: const Text('Select Category'),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      tabs: const [
        Tab(text: 'Expenses'),
        Tab(text: 'Income'),
        Tab(text: 'Loans'),
      ],
      body: TabBarView(
        children: [
          _buildCategoryList('expenses'),
          _buildCategoryList('income'),
          _buildCategoryList('loans'),
        ],
      ),
    );
  }

  Widget _buildCategoryList(String type) {
    return ListView(
      children: const [
        ListTile(title: Text('Category 1')),
        ListTile(title: Text('Category 2')),
      ],
    );
  }
}
```

#### Example 2: Wallet Management (from WalletScreen)
```dart
class WalletScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TabBarScaffold(
      title: const Text('Accounts'),
      actions: const [
        Icon(Icons.search),
        SizedBox(width: 10),
        Icon(Icons.filter),
      ],
      tabs: const [
        Tab(text: 'Accounts'),
        Tab(text: 'Savings'),
        Tab(text: 'Accumulation'),
      ],
      body: TabBarView(
        children: [
          AccountsTab(),
          SavingsTab(),
          AccumulationTab(),
        ],
      ),
    );
  }
}
```

---

## Other Custom Widgets

### CustomListTile
A customizable list tile with optional leading, title, trailing widgets and tap callback.

### TransactionItem
Displays a single transaction with icon, amount, and wallet info.

### TransactionInPeriodTime
Groups and displays transactions for a specific time period.

### CategoryPieChart
Visualizes transaction distribution across categories using a pie chart.

### TransactionCategoryItem
Shows category name with a percentage indicator bar.

---

## Performance Tips

1. **Use const constructors** when possible to reduce rebuild cycles
2. **Extract tab content** to separate widgets to prevent unnecessary rebuilds
3. **Use PageStorageKey** for stateful tab content
4. **Lazy load** heavy content using FutureBuilder
5. **Avoid rebuilding** the entire TabBarScaffold when only tab content changes

---

## Contributing

When adding new features to TabBarScaffold:
1. Update this documentation
2. Add unit tests for new parameters
3. Update the real-world examples if relevant
4. Ensure backward compatibility

