/// Centralized routes definition for nested routing
/// Bottom Nav Shell → 5 branches (Overview, Wallet, History, Stats, Settings)
/// Mỗi branch có child routes riêng
abstract class AppRoutes {
  // ===== SHELL / MAIN LAYOUT ROUTES =====

  /// Home shell - bottom nav layout (parent)
  static const String shell = '/';

  // ===== BRANCH 1: OVERVIEW / TỔNG QUAN =====
  static const String overview = '/overview';

  // ===== BRANCH 2: WALLET / TÀI KHOẢN =====
  static const String wallet = '/wallet';
  static const String addWallet = '/wallet/add';

  // ===== BRANCH 3: HISTORY / LỊCH SỬ =====
  static const String history = '/history';

  // ===== BRANCH 4: STATS / THỐNG KÊ =====
  static const String stats = '/stats';

  // ===== BRANCH 5: SETTINGS / CÀI ĐẶT =====
  static const String settings = '/settings';

  static const String login = '/login';

  // ===== TRANSACTION FLOWS (OVERLAY / MODAL) =====
  // Những route này NOT thuộc bottom nav, nằm phía trên
  // Khi navigate tới đây → FAB → open AddTransaction screen

  /// Add new transaction (full screen / modal)
  static const String addTransaction = '/add-transaction';

  /// Edit existing transaction
  /// Format: /edit-transaction/123 (id = 123)
  static const String editTransaction = '/edit-transaction/:id';

  /// View transaction detail
  static const String viewTransaction = '/transaction/:id';

  // ===== CATEGORY MANAGEMENT =====
  static const String categoryList = '/categories';

  // ==== SELECT WALLET ====
  static const String selectWallet = '/selectWallet';
  static const String selectTransferOutWallet = '/selectTransferToWallet';
  static const String selectTransferInWallet = '/selectTransferInWallet';
  static const String typeWalletList = '/typeWalletList';
  static const String bankList = '/bankList';
  static const String personList = '/personList';

  // ===== PHASE 2: GROUP FEATURES (PREPARED) =====
  static const String createGroup = '/create-group';
  static const String groupDetail = '/group/:groupId';
  static const String groupSettlement = '/group/:groupId/settlement';
  static const String groupMembers = '/group/:groupId/members';
}
