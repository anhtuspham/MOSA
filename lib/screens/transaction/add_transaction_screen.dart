import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/widgets/custom_list_tile.dart';

import '../../utils/app_colors.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late final ValueNotifier<String> _selectedType = ValueNotifier<String>('Chi tiền');
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.primaryBackground),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primaryBackground,
            leading: Icon(Icons.history),
            centerTitle: true,
            title: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: AppColors.lightBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              constraints: BoxConstraints(maxWidth: 180),
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  // border: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(8),
                  //   borderSide: BorderSide(color: AppColors.lightBorder, width: 1),
                  // ),
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
            decoration: BoxDecoration(color: AppColors.primaryBackground),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            child: ValueListenableBuilder(
              valueListenable: _selectedType,
              builder: (context, value, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                              child: Column(
                                children: [
                                  Text('Số tiền'),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: IntrinsicWidth(
                                          child: TextField(
                                            controller: _amountController,
                                            textAlign: TextAlign.right,
                                            decoration: InputDecoration(
                                              counterText: '',
                                              isDense: true,
                                              border: InputBorder.none,
                                              hintText: '0',
                                              hintStyle: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.expense.withValues(alpha: 0.9),
                                              ),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                            ),
                                            maxLength: 13,
                                            maxLengthEnforcement: MaxLengthEnforcement.none,
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.expense,
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'đ',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.expense,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                              child: Column(
                                children: [
                                  CustomListTile(
                                    leading: Icon(Icons.add_circle_rounded),
                                    title: Text('Chọn hạng mục'),
                                    trailing: Row(
                                      children: [Text('Tất cả'), const SizedBox(width: 12), Icon(Icons.chevron_right)],
                                    ),
                                    onTap: () {
                                      context.push(AppRoutes.categoryList);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                              child: Column(
                                children: [
                                  CustomListTile(
                                    leading: Icon(Icons.money),
                                    title: Text('Zalopay'),
                                    trailing: Icon(Icons.chevron_right),
                                    onTap: () {
                                      context.push(AppRoutes.categoryList);
                                    },
                                  ),
                                  CustomListTile(
                                    leading: Icon(Icons.calendar_month_outlined),
                                    title: Text('Hôm nay - 01/11/2025'),
                                    trailing: Text('22:53'),
                                    onTap: () {
                                      context.push(AppRoutes.categoryList);
                                    },
                                  ),
                                  CustomListTile(
                                    leading: Icon(Icons.notes_sharp),
                                    title: Text(
                                      'Diễn giải',
                                      style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textHint),
                                    ),
                                    onTap: () {
                                      context.push(AppRoutes.categoryList);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(child: Icon(Icons.mic_none_sharp)),
                                  Container(
                                    color: AppColors.borderLight,
                                    width: 1,
                                    height: 50,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                  Expanded(child: Icon(Icons.image_outlined)),
                                  Container(
                                    color: AppColors.borderLight,
                                    width: 1,
                                    height: 50,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                  Expanded(child: Icon(Icons.camera_alt_outlined)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push(AppRoutes.categoryList),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Lưu lại'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
