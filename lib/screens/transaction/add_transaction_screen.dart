import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/router/app_routes.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late final ValueNotifier<String> _selectedType = ValueNotifier<String>('Chi tiền');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton(
          value: _selectedType.value,
          items: [
            DropdownMenuItem(value: 'Chi tiền',child: Text('Chi tiền'),),
            DropdownMenuItem(value: 'Thu tiền', child: Text('Thu tiền')),
            DropdownMenuItem(value: 'Cho vay', child: Text('Cho vay')),
            DropdownMenuItem(value: 'Chuyển khoản', child: Text('Chuyển khoản')),
          ],
          onChanged: (value) {
            if(value != null){
              _selectedType.value = value;
              print('Selected: $value');
            }
          },

        ),
        ValueListenableBuilder(
          valueListenable: _selectedType,
          builder: (context, value, child) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  child: Column(children: [Text('Số tiền'), TextField(decoration: InputDecoration(suffixText: 'đ'))]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      InkWell(
                        child: ListTile(
                          leading: Icon(Icons.question_mark_outlined),
                          trailing: TextButton.icon(
                            onPressed: null,
                            label: Text('Tất cả'),
                            icon: Icon(Icons.keyboard_arrow_right),
                          ),
                          title: Text('Chọn hạng mục'),
                        ),
                        onTap: () {
                          context.push(AppRoutes.categoryList);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
