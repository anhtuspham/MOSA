import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/router/app_routes.dart';

import '../../utils/app_colors.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late final ValueNotifier<String> _selectedType = ValueNotifier<String>('Chi tiền');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.history),
          centerTitle: true,
          title: Container(
            alignment: Alignment.center,
            constraints: BoxConstraints(maxWidth: 180),
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                floatingLabelAlignment: FloatingLabelAlignment.center,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              isExpanded: true,
              alignment: Alignment.center,
              value: _selectedType.value,
              items: [
                DropdownMenuItem(value: 'Chi tiền', child: Text('Chi tiền')),
                DropdownMenuItem(value: 'Thu tiền', child: Text('Thu tiền')),
                DropdownMenuItem(value: 'Cho vay', child: Text('Cho vay')),
                DropdownMenuItem(value: 'Chuyển khoản', child: Text('Chuyển khoản')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType.value = value;
                    print('Selected: $value');
                  });
                }
              },
            ),
          ),
          actions: [IconButton(onPressed: null, icon: Icon(Icons.check))],
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            children: [
              ValueListenableBuilder(
                valueListenable: _selectedType,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          children: [
                            Text('Số tiền'),
                            TextField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                suffixText: 'đ',
                                suffixStyle: TextStyle(fontSize: 20, color: AppColors.expense),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                              ),
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: AppColors.expense, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
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
          ),
        ),
      ),
    );
  }
}
