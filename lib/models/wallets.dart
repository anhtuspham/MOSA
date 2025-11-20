import '../utils/app_icons.dart';

class Wallet {
  final String id;
  final String name;
  final String icon;
  final double balance;

  Wallet({required this.id, required this.name, this.icon = AppIcons.logoCash, required this.balance});
}
