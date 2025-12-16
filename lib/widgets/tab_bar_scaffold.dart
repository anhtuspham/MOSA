import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/config/tab_bar_config.dart';

/// A scaffold widget that provides a consistent structure for screens with optional tab navigation.
///
/// [CommonScaffold] can be used in two modes:
/// 1. **With tabs**: Combines AppBar and TabBar for multi-view navigation
/// 2. **Without tabs**: Provides a standard scaffold with just AppBar and body
///
/// Features:
/// - Customizable AppBar with title, leading widget, and action buttons
/// - Optional TabBar with configurable styling through [TabBarConfig]
/// - Automatic TabController management when tabs are present
/// - Support for both manual body control and automatic TabBarView creation
/// - Tab change callbacks for analytics or data loading
/// - Flexible enough to work as a regular scaffold when tabs aren't needed
///
/// Example without tabs (regular scaffold):
/// ```dart
/// TabBarScaffold(
///   title: Text('Profile'),
///   body: ProfileScreen(),
/// )
/// ```
///
/// Example with automatic TabBarView:
/// ```dart
/// TabBarScaffold(
///   title: Text('Dashboard'),
///   tabs: [
///     Tab(text: 'Overview'),
///     Tab(text: 'Analytics'),
///   ],
///   children: [
///     OverviewScreen(),
///     AnalyticsScreen(),
///   ],
/// )
/// ```
///
/// Example with manual TabBarView:
/// ```dart
/// TabBarScaffold(
///   title: Text('Reports'),
///   tabs: [
///     Tab(text: 'Daily'),
///     Tab(text: 'Monthly'),
///   ],
///   body: TabBarView(
///     children: [
///       DailyReport(),
///       MonthlyReport(),
///     ],
///   ),
/// )
/// ```
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
          tabs == null || tabs.isEmpty || (children != null && children.length == tabs.length) || body != null,
          'When using tabs, either provide children with matching length or a custom body',
        );

  @override
  State<CommonScaffold> createState() => _CommonScaffoldState();
}

class _CommonScaffoldState extends State<CommonScaffold> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabBarConfig _tabBarConfig;

  @override
  void initState() {
    super.initState();
    _initializeTabController();
  }

  void _initializeTabController() {
    if (_hasTabs) {
      _tabBarConfig = widget.tabBarConfig ?? TabBarConfig.defaultConfig();
      _tabController = TabController(
        length: widget.tabs!.length,
        initialIndex: widget.initialIndex,
        vsync: this,
      );
      _tabController.addListener(_onTabChanged);
    }
  }

  bool get _hasTabs => widget.tabs != null && widget.tabs!.isNotEmpty;

  @override
  void didUpdateWidget(CommonScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle transition between tabs and no-tabs states
    final hadTabs = oldWidget.tabs != null && oldWidget.tabs!.isNotEmpty;
    
    if (_hasTabs && hadTabs && widget.tabs!.length != oldWidget.tabs!.length) {
      // Tab count changed - recreate controller
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
      _initializeTabController();
    } else if (_hasTabs && !hadTabs) {
      // Switched from no tabs to having tabs
      _initializeTabController();
    } else if (!_hasTabs && hadTabs) {
      // Switched from having tabs to no tabs
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
    }
  }

  void _onTabChanged() {
    widget.onTabChanged?.call(_tabController.index);
  }

  @override
  void dispose() {
    if (_hasTabs) {
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
    }
    super.dispose();
  }

  /// Creates a styled TabBar using the provided configuration.
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

  /// Constructs the main content area, either from children or custom body.
  Widget _buildTabContent() {
    // If no tabs, just return the body directly
    if (!_hasTabs) {
      return widget.body ?? (widget.children?.first ?? const SizedBox.shrink());
    }
    
    // If children provided with tabs, auto-build TabBarView with controller
    if (widget.children != null) {
      return TabBarView(controller: _tabController, children: widget.children!);
    }
    // Otherwise use provided body
    return widget.body!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        leading: widget.leading,
        actions: widget.actions,
        actionsPadding: EdgeInsets.symmetric(horizontal: 12.w),
        backgroundColor: widget.appBarBackgroundColor ?? Theme.of(context).colorScheme.inversePrimary,
        elevation: widget.elevation ? null : 0,
        toolbarHeight: widget.appBarHeight,
        bottom: _hasTabs
            ? PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: _buildStyledTabBar(),
              )
            : null,
        centerTitle: widget.centerTitle,
      ),
      body: _buildTabContent(),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

/// Legacy alias maintained for backward compatibility.
/// @deprecated Since v2.0 - Use [CommonScaffold] directly.
typedef CustomTabAppBar = CommonScaffold;
