// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mosa/providers/category_provider.dart';
// import 'package:mosa/utils/app_colors.dart';
// import 'package:mosa/utils/app_icons.dart';
// import 'package:mosa/widgets/category_grid_view.dart';
// import 'package:mosa/widgets/custom_expansion_tile.dart';
// import 'package:mosa/widgets/item_widget.dart';
// import 'package:mosa/widgets/search_bar_widget.dart';
//
// class ExpenseCategoryScreen extends ConsumerStatefulWidget {
//   const ExpenseCategoryScreen({super.key});
//
//   @override
//   ConsumerState<ExpenseCategoryScreen> createState() => _ExpenseCategoryScreenState();
// }
//
// class _ExpenseCategoryScreenState extends ConsumerState<ExpenseCategoryScreen> {
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final categoryByTypeNotifier = ref.watch(categoryByTypeProvider);
//
//     return Container(
//       decoration: BoxDecoration(color: AppColors.background),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//               child: SearchBarWidget(
//                 onChange: (value) {
//                   log(value);
//                 },
//                 onClear: () => print('Clear text'),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Hay dùng'),
//                   const SizedBox(height: 12),
//                   SingleChildScrollView(
//                     controller: _scrollController,
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: List.generate(15, (index) {
//                         return ItemWidget(itemId: '1', iconPath: AppIcons.statisticIcon, title: 'Quỹ nhóm');
//                       }),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             CustomExpansionTile(
//               title: Row(children: [Icon(Icons.card_giftcard_rounded), const SizedBox(width: 4), Text('Người yêu')]),
//               children: [
//                 CategoryGridView(
//                   categories: [
//                     ItemWidget(itemId: '1', iconPath: AppIcons.statisticIcon, title: 'Ăn sáng'),
//                     ItemWidget(itemId: '2', iconPath: AppIcons.statisticIcon, title: 'Ăn trưa'),
//                     ItemWidget(itemId: '3', iconPath: AppIcons.statisticIcon, title: 'Ăn chiều'),
//                     ItemWidget(itemId: '4', iconPath: AppIcons.statisticIcon, title: 'Ăn tối'),
//                     ItemWidget(itemId: '5', iconPath: AppIcons.statisticIcon, title: 'Đồ uống'),
//                     ItemWidget(itemId: '6', iconPath: AppIcons.statisticIcon, title: 'Khác'),
//                   ],
//                 ),
//               ],
//             ),
//             CustomExpansionTile(
//               title: Row(
//                 children: [Image.asset(AppIcons.logoZalopay, width: 22), const SizedBox(width: 4), Text('Ăn uống')],
//               ),
//               children: [
//                 CategoryGridView(
//                   categories: [
//                     ItemWidget(itemId: '1', iconPath: AppIcons.statisticIcon, title: 'Ăn sáng'),
//                     ItemWidget(itemId: '2', iconPath: AppIcons.statisticIcon, title: 'Ăn trưa'),
//                     ItemWidget(itemId: '3', iconPath: AppIcons.statisticIcon, title: 'Ăn chiều'),
//                     ItemWidget(itemId: '4', iconPath: AppIcons.statisticIcon, title: 'Ăn tối'),
//                     ItemWidget(itemId: '5', iconPath: AppIcons.statisticIcon, title: 'Đồ uống'),
//                     ItemWidget(itemId: '6', iconPath: AppIcons.statisticIcon, title: 'Khác'),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
