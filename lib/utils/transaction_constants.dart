/// Constants for transaction-related strings and messages
class TransactionConstants {
  // Transaction type labels
  static const String expense = 'Chi tiền';
  static const String income = 'Thu tiền';
  static const String lend = 'Cho vay';
  static const String borrowing = 'Đi vay';
  static const String transfer = 'Chuyển khoản';
  static const String adjustBalance = 'Điều chỉnh số dư';

  // Section titles
  static const String amountLabel = 'Số tiền';
  static const String fromAccountLabel = 'Từ tài khoản';
  static const String toAccountLabel = 'Đến tài khoản';
  static const String balanceOnAccount = 'Số dư trên tài khoản';
  static const String actualBalance = 'Số dư thực tế';
  static const String received = 'Đã thu';
  static const String spent = 'Đã chi';
  static const String selectCategory = 'Chọn hạng mục';
  static const String selectPerson = 'Chọn người';
  static const String selectAccount = 'Chọn tài khoản';
  static const String notes = 'Diễn giải';
  static const String allCategories = 'Tất cả';
  static const String debtCollectionDate = 'Ngày thu nợ';
  static const String debtRepaymentDate = 'Ngày trả nợ';

  // Validation messages
  static const String errorEnterAmount = 'Vui lòng nhập số tiền';
  static const String errorInvalidAmount = 'Số tiền không hợp lệ';
  static const String errorSelectCategory = 'Vui lòng chọn hạng mục';
  static const String errorSelectPerson = 'Vui lòng chọn người';
  static const String errorSelectDebt = 'Vui lòng chọn khoản nợ';
  static const String errorSelectSourceAccount = 'Vui lòng chọn tài khoản nguồn';
  static const String errorSelectDestAccount = 'Vui lòng chọn tài khoản đích';
  static const String errorSameAccount = 'Không thể chuyển khoản vào cùng một tài khoản';
  static const String errorBalanceEqual = 'Số dư thực tế giống với số dư hiện tại';
  static const String errorSelectDebtToCollect = 'Vui lòng chọn khoản nợ cần thu';
  static const String errorSelectDebtToRepay = 'Vui lòng chọn khoản nợ cần trả';

  // Success messages
  static const String successTitle = 'Thành công';
  static const String successSaveTransaction = 'Đã lưu giao dịch';
  
  // Error messages
  static const String errorTitle = 'Thất bại';
  static const String errorSaveTransaction = 'Lỗi khi lưu giao dịch';

  // Transaction titles
  static const String adjustBalanceTitle = 'Điều chỉnh số dư';
  static String transferToTitle(String walletName) => 'Chuyển khoản đến $walletName';
  static String transferFromTitle(String walletName) => 'Nhận chuyển khoản từ $walletName';
  static String transactionWithPerson(String personName) => 'Giao dịch với $personName';
  static String payDebtTitle(String description) => 'Thanh toán nợ: $description';
  static String unselected(String item) => 'Chưa chọn $item';

  // Hints
  static const String enterActualBalance = 'Nhập số dư thực tế';
  static const String notSelectedDebt = 'Chưa chọn khoản nợ';
  static const String selectFromList = 'Vui lòng chọn từ danh mục';
  
  // Currency
  static const String currencySymbol = 'đ';
}
