import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/bank_provider.dart';
import 'package:mosa/widgets/custom_list_tile.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';
import 'package:mosa/widgets/common_scaffold.dart';
import 'package:mosa/widgets/logo_container.dart';

import '../../../config/app_colors.dart';

class SelectBankScreen extends ConsumerStatefulWidget {
  const SelectBankScreen({super.key});

  @override
  ConsumerState<SelectBankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends ConsumerState<SelectBankScreen> {
  @override
  Widget build(BuildContext context) {
    final bankListState = ref.watch(bankListProvider);
    final selectBankState = ref.watch(selectedBankProvider);

    return CommonScaffold(
      title: Text('Chọn ngân hàng'),
      leading: IconButton(
        onPressed: () {
          context.pop();
        },
        icon: const Icon(Icons.arrow_back),
      ),
      body: bankListState.when(
        data: (banks) {
          return ListView.builder(
            itemCount: banks.length,
            itemBuilder: (context, index) {
              final bank = banks[index];
              final isSelected = selectBankState?.id == bank.id;
              return CustomListTile(
                title: Text(bank.name),
                leading: LogoContainer(assetPath: bank.iconPath, size: 25),
                backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) : null,
                trailing:
                    isSelected ? IconButton(onPressed: null, icon: Icon(Icons.check, color: AppColors.primary)) : null,
                onTap: () {
                  ref.read(selectedBankProvider.notifier).state = bank;
                  context.pop();
                },
              );
            },
          );
        },
        error: (error, stackTrace) => ErrorSectionWidget(error: error),
        loading: () => LoadingSectionWidget(),
      ),
    );
  }
}
