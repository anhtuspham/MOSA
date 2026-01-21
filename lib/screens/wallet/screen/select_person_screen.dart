import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/models/person.dart';
import 'package:mosa/providers/person_provider.dart';
import 'package:mosa/widgets/custom_list_tile.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';
import 'package:mosa/widgets/tab_bar_scaffold.dart';
import '../../../utils/app_colors.dart';

class SelectPersonScreen extends ConsumerStatefulWidget {
  const SelectPersonScreen({super.key});

  @override
  ConsumerState<SelectPersonScreen> createState() => _SelectPersonScreenState();
}

class _SelectPersonScreenState extends ConsumerState<SelectPersonScreen> {
  @override
  Widget build(BuildContext context) {
    final personListState = ref.watch(personProvider);
    final selectedPerson = ref.watch(selectedPersonProvider);

    return CommonScaffold(
      title: Text('Chọn người'),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        // Add person button
        IconButton(
          onPressed: () => _showAddPersonDialog(context),
          icon: const Icon(Icons.add),
          tooltip: 'Thêm người mới',
        ),
      ],
      body: personListState.when(
        data: (persons) {
          if (persons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text('Chưa có người nào', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddPersonDialog(context),
                    icon: Icon(Icons.add),
                    label: Text('Thêm người mới'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: persons.length,
            itemBuilder: (context, index) {
              final person = persons[index];
              final isSelected = selectedPerson?.id == person.id;

              return CustomListTile(
                title: Text(person.name),
                leading: Image.asset(
                  person.iconPath ?? 'assets/images/icon.png',
                  width: 30,
                  errorBuilder: (_, __, ___) => Icon(Icons.person, size: 30),
                ),
                backgroundColor: isSelected ? AppColors.lightBackGroundColor : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit button
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _showEditPersonDialog(context, person),
                    ),
                    // Selection checkmark
                    if (isSelected)
                      Icon(Icons.check, color: AppColors.primary),
                  ],
                ),

                onTap: () {
                  ref.read(selectedPersonProvider.notifier).state = person;
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

  void _showAddPersonDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm người mới'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Tên người',
            hintText: 'Nhập tên người',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vui lòng nhập tên')),
                );
                return;
              }

              try {
                final newPerson = Person(
                  id: 0, // Will be assigned by database
                  name: name,
                  iconPath: 'assets/icons/person_default.png',
                );

                await ref.read(personProvider.notifier).addPerson(newPerson);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã thêm $name')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${e.toString()}')),
                  );
                }
              }
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditPersonDialog(BuildContext context, Person person) {
    final nameController = TextEditingController(text: person.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sửa thông tin'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Tên người',
            hintText: 'Nhập tên người',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vui lòng nhập tên')),
                );
                return;
              }

              try {
                final updatedPerson = person.copyWith(name: name);
                await ref.read(personProvider.notifier).updatePerson(updatedPerson);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã cập nhật')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${e.toString()}')),
                  );
                }
              }
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
