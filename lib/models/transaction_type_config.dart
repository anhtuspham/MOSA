import 'package:flutter/material.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/utils/app_colors.dart';

class TransactionTypeConfig {
  final TransactionType type;
  final TransactionCategory category;
  final BalanceEffect balanceEffect;
  final String displayName;
  final Color color;
  final String description;

  const TransactionTypeConfig({
    required this.type,
    required this.category,
    required this.balanceEffect,
    required this.displayName,
    required this.color,
    required this.description,
  });
}

class TransactionTypeManager {
  static const Map<TransactionType, TransactionTypeConfig> _configs = {
    TransactionType.income: TransactionTypeConfig(
      type: TransactionType.income,
      category: TransactionCategory.cashFlow,
      balanceEffect: BalanceEffect.plus,
      displayName: 'Income',
      color: AppColors.income,
      description: 'Money received',
    ),
    TransactionType.expense: TransactionTypeConfig(
      type: TransactionType.expense,
      category: TransactionCategory.cashFlow,
      balanceEffect: BalanceEffect.minus,
      displayName: 'Expense',
      color: AppColors.expense,
      description: 'Money spent',
    ),
    TransactionType.lend: TransactionTypeConfig(
      type: TransactionType.lend,
      category: TransactionCategory.lending,
      balanceEffect: BalanceEffect.minus,
      displayName: 'Lend',
      color: AppColors.expense,
      description: 'Money lent to others',
    ),
    TransactionType.borrowing: TransactionTypeConfig(
      type: TransactionType.borrowing,
      category: TransactionCategory.lending,
      balanceEffect: BalanceEffect.plus,
      displayName: 'Borrowing',
      color: AppColors.income,
      description: 'Money borrowed from others',
    ),
    TransactionType.repayment: TransactionTypeConfig(
      type: TransactionType.repayment,
      category: TransactionCategory.debtCollection,
      balanceEffect: BalanceEffect.minus,
      displayName: 'Repayment',
      color: AppColors.expense,
      description: 'Repayment',
    ),
    TransactionType.debtCollection: TransactionTypeConfig(
      type: TransactionType.debtCollection,
      category: TransactionCategory.debtCollection,
      balanceEffect: BalanceEffect.plus,
      displayName: 'Debt Collection',
      color: AppColors.income,
      description: 'Debt collection',
    ),
    TransactionType.transfer: TransactionTypeConfig(
      type: TransactionType.transfer,
      category: TransactionCategory.transfer,
      balanceEffect: BalanceEffect.neutral,
      displayName: 'Transfer',
      color: AppColors.textPrimary,
      description: 'Transfer between wallets',
    ),
    TransactionType.transferIn: TransactionTypeConfig(
      type: TransactionType.transferIn,
      category: TransactionCategory.transfer,
      balanceEffect: BalanceEffect.neutral,
      displayName: 'Transfer In',
      color: AppColors.textPrimary,
      description: 'Receive transfer from another wallet',
    ),
    TransactionType.transferOut: TransactionTypeConfig(
      type: TransactionType.transferOut,
      category: TransactionCategory.transfer,
      balanceEffect: BalanceEffect.neutral,
      displayName: 'Transfer Out',
      color: AppColors.textPrimary,
      description: 'Send transfer to another wallet',
    ),
    TransactionType.adjustBalance: TransactionTypeConfig(
      type: TransactionType.adjustBalance,
      category: TransactionCategory.adjustment,
      balanceEffect: BalanceEffect.neutral,
      displayName: 'Adjust Balance',
      color: AppColors.primary,
      description: 'Balance adjustment',
    ),
    TransactionType.unknown: TransactionTypeConfig(
      type: TransactionType.unknown,
      category: TransactionCategory.unknown,
      balanceEffect: BalanceEffect.neutral,
      displayName: 'Unknown',
      color: AppColors.textPrimary,
      description: 'Unknown transaction type'
    )
  };

  static TransactionTypeConfig getConfig(TransactionType type) {
    return _configs[type] ?? _configs[TransactionType.expense]!;
  }

  static Color getColor(TransactionType type) {
    return getConfig(type).color;
  }

  static BalanceEffect getBalanceEffect(TransactionType type) {
    return getConfig(type).balanceEffect;
  }

  static TransactionCategory getCategory(TransactionType type) {
    return getConfig(type).category;
  }

  static String getDisplayName(TransactionType type) {
    return getConfig(type).displayName;
  }

  static bool affectsBalance(TransactionType type) {
    return getBalanceEffect(type) != BalanceEffect.neutral;
  }

  static bool increasesBalance(TransactionType type) {
    return getBalanceEffect(type) == BalanceEffect.plus;
  }

  static bool decreasesBalance(TransactionType type) {
    return getBalanceEffect(type) == BalanceEffect.minus;
  }

  static List<TransactionType> getTypesByCategory(
    TransactionCategory category,
  ) {
    return _configs.values
        .where((config) => config.category == category)
        .map((config) => config.type)
        .toList();
  }

  static List<TransactionType> getTypesByBalanceEffect(BalanceEffect effect) {
    return _configs.values
        .where((config) => config.balanceEffect == effect)
        .map((config) => config.type)
        .toList();
  }

  static double calculateBalanceImpact(TransactionType type, double amount) {
    switch (getBalanceEffect(type)) {
      case BalanceEffect.plus:
        return amount;
      case BalanceEffect.minus:
        return -amount;
      case BalanceEffect.neutral:
        return 0.0;
    }
  }
}
