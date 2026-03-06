import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/wallets.dart';
import 'package:mosa/services/database_service.dart';
import 'package:mosa/services/type_wallet_service.dart';

import 'database_service_provider.dart';

/// Quản lý trạng thái danh sách ví bất đồng bộ
class WalletsNotifier extends AsyncNotifier<List<Wallet>> {
  DatabaseService get _databaseService => ref.read(databaseServiceProvider);

  @override
  FutureOr<List<Wallet>> build() async {
    return await _databaseService.getAllWallets();
  }

  /// Thêm ví mới vào database và cập nhật state
  Future<void> insertWallet(Wallet wallet) async {
    state = const AsyncLoading();

    try {
      int id = await _databaseService.insertWallet(wallet);
      final newWallet = wallet.copyWith(id: id);
      // Cập nhật state ngay khi thêm ví
      state = AsyncData([newWallet, ...state.requireValue]);
      refreshWallet();
    } catch (e) {
      log('Error when insert wallet $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Làm mới danh sách ví từ database
  Future<void> refreshWallet() async {
    try {
      final wallets = await _databaseService.getAllWallets();
      log(
        'Refresh wallet in background: ${state.value?.first.balance} - ${wallets.first.balance}',
      );
      if (state.value != wallets) {
        state = AsyncData(wallets);
      }
    } catch (e) {
      log('Refresh wallet in background have error ${e.toString()}');
    }
  }

  /// Cập nhật thông tin ví
  Future<void> updateWallet(Wallet wallet) async {
    state = const AsyncLoading();
    try {
      await _databaseService.updateWallet(wallet);
      final index = state.requireValue.indexWhere(
        (element) => element == wallet,
      );
      if (index != -1) {
        state = AsyncData([
          ...state.requireValue.sublist(0, index),
          wallet,
          ...state.requireValue.sublist(index + 1),
        ]);
      }
      refreshWallet();
    } catch (e) {
      log('Error when update wallet');
    }
  }

  /// Xóa ví khỏi database
  Future<void> deleteWallet(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final status = await _databaseService.deleteWallet(id);
      if (status <= 0) {
        throw Exception('Không thể xóa ví');
      }
      // Return updated wallet list without the deleted wallet
      return state.requireValue.where((element) => element.id != id).toList();
    });
  }
}

/// Provider chính quản lý danh sách ví
final walletProvider = AsyncNotifierProvider<WalletsNotifier, List<Wallet>>(
  WalletsNotifier.new,
);

/// Lấy ví theo ID
final getWalletByIdProvider = FutureProvider.family<Wallet?, int>((
  ref,
  param,
) async {
  final db = ref.read(databaseServiceProvider);
  return db.getWalletById(param);
});

/// Lấy ví mặc định
final defaultWalletProvider = FutureProvider<Wallet?>((ref) {
  final db = ref.read(databaseServiceProvider);
  return db.getDefaultWallet();
});

/// Lưu trữ ví được chọn hiện tại
final selectedWalletProvider = StateProvider<Wallet?>((ref) => null);

/// Lưu trữ ví chuyển tiền đi
final transferOutWalletProvider = StateProvider<Wallet?>((ref) => null);
/// Lưu trữ ví chuyển tiền đến
final transferInWalletProvider = StateProvider<Wallet?>((ref) => null);

/// Lấy ví hiệu quả (được chọn hoặc mặc định)
final effectiveWalletProvider = FutureProvider<Wallet>((ref) async {
  final selectedWallet = ref.watch(selectedWalletProvider);
  final wallets = await ref.watch(walletProvider.future);

  if (selectedWallet != null) {
    final updateWallets = wallets.firstWhere(
      (wallet) => wallet.id == selectedWallet.id,
    );
    return updateWallets;
  }

  final defaultWallet = wallets.firstWhere(
    (wallet) => wallet.isDefault,
    orElse: () => throw Exception('Không có ví nào để lưu giao dịch'),
  );
  return defaultWallet;
});

/// Tính tổng số dư của tất cả các ví
final totalBalanceWalletProvider = Provider<double>((ref) {
  double total = 0;
  final wallets = ref.watch(walletProvider);
  wallets.when(
    data: (walletsData) {
      for (var wallet in walletsData) {
        total += wallet.balance;
      }
    },
    error: (error, stackTrace) => total = 0.0,
    loading: () => total = 0.0,
  );
  return total;
});

/// Lấy danh sách loại ví
final typeWalletProvider = FutureProvider<List<TypeWallet>>((ref) {
  return TypeWalletService.loadTypeWallets();
});

/// Lưu trữ loại ví được chọn
final selectedTypeWalletProvider = StateProvider<TypeWallet?>((ref) {
  final typeWallets = ref.watch(typeWalletProvider);
  return typeWallets
      .whenData((wallet) => wallet.isNotEmpty ? wallet.first : null)
      .value;
});

/// Quản lý trạng thái danh sách loại ví
class TypeWalletNotifier extends AsyncNotifier<List<TypeWallet>> {
  DatabaseService get _databaseService => ref.read(databaseServiceProvider);

  @override
  FutureOr<List<TypeWallet>> build() {
    return TypeWalletService.loadTypeWallets();
  }

  /// Làm mới danh sách loại ví từ database
  Future<void> refreshTypeWallet() async {
    try {
      final typeWallets = await _databaseService.getAllTypeWallets();
      if (typeWallets != state.value) {
        state = AsyncData(typeWallets);
      }
    } catch (e) {
      log('Error when refresh type wallet $e');
    }
  }

  /// Thêm loại ví mới
  Future<void> addTypeWallet(TypeWallet tp) async {
    state = const AsyncLoading();
    try {
      int id = await _databaseService.insertTypeWallet(tp);
      final newTypeWallet = tp.copyWith(id: id);
      state = AsyncData([newTypeWallet, ...state.requireValue]);
      refreshTypeWallet();
    } catch (e) {
      log('Error when add type wallet $e');
    }
  }

  /// Xóa loại ví
  Future<void> deleteTypeWallet(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _databaseService.deleteTypeWallet(id);
      return state.requireValue.where((element) => element.id != id).toList();
    });
  }
}

final typeWalletNotifier =
    AsyncNotifierProvider<TypeWalletNotifier, List<TypeWallet>>(
      TypeWalletNotifier.new,
    );
