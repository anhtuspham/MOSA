import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/config/tab_bar_config.dart';

/// Widget Scaffold dùng chung cho toàn bộ màn hình trong ứng dụng MOSA.
///
/// [CommonScaffold] cung cấp một AppBar thống nhất và hỗ trợ các chế độ hiển thị linh hoạt:
/// 1. [CommonScaffold.single]: Cho màn hình đơn giản, không có tab.
/// 2. [CommonScaffold.tabbed]: Cho màn hình có nhiều tab, tự động quản lý [TabBarView].
/// 3. [CommonScaffold.customTabbed]: Cho màn hình có tab nhưng muốn tự tùy chỉnh nội dung (ví dụ: tắt vuốt tab).
class CommonScaffold extends StatefulWidget {
  /// Tiêu đề hiển thị trên AppBar. Thường là widget [Text].
  final Widget title;

  /// Widget ở đầu AppBar (bên trái). Thường là nút Back hoặc icon menu.
  final Widget? leading;

  /// Danh sách widget hành động ở cuối AppBar (bên phải).
  final List<Widget>? actions;

  /// Danh sách tab hiển thị trên AppBar.
  final List<Widget>? tabs;

  /// Widget nội dung chính.
  /// Được sử dụng trong chế độ [single] hoặc [customTabbed].
  final Widget? body;

  /// Danh sách widget nội dung tương ứng với từng tab.
  /// Được sử dụng trong chế độ [tabbed] để tự động tạo [TabBarView].
  final List<Widget>? children;

  /// Có căn giữa tiêu đề trên AppBar không. Mặc định: `false`.
  final bool? centerTitle;

  /// Cấu hình giao diện cho TabBar (màu indicator, style chữ, v.v.).
  final TabBarConfig? tabBarConfig;

  /// Màu nền AppBar. Mặc định dùng màu `onSecondary` từ ColorScheme.
  final Color? appBarBackgroundColor;

  /// Callback được gọi khi người dùng chuyển tab.
  final ValueChanged<int>? onTabChanged;

  /// Chỉ số tab được chọn mặc định khi khởi tạo. Mặc định: `0`.
  final int initialIndex;

  /// Có hiển thị bóng đổ (shadow) cho AppBar không. Mặc định: `true`.
  final bool elevation;

  /// Chiều cao tùy chỉnh cho AppBar. Nếu null, dùng chiều cao mặc định.
  final double? appBarHeight;

  /// Nút hành động nổi (FAB) hiển thị phía trên nội dung.
  final FloatingActionButton? floatingActionButton;

  /// Constructor mặc định (Private)
  const CommonScaffold._({
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
  });

  /// 🌟 **Chế độ 1: Màn hình đơn (Single Screen)**
  ///
  /// Sử dụng khi màn hình chỉ có một nội dung duy nhất, không có hệ thống tab.
  /// Chỉ nhận tham số [body].
  factory CommonScaffold.single({
    Key? key,
    required Widget title,
    required Widget body,
    Widget? leading,
    List<Widget>? actions,
    bool? centerTitle,
    Color? appBarBackgroundColor,
    bool elevation = true,
    double? appBarHeight,
    FloatingActionButton? floatingActionButton,
  }) {
    return CommonScaffold._(
      key: key,
      title: title,
      body: body,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      appBarBackgroundColor: appBarBackgroundColor,
      elevation: elevation,
      appBarHeight: appBarHeight,
      floatingActionButton: floatingActionButton,
    );
  }

  /// 🌟 **Chế độ 2: Màn hình Tab tự động (Auto Tabbed)**
  ///
  /// Sử dụng khi màn hình có nhiều tab và bạn muốn widget tự động tạo [TabBarView].
  /// Yêu cầu cung cấp [tabs] và [children] với số lượng bằng nhau.
  factory CommonScaffold.tabbed({
    Key? key,
    required Widget title,
    required List<Widget> tabs,
    required List<Widget> children,
    Widget? leading,
    List<Widget>? actions,
    bool? centerTitle,
    TabBarConfig? tabBarConfig,
    Color? appBarBackgroundColor,
    ValueChanged<int>? onTabChanged,
    int initialIndex = 0,
    bool elevation = true,
    double? appBarHeight,
    FloatingActionButton? floatingActionButton,
  }) {
    assert(tabs.length == children.length, 'Số lượng tabs và children phải bằng nhau');
    return CommonScaffold._(
      key: key,
      title: title,
      tabs: tabs,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      tabBarConfig: tabBarConfig,
      appBarBackgroundColor: appBarBackgroundColor,
      onTabChanged: onTabChanged,
      initialIndex: initialIndex,
      elevation: elevation,
      appBarHeight: appBarHeight,
      floatingActionButton: floatingActionButton,
      children: children,
    );
  }

  /// 🌟 **Chế độ 3: Màn hình Tab tùy chỉnh (Custom Tabbed)**
  ///
  /// Sử dụng khi màn hình có tab nhưng bạn muốn tự quản lý nội dung chính [body]
  /// (ví dụ: lồng các widget phức tạp hơn [TabBarView]).
  factory CommonScaffold.customTabbed({
    Key? key,
    required Widget title,
    required List<Widget> tabs,
    required Widget body,
    Widget? leading,
    List<Widget>? actions,
    bool? centerTitle,
    TabBarConfig? tabBarConfig,
    Color? appBarBackgroundColor,
    ValueChanged<int>? onTabChanged,
    int initialIndex = 0,
    bool elevation = true,
    double? appBarHeight,
    FloatingActionButton? floatingActionButton,
  }) {
    return CommonScaffold._(
      key: key,
      title: title,
      tabs: tabs,
      body: body,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      tabBarConfig: tabBarConfig,
      appBarBackgroundColor: appBarBackgroundColor,
      onTabChanged: onTabChanged,
      initialIndex: initialIndex,
      elevation: elevation,
      appBarHeight: appBarHeight,
      floatingActionButton: floatingActionButton,
    );
  }

  @override
  State<CommonScaffold> createState() => _CommonScaffoldState();
}

/// State nội bộ của [CommonScaffold].
///
/// Quản lý vòng đời [TabController] và xử lý các thay đổi cấu hình tab động.
/// Dùng [TickerProviderStateMixin] để cung cấp ticker cho animation tab.
class _CommonScaffoldState extends State<CommonScaffold> with TickerProviderStateMixin {
  /// Controller quản lý trạng thái và animation của tab.
  /// Nullable — chỉ khởi tạo khi màn hình có tab, an toàn hơn so với `late`.
  TabController? _tabController;

  /// Cấu hình giao diện TabBar. Chỉ hợp lệ khi có tab.
  late TabBarConfig _tabBarConfig;

  @override
  void initState() {
    super.initState();
    _initTabController();
  }

  /// Khởi tạo [TabController] và [TabBarConfig] nếu màn hình có tab.
  void _initTabController() {
    if (!_hasTabs) return;

    // Dùng config tùy chỉnh hoặc fallback về config mặc định từ theme
    _tabBarConfig = widget.tabBarConfig ?? TabBarConfig.defaultConfig();

    _tabController = TabController(length: widget.tabs!.length, initialIndex: widget.initialIndex, vsync: this);

    // Lắng nghe sự kiện chuyển tab để thông báo cho widget cha
    _tabController!.addListener(_onTabChanged);
  }

  /// Kiểm tra xem màn hình có cấu hình tab hay không.
  bool get _hasTabs => widget.tabs != null && widget.tabs!.isNotEmpty;

  @override
  void didUpdateWidget(CommonScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);

    final hadTabs = oldWidget.tabs != null && oldWidget.tabs!.isNotEmpty;

    if (_hasTabs && hadTabs) {
      // Trường hợp số tab thay đổi: tái tạo controller với số lượng mới
      if (widget.tabs!.length != oldWidget.tabs!.length) {
        _disposeTabController();
        _initTabController();
      }
    } else if (_hasTabs && !hadTabs) {
      // Chuyển từ màn hình không có tab sang có tab
      _initTabController();
    } else if (!_hasTabs && hadTabs) {
      // Chuyển từ màn hình có tab sang không có tab
      _disposeTabController();
    }
  }

  /// Hủy [TabController] và gỡ listener để tránh memory leak.
  void _disposeTabController() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    _tabController = null;
  }

  /// Callback khi người dùng chuyển tab.
  /// Thông báo index tab mới cho widget cha qua [onTabChanged].
  void _onTabChanged() {
    final index = _tabController?.index;
    if (index != null) {
      widget.onTabChanged?.call(index);
    }
  }

  @override
  void dispose() {
    _disposeTabController();
    super.dispose();
  }

  /// Xây dựng [TabBar] với cấu hình giao diện từ [_tabBarConfig].
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
      tabs: widget.tabs!,
    );
  }

  /// Xây dựng nội dung chính dựa trên cấu hình widget:
  ///
  /// - Không có tab → trả về [body] hoặc widget đầu tiên trong [children].
  /// - Có tab + [children] → tự động tạo [TabBarView] (chế độ khuyến nghị).
  /// - Có tab + [body] → trả về [body] để người dùng tự quản lý.
  Widget _buildBody() {
    if (!_hasTabs) {
      return widget.body ?? (widget.children?.first ?? const SizedBox.shrink());
    }

    if (widget.children != null) {
      return TabBarView(controller: _tabController, children: widget.children!);
    }

    return widget.body!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        leading: widget.leading,
        // leading:
        //     widget.leading ??
        //     IconButton(
        //       onPressed: () => context.pop(),
        //       icon: Icon(
        //         Icons.arrow_back,
        //         color:
        //             _hasTabs
        //                 ? Theme.of(context).colorScheme.onSecondary
        //                 : Theme.of(context).colorScheme.onPrimaryContainer,
        //       ),
        //     ),
        actions: widget.actions,
        actionsPadding: EdgeInsets.symmetric(horizontal: 12.w),
        backgroundColor: widget.appBarBackgroundColor ?? Theme.of(context).colorScheme.onSecondary,
        // null → dùng elevation mặc định của Material; 0 → phẳng (không bóng)
        elevation: widget.elevation ? null : 0,
        toolbarHeight: widget.appBarHeight,
        bottom:
            _hasTabs
                ? PreferredSize(preferredSize: const Size.fromHeight(kToolbarHeight), child: _buildTabBar())
                : null,
        centerTitle: widget.centerTitle,
      ),
      body: _buildBody(),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
