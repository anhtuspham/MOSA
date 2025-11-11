import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/wallets.dart';
import 'package:mosa/utils/app_icons.dart';

class SelectedWalletNotifier extends StateNotifier<Wallet?> {
  SelectedWalletNotifier() : super(Wallet(id: '1', name: 'MB Bank', icon: AppIcons.logoMbBank, balance: 913.024));

  void selectWallet(Wallet wallet) {
    state = wallet;
  }

  void resetWallet(Wallet wallet) {
    state = null;
  }
}

final selectedWalletNotifier = StateNotifierProvider<SelectedWalletNotifier, Wallet?>((ref) {
  return SelectedWalletNotifier();
});

final walletsProvider = Provider<List<Wallet>>((ref) {
  return [
    Wallet(id: '1', name: 'MB Bank', icon: AppIcons.logoMbBank, balance: 913.024),
    Wallet(id: '2', name: 'Tiền mặt', icon: AppIcons.logoCash, balance: 913.024),
    Wallet(id: '3', name: 'Momo', icon: AppIcons.logoMomo, balance: 913.024),
    Wallet(id: '4', name: 'Zalopay', icon: AppIcons.logoZalopay, balance: 913.024),
  ];
});
