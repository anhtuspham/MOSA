import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/widgets/tab_bar_scaffold.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  @override
  Widget build(BuildContext context) {
    return TabBarScaffold(
      title: Text('Thêm tài khoản'),
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          context.pop();
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: const [Icon(Icons.check)],
      body: Container(),
    );
  }
}
