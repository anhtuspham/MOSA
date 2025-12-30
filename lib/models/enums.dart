enum TransactionType {
  income,
  expense,
  lend, // cho mượn
  borrowing, // đi vay
  repayment, // trả nợ
  debtCollection, // thu nợ
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
  debtCollection, // debt collection
  adjustment, // balance adjustments
  unknown
}

// transferIn là nhận tiền vào
// transferOut là chuyển tiền đi
