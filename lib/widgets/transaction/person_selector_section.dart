import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/person_provider.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/utils/transaction_constants.dart';
import 'package:mosa/widgets/custom_list_tile.dart';

/// Widget for person selection section (for loan transactions)
class PersonSelectorSection extends ConsumerWidget {
  const PersonSelectorSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPerson = ref.watch(selectedPersonProvider);

    return CustomListTile(
      leading: selectedPerson != null
          ? Image.asset(
              selectedPerson.iconPath ?? 'assets/images/icon.png',
              width: 22,
              errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 22),
            )
          : const Icon(Icons.person_add_outlined),
      title: Text(selectedPerson?.name ?? TransactionConstants.selectPerson),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.push(AppRoutes.personList);
      },
    );
  }
}
