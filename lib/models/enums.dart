enum TransactionType {
  income,
  expense,
  lend,
  borrowing,
  transfer,
  transferIn,
  transferOut,
  adjustBalance,
  unknown
}

enum BalanceEffect { plus, minus, neutral }

enum TransactionCategory {
  cashFlow, // income/expense
  transfer, // between wallets
  lending, // lend/borrow
  adjustment, // balance adjustments
  unknown
}

// transferIn là nhận tiền vào
// transferOut là chuyển tiền đi
