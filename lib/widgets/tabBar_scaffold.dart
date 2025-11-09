import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/config/tab_bar_config.dart';

/// A reusable scaffold widget that combines AppBar with TabBar functionality.
///
/// [TabBarScaffold] provides a convenient way to create a screen with:
/// - A customizable AppBar (title, leading widget, actions)
/// - A TabBar with multiple tabs
/// - A body that syncs with the selected tab
///
/// The widget uses [DefaultTabController] internally to manage tab state,
/// and supports flexible customization through [TabBarConfig].
///
/// **Example Usage:**
/// ```dart
/// TabBarScaffold(
///   title: Text('My Tabs'),
///   tabs: [
///     Tab(text: 'Tab 1'),
///     Tab(text: 'Tab 2'),
///   ],
///   tabBarConfig: TabBarConfig.defaultConfig(),
///   body: TabBarView(
///     children: [
///       FirstTabContent(),
///       SecondTabContent(),
///     ],
///   ),
/// )
/// ```
class TabBarScaffold extends StatefulWidget {
  /// The title widget displayed in the AppBar
  final Widget title;

  /// Optional leading widget for the AppBar (usually a back button)
  final Widget? leading;

  /// Optional action buttons displayed in the AppBar trailing position
  final List<Widget>? actions;

  /// List of Tab widgets to display in the TabBar
  ///
  /// Example: `[Tab(text: 'Tab 1'), Tab(text: 'Tab 2')]`
  final List<Widget> tabs;

  /// The main content widget, typically a [TabBarView]
  ///
  /// This widget should contain children that match the number of tabs.
  /// **Important:** If using [TabBarView], pass `controller: _tabController` to it.
  /// Alternatively, use the [children] parameter for automatic TabBarView building.
  final Widget? body;

  /// List of widgets to display in the tabs (auto-builds TabBarView)
  ///
  /// If provided, [TabBarScaffold] will automatically create a [TabBarView]
  /// with the controller already injected. This is the recommended approach.
  /// If both [body] and [children] are provided, [children] takes precedence.
  final List<Widget>? children;

  /// Configuration object for TabBar styling and behavior
  ///
  /// Use [TabBarConfig] to customize indicator color, text styles, etc.
  /// Defaults to [TabBarConfig.defaultConfig()] if not provided.
  final TabBarConfig? tabBarConfig;

  /// Optional background color for the AppBar
  ///
  /// If not specified, uses the theme's [inversePrimary] color.
  final Color? appBarBackgroundColor;

  /// Callback triggered when the active tab changes
  ///
  /// Useful for tracking tab switches or triggering data loading.
  /// The callback receives the index of the newly selected tab.
  final ValueChanged<int>? onTabChanged;

  /// The initial tab index to display
  ///
  /// Defaults to 0 (first tab).
  final int initialIndex;

  /// Whether the AppBar should be elevated (shadow effect)
  final bool elevation;

  /// Custom height for the AppBar
  ///
  /// If null, uses the standard AppBar height.
  final double? appBarHeight;

  // Custom floatAtion button in bottom bar
  final FloatingActionButton? floatingActionButton;

  const TabBarScaffold({
    super.key,
    required this.title,
    required this.tabs,
    this.body,
    this.children,
    this.leading,
    this.actions,
    this.tabBarConfig,
    this.appBarBackgroundColor,
    this.onTabChanged,
    this.initialIndex = 0,
    this.elevation = true,
    this.appBarHeight,
    this.floatingActionButton
  }) : assert(body != null || children != null, 'Either body or children must be provided');

  @override
  State<TabBarScaffold> createState() => _TabBarScaffoldState();
}

class _TabBarScaffoldState extends State<TabBarScaffold> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabBarConfig _tabBarConfig;

  @override
  void initState() {
    super.initState();
    _tabBarConfig = widget.tabBarConfig ?? TabBarConfig.defaultConfig();
    _tabController = TabController(length: widget.tabs.length, initialIndex: widget.initialIndex, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(TabBarScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != oldWidget.tabs.length) {
      _tabController.dispose();
      _tabController = TabController(length: widget.tabs.length, initialIndex: widget.initialIndex, vsync: this);
      _tabController.addListener(_onTabChanged);
    }
  }

  void _onTabChanged() {
    widget.onTabChanged?.call(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  /// Builds the TabBar widget with configuration
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: _tabBarConfig.indicatorColor,
      indicatorSize: _tabBarConfig.indicatorSize,
      indicatorWeight: _tabBarConfig.indicatorWeight,
      labelStyle: _tabBarConfig.labelStyle,
      unselectedLabelStyle: _tabBarConfig.unselectedLabelStyle,
      labelPadding: _tabBarConfig.labelPadding,
      physics: _tabBarConfig.physics,
      tabs: widget.tabs,
    );
  }

  /// Build the body content - auto-build TabBarView if children provided
  Widget _buildBody() {
    // If children provided, auto-build TabBarView with controller
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
        bottom: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight), child: _buildTabBar()),
      ),
      body: _buildBody(),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

/// Backward compatibility alias for migration
/// @deprecated Use [TabBarScaffold] instead
typedef CustomTabAppBar = TabBarScaffold;
