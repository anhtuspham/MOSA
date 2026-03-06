/// Loại giao dịch: thu nhập, chi tiêu, cho vay, đi vay, trả nợ, thu nợ, chuyển tiền, điều chỉnh số dư
enum TransactionType {
  income,
  expense,
  lend,
  borrowing,
  repayment,
  debtCollection,
  transfer,
  transferIn,
  transferOut,
  adjustBalance,
  unknown,
}

/// Ảnh hưởng đến số dư: cộng, trừ, trung tính
enum BalanceEffect { plus, minus, neutral }

/// Danh mục giao dịch: dòng tiền, chuyển tiền, cho vay, thu nợ, điều chỉnh
enum TransactionCategory {
  cashFlow,
  transfer,
  lending,
  debtCollection,
  adjustment,
  unknown,
}
