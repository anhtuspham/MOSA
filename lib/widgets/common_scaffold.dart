import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/config/tab_bar_config.dart';

/// Widget scaffold dùng chung cho toàn bộ màn hình trong ứng dụng MOSA.
///
/// Cung cấp AppBar thống nhất và hỗ trợ điều hướng theo tab.
/// Tự động quản lý vòng đời [TabController] khi dùng tab.
///
/// ## Các chế độ sử dụng
///
/// ### Chế độ 1: Màn hình đơn (không có tab)
/// ```dart
/// CommonScaffold(
///   title: Text('Hồ sơ'),
///   body: ProfileScreen(),
/// )
/// ```
///
/// ### Chế độ 2: Màn hình có tab — tự động tạo [TabBarView]
/// Khuyến nghị cho hầu hết các màn hình có tab:
/// ```dart
/// CommonScaffold(
///   title: Text('Thống kê'),
///   tabs: [
///     Tab(text: 'Thu nhập'),
///     Tab(text: 'Chi tiêu'),
///   ],
///   children: [
///     IncomeStatsScreen(),
///     ExpenseStatsScreen(),
///   ],
/// )
/// ```
///
/// ### Chế độ 3: Màn hình có tab — tự quản lý [TabBarView]
/// Dùng khi cần cấu hình đặc biệt (ví dụ: tắt swipe):
/// ```dart
/// CommonScaffold(
///   title: Text('Quản lý nợ'),
///   tabs: [
///     Tab(icon: Icon(Icons.arrow_upward), text: 'Cho vay'),
///     Tab(icon: Icon(Icons.arrow_downward), text: 'Đi vay'),
///   ],
///   body: TabBarView(
///     physics: NeverScrollableScrollPhysics(),
///     children: [LentScreen(), BorrowedScreen()],
///   ),
/// )
/// ```
///
/// ## Lưu ý quan trọng
/// - Khi có tab: cung cấp [children] (khuyến nghị) hoặc [body].
/// - Số lượng [children] phải bằng số lượng [tabs].
/// - Dùng [TickerProviderStateMixin] để hỗ trợ animation tab mượt mà.
class CommonScaffold extends StatefulWidget {
  /// Tiêu đề hiển thị trên AppBar. Thường là widget [Text].
  final Widget title;

  /// Widget ở đầu AppBar (bên trái). Thường là nút Back hoặc icon menu.
  final Widget? leading;

  /// Danh sách widget hành động ở cuối AppBar (bên phải).
  final List<Widget>? actions;

  /// Danh sách tab hiển thị trên AppBar.
  /// Khi null hoặc rỗng, màn hình hiển thị không có tab.
  final List<Widget>? tabs;

  /// Widget nội dung chính.
  /// Dùng khi không có tab, hoặc khi tự quản lý [TabBarView] (chế độ 3).
  /// Nếu có [children], ưu tiên dùng [children] thay thế.
  final Widget? body;

  /// Danh sách widget nội dung tương ứng với từng tab.
  /// Khi cung cấp cùng [tabs], widget sẽ tự động tạo và quản lý [TabBarView].
  /// Số phần tử phải bằng số lượng [tabs].
  final List<Widget>? children;

  /// Có căn giữa tiêu đề trên AppBar không. Mặc định: `false`.
  final bool? centerTitle;

  /// Cấu hình giao diện cho TabBar (màu indicator, style chữ, v.v.).
  /// Nếu không cung cấp, dùng cấu hình mặc định từ theme.
  final TabBarConfig? tabBarConfig;

  /// Màu nền AppBar. Mặc định dùng màu `onSecondary` từ ColorScheme.
  final Color? appBarBackgroundColor;

  /// Callback được gọi khi người dùng chuyển tab.
  /// Nhận vào chỉ số (index) của tab mới được chọn.
  final ValueChanged<int>? onTabChanged;

  /// Chỉ số tab được chọn mặc định khi khởi tạo. Mặc định: `0`.
  final int initialIndex;

  /// Có hiển thị bóng đổ (shadow) cho AppBar không. Mặc định: `true`.
  final bool elevation;

  /// Chiều cao tùy chỉnh cho AppBar. Nếu null, dùng chiều cao mặc định.
  final double? appBarHeight;

  /// Nút hành động nổi (FAB) hiển thị phía trên nội dung.
  final FloatingActionButton? floatingActionButton;

  /// Tạo [CommonScaffold] với AppBar thống nhất và hỗ trợ điều hướng tab tùy chọn.
  ///
  /// Bắt buộc cung cấp [title] và ít nhất một trong [body] hoặc [children].
  ///
  /// Ném [AssertionError] nếu:
  /// - Không cung cấp cả [body] lẫn [children].
  /// - Số lượng [children] không khớp với [tabs] (khi không dùng [body]).
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
         'Phải cung cấp body hoặc children',
       ),
       assert(
         tabs == null ||
             tabs.isEmpty ||
             (children != null && children.length == tabs.length) ||
             body != null,
         'Khi dùng tabs, phải cung cấp children với số lượng tương ứng hoặc body tùy chỉnh',
       );

  @override
  State<CommonScaffold> createState() => _CommonScaffoldState();
}

/// State nội bộ của [CommonScaffold].
///
/// Quản lý vòng đời [TabController] và xử lý các thay đổi cấu hình tab động.
/// Dùng [TickerProviderStateMixin] để cung cấp ticker cho animation tab.
class _CommonScaffoldState extends State<CommonScaffold>
    with TickerProviderStateMixin {
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

    _tabController = TabController(
      length: widget.tabs!.length,
      initialIndex: widget.initialIndex,
      vsync: this,
    );

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
      return widget.body ??
          (widget.children?.first ?? const SizedBox.shrink());
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
        actions: widget.actions,
        actionsPadding: EdgeInsets.symmetric(horizontal: 12.w),
        backgroundColor:
            widget.appBarBackgroundColor ??
            Theme.of(context).colorScheme.onSecondary,
        // null → dùng elevation mặc định của Material; 0 → phẳng (không bóng)
        elevation: widget.elevation ? null : 0,
        toolbarHeight: widget.appBarHeight,
        bottom:
            _hasTabs
                ? PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: _buildTabBar(),
                )
                : null,
        centerTitle: widget.centerTitle,
      ),
      body: _buildBody(),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
