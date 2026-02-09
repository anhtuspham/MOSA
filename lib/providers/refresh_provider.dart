import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/providers/debt_provider.dart';
import 'package:mosa/providers/person_provider.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/providers/wallet_provider.dart';

final refreshAllProvider = AsyncNotifierProvider<RefreshAllNotifier, void>(RefreshAllNotifier.new);

class RefreshAllNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.wait([
        ref.read(categoriesProvider.notifier).refreshCategories(),
        ref.read(transactionProvider.notifier).refreshTransactions(),
        ref.read(walletProvider.notifier).refreshWallet(),
        ref.read(personProvider.notifier).refreshPersons(),
        ref.read(debtProvider.notifier).refreshListDebt(),
      ]);
    });
  }
}
