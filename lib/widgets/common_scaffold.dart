import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/config/tab_bar_config.dart';

/// A reusable scaffold widget that provides consistent structure for screens with optional tab navigation.
///
/// This widget serves as a unified solution for building screens in the app, handling both
/// simple screens and complex tabbed interfaces. It automatically manages [TabController]
/// lifecycle and provides a clean API for common AppBar configurations.
///
/// ## Usage Modes
///
/// ### Mode 1: Simple Screen (No Tabs)
/// Use this mode for standard screens without tab navigation:
/// ```dart
/// CommonScaffold(
///   title: Text('Profile'),
///   body: ProfileScreen(),
/// )
/// ```
///
/// ### Mode 2: Tabbed Screen with Automatic TabBarView
/// The recommended approach for most tabbed screens. Automatically creates and manages
/// a [TabBarView] with the provided children:
/// ```dart
/// CommonScaffold(
///   title: Text('Statistics'),
///   tabs: [
///     Tab(text: 'Income'),
///     Tab(text: 'Expense'),
///   ],
///   children: [
///     IncomeStatsScreen(),
///     ExpenseStatsScreen(),
///   ],
/// )
/// ```
///
/// ### Mode 3: Tabbed Screen with Manual Body Control
/// Use this when you need custom TabBarView configuration or complex nested navigation:
/// ```dart
/// CommonScaffold(
///   title: Text('Debt Management'),
///   tabs: [
///     Tab(icon: Icon(Icons.arrow_upward), text: 'Lent'),
///     Tab(icon: Icon(Icons.arrow_downward), text: 'Borrowed'),
///   ],
///   body: TabBarView(
///     physics: NeverScrollableScrollPhysics(),
///     children: [
///       LentDebtsScreen(),
///       BorrowedDebtsScreen(),
///     ],
///   ),
/// )
/// ```
///
/// ## Key Features
///
/// - **Automatic State Management**: Handles [TabController] creation, updates, and disposal
/// - **Dynamic Tab Updates**: Safely handles tab count changes and tab addition/removal
/// - **Memory Efficient**: Properly disposes controllers and removes listeners to prevent leaks
/// - **Flexible Styling**: Supports custom [TabBarConfig] for consistent theming
/// - **Callback Support**: Optional [onTabChanged] for analytics or data refreshing
/// - **Screen Util Integration**: Uses flutter_screenutil for responsive sizing
///
/// ## Important Notes
///
/// - When using tabs, either [children] (recommended) or [body] must be provided
/// - The number of [children] must match the number of [tabs]
/// - The widget uses [TickerProviderStateMixin] for smooth tab animations
/// - Tab controllers are automatically recreated when tab count changes
class CommonScaffold extends StatefulWidget {
  /// The primary title widget displayed in the center or start of the AppBar.
  /// Typically a [Text] widget with the screen name.
  final Widget title;

  /// Widget displayed at the start of the AppBar before the title.
  /// Commonly used for back buttons, drawer menu icons, or custom navigation.
  final Widget? leading;

  /// Action widgets displayed at the end of the AppBar.
  /// Commonly used for search, settings, or overflow menu buttons.
  final List<Widget>? actions;

  /// Tab widgets that define the navigation options.
  /// Each tab typically contains text, an icon, or both.
  /// When null or empty, the scaffold displays without a TabBar.
  /// The number of tabs must match the number of children in the body when using tabs.
  final List<Widget>? tabs;

  /// Custom body widget for advanced use cases.
  /// When provided, you're responsible for managing the TabBarView and controller.
  /// For simpler usage, prefer the [children] parameter instead.
  final Widget? body;

  /// Content widgets for each tab.
  /// When provided with tabs, automatically creates a managed TabBarView.
  /// This is the recommended approach for most tab-based use cases.
  /// The number of children must match the number of tabs.
  /// Ignored when tabs are not provided.
  final List<Widget>? children;

  /// Whether to center the title text in the AppBar.
  /// Defaults to false, which aligns the title to the start (left).
  final bool? centerTitle;

  /// Styling configuration for the TabBar.
  /// Controls indicator appearance, text styles, padding, and physics.
  /// If not provided, uses default theme-based configuration.
  final TabBarConfig? tabBarConfig;

  /// Background color of the AppBar.
  /// Defaults to theme's inversePrimary color if not specified.
  final Color? appBarBackgroundColor;

  /// Called when the user selects a different tab.
  /// Receives the index of the newly selected tab.
  /// Useful for analytics tracking or lazy data loading.
  final ValueChanged<int>? onTabChanged;

  /// Index of the tab to display initially.
  /// Must be valid within the range of available tabs.
  final int initialIndex;

  /// Controls the shadow elevation of the AppBar.
  /// Set to false for a flat appearance.
  final bool elevation;

  /// Override the default AppBar height.
  /// Useful for creating more compact or spacious headers.
  final double? appBarHeight;

  /// Floating action button displayed over the content.
  /// Typically used for primary actions like 'Add' or 'Create'.
  final FloatingActionButton? floatingActionButton;

  /// Creates a [CommonScaffold] with consistent AppBar and optional tab navigation.
  ///
  /// The [title] parameter is required and displayed in the AppBar.
  ///
  /// For screens without tabs, provide either:
  /// - [body]: A single widget for the screen content
  /// - [children]: A list with one widget (less common)
  ///
  /// For screens with tabs, provide:
  /// - [tabs]: List of Tab widgets defining navigation options
  /// - [children]: Matching list of content widgets (recommended), OR
  /// - [body]: Custom TabBarView for advanced use cases
  ///
  /// Throws [AssertionError] if:
  /// - Neither [body] nor [children] is provided
  /// - [tabs] count doesn't match [children] count
  CommonScaffold({
    super.key,
    required this.title,
    this.tabs,
    this.body,
    this.children,
    this.centerTitle = false,
    this.leading,
    this.actions,
    this.tabBarConfig,
    this.appBarBackgroundColor,
    this.onTabChanged,
    this.initialIndex = 0,
    this.elevation = true,
    this.appBarHeight,
    this.floatingActionButton,
  }) : assert(
         body != null || children != null,
         'Either body or children must be provided',
       ),
       assert(
         tabs == null ||
             tabs.isEmpty ||
             (children != null && children.length == tabs.length) ||
             body != null,
         'When using tabs, either provide children with matching length or a custom body',
       );

  @override
  State<CommonScaffold> createState() => _CommonScaffoldState();
}

/// Private state class for [CommonScaffold].
///
/// Manages the lifecycle of [TabController] and handles dynamic updates to tabs.
/// Uses [TickerProviderStateMixin] to provide animation tickers for smooth tab transitions.
class _CommonScaffoldState extends State<CommonScaffold>
    with TickerProviderStateMixin {
  /// Controller for managing tab selection and animation.
  /// Only initialized when tabs are present.
  late TabController _tabController;

  /// Configuration object for TabBar styling.
  /// Initialized from widget parameter or uses defaults.
  late TabBarConfig _tabBarConfig;

  @override
  void initState() {
    super.initState();
    // Set up tab controller on first build if tabs are present
    _initializeTabController();
  }

  /// Initializes the [TabController] and [TabBarConfig] if tabs are present.
  ///
  /// This method:
  /// 1. Checks if tabs exist via [_hasTabs]
  /// 2. Sets up tab bar styling configuration
  /// 3. Creates a new controller with the correct tab count
  /// 4. Attaches a listener for tab change notifications
  ///
  /// Called during [initState] and when tab configuration changes in [didUpdateWidget].
  void _initializeTabController() {
    if (_hasTabs) {
      // Use custom config or fall back to theme-based defaults
      _tabBarConfig = widget.tabBarConfig ?? TabBarConfig.defaultConfig();

      // Create controller with animation ticker from TickerProviderStateMixin
      _tabController = TabController(
        length: widget.tabs!.length,
        initialIndex: widget.initialIndex,
        vsync: this,
      );

      // Listen for tab changes to notify parent widget
      _tabController.addListener(_onTabChanged);
    }
  }

  /// Checks whether the widget currently has tabs configured.
  ///
  /// Returns true if [tabs] is non-null and contains at least one tab.
  /// Used throughout the widget to conditionally render tab-related UI.
  bool get _hasTabs => widget.tabs != null && widget.tabs!.isNotEmpty;

  /// Handles updates to the widget configuration.
  ///
  /// This method is critical for managing dynamic tab changes. It handles three scenarios:
  ///
  /// 1. **Tab count changed**: Disposes old controller and creates new one with updated count
  /// 2. **Tabs added**: Creates controller when transitioning from no tabs to having tabs
  /// 3. **Tabs removed**: Disposes controller when transitioning from tabs to no tabs
  ///
  /// This ensures proper memory management and prevents controller/tab count mismatches
  /// that would cause runtime errors or UI glitches.
  @override
  void didUpdateWidget(CommonScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Determine if the previous widget configuration had tabs
    final hadTabs = oldWidget.tabs != null && oldWidget.tabs!.isNotEmpty;

    // Scenario 1: Tab count changed (e.g., from 2 tabs to 3 tabs)
    if (_hasTabs && hadTabs && widget.tabs!.length != oldWidget.tabs!.length) {
      // Clean up old controller to prevent memory leak
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
      // Create new controller with updated tab count
      _initializeTabController();
    }
    // Scenario 2: Switched from no tabs to having tabs
    else if (_hasTabs && !hadTabs) {
      _initializeTabController();
    }
    // Scenario 3: Switched from having tabs to no tabs
    else if (!_hasTabs && hadTabs) {
      // Clean up controller that's no longer needed
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
    }
  }

  /// Callback invoked when the user switches tabs.
  ///
  /// Notifies the parent widget via [onTabChanged] callback if provided.
  /// Useful for triggering data refreshes, analytics tracking, or other side effects.
  void _onTabChanged() {
    widget.onTabChanged?.call(_tabController.index);
  }

  /// Cleans up resources when the widget is removed from the tree.
  ///
  /// Ensures proper disposal of the [TabController] and removes all listeners
  /// to prevent memory leaks. This is critical for tab-based screens that may
  /// be frequently pushed/popped in navigation.
  @override
  void dispose() {
    if (_hasTabs) {
      // Remove listener first to avoid callbacks during disposal
      _tabController.removeListener(_onTabChanged);
      // Dispose controller to free animation resources
      _tabController.dispose();
    }
    super.dispose();
  }

  /// Creates a styled TabBar using the provided configuration.
  ///
  /// Applies styling from [_tabBarConfig] including:
  /// - Indicator color, size, and weight
  /// - Selected and unselected label text styles
  /// - Label padding for consistent spacing
  /// - Scroll physics for tab overflow behavior
  ///
  /// The [TabBar] is connected to [_tabController] for state synchronization.
  Widget _buildStyledTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: _tabBarConfig.indicatorColor,
      indicatorSize: _tabBarConfig.indicatorSize,
      indicatorWeight: _tabBarConfig.indicatorWeight,
      labelStyle: _tabBarConfig.labelStyle,
      unselectedLabelStyle: _tabBarConfig.unselectedLabelStyle,
      labelPadding: _tabBarConfig.labelPadding,
      physics: _tabBarConfig.physics,
      tabs: widget.tabs!,
    );
  }

  /// Constructs the main content area based on the widget configuration.
  ///
  /// Three possible return values:
  ///
  /// 1. **No tabs mode**: Returns [body] if provided, or first [children] item, or empty widget
  /// 2. **Auto TabBarView mode**: Creates a [TabBarView] from [children] with managed controller
  /// 3. **Manual body mode**: Returns custom [body] that should contain its own TabBarView
  ///
  /// The method prioritizes [children] over [body] when tabs are present, as [children]
  /// provides automatic controller management and is the recommended approach.
  Widget _buildTabContent() {
    // Scenario 1: No tabs - simple body rendering
    if (!_hasTabs) {
      return widget.body ?? (widget.children?.first ?? const SizedBox.shrink());
    }

    // Scenario 2: Tabs with children - auto-create TabBarView
    // This is the recommended pattern for most use cases
    if (widget.children != null) {
      return TabBarView(controller: _tabController, children: widget.children!);
    }

    // Scenario 3: Tabs with custom body - advanced use case
    // User is responsible for TabBarView and controller management
    return widget.body!;
  }

  /// Builds the complete scaffold structure with AppBar and content.
  ///
  /// The AppBar configuration includes:
  /// - Title, leading widget, and action buttons
  /// - Responsive padding using flutter_screenutil
  /// - Theme-based or custom background color
  /// - Optional elevation for shadow effect
  /// - Optional custom toolbar height
  /// - TabBar in the bottom slot if tabs are present
  ///
  /// The body is built using [_buildTabContent] which handles both
  /// tabbed and non-tabbed content rendering.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        leading: widget.leading,
        actions: widget.actions,
        // Responsive horizontal padding for action buttons
        actionsPadding: EdgeInsets.symmetric(horizontal: 12.w),
        // Use custom color or fall back to theme's inversePrimary
        backgroundColor:
            widget.appBarBackgroundColor ??
            Theme.of(context).colorScheme.inversePrimary,
        // Set elevation to 0 for flat look, or use default Material elevation
        elevation: widget.elevation ? null : 0,
        // Custom toolbar height for compact or spacious layouts
        toolbarHeight: widget.appBarHeight,
        // Add TabBar at bottom of AppBar if tabs exist
        bottom:
            _hasTabs
                ? PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: _buildStyledTabBar(),
                )
                : null,
        centerTitle: widget.centerTitle,
      ),
      // Main content area - handles both tabbed and simple layouts
      body: _buildTabContent(),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

/// Legacy alias maintained for backward compatibility with older code.
///
/// This typedef allows existing code using [CustomTabAppBar] to continue working
/// without modifications. However, new code should use [CommonScaffold] directly.
///
/// **Deprecated**: This alias will be removed in a future version.
/// Please migrate to [CommonScaffold] for better code clarity.
///
/// Example migration:
/// ```dart
/// // Old code
/// CustomTabAppBar(title: Text('Home'), body: HomeScreen())
///
/// // New code
/// CommonScaffold(title: Text('Home'), body: HomeScreen())
/// ```
@Deprecated('Use CommonScaffold instead. This alias will be removed in v3.0')
typedef CustomTabAppBar = CommonScaffold;
