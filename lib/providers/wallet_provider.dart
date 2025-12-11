import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/wallets.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/services/database_service.dart';
import 'package:mosa/utils/app_icons.dart';

class WalletsNotifier extends AsyncNotifier<List<Wallet>> {
  DatabaseService get _databaseService => ref.read(databaseServiceProvider);

  @override
  FutureOr<List<Wallet>> build() async {
    return await _databaseService.getAllWallets();
  }

  Future<void> insertWallet(Wallet wallet) async {
    state = const AsyncLoading();

    try {
      int id = await _databaseService.insertWallet(wallet);
      final newWallet = wallet.copyWith(id: id);
      // update state ngay khi thêm wallet
      state = AsyncData([newWallet, ...state.requireValue]);
      refreshWallet();
    } catch (e) {
      log('Error when insert wallet $e');
    }
  }

  Future<void> refreshWallet() async {
    try {
      final wallets = await _databaseService.getAllWallets();
      if (state.value != wallets) {
        state = AsyncData(wallets);
      }
    } catch (e) {
      log('Refresh wallet in background have error ${e.toString()}');
    }
  }

  Future<void> updateWallet(Wallet wallet) async {
    state = const AsyncLoading();
    try {
      await _databaseService.updateWallet(wallet);
      final index = state.requireValue.indexWhere((element) => element == wallet);
      if (index != -1) {
        state = AsyncData([...state.requireValue.sublist(0, index), wallet, ...state.requireValue.sublist(index + 1)]);
      }
      refreshWallet();
    } catch (e) {
      log('Error when update wallet');
    }
  }

  Future<void> deleteWallet(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _databaseService.deleteWallet(id);
      return state.requireValue.where((element) => element.id != id).toList();
    });
  }
}

final walletProvider = AsyncNotifierProvider<WalletsNotifier, List<Wallet>>(WalletsNotifier.new);

final getWalletByIdProvider = FutureProvider.family<Wallet?, int>((ref, param) async {
  final db = ref.read(databaseServiceProvider);
  return db.getWalletById(param);
});

final defaultWalletProvider = FutureProvider<Wallet?>((ref) {
  final db = ref.read(databaseServiceProvider);
  return db.getDefaultWallet();
});

final selectedWalletProvider = StateProvider<Wallet?>((ref) => null);

final transferOutWalletProvider = StateProvider<Wallet?>((ref) => null);
final transferInWalletProvider = StateProvider<Wallet?>((ref) => null);

final effectiveWalletProvider = FutureProvider<Wallet>((ref) async {
  final selectedWallet = ref.watch(selectedWalletProvider);

  if (selectedWallet != null) {
    return selectedWallet;
  }

  final defaultWallet = await ref.watch(defaultWalletProvider.future);
  if (defaultWallet != null) {
    return defaultWallet;
  }

  throw Exception('Không có ví nào để lưu giao dịch');
});

final totalBalanceWalletProvider = FutureProvider<double>((ref) async {
  double total = 0;
  final wallets = ref.watch(walletProvider);
  wallets.whenData((data) {
    for (var element in data) {
      total += element.balance;
    }
  });
  return total;
});
