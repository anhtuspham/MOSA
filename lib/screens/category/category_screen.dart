import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn hạng mục'),
        leading: IconButton(onPressed: () {
          context.pop();
        }, icon: Icon(Icons.arrow_back)),
        actions: [Icon(Icons.edit_note_sharp), const SizedBox(width: 4), Icon(Icons.filter_list)],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.tab,
          unselectedLabelStyle: TextStyle(color: Colors.white),
          labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          tabs: [Tab(child: Text('Chi tiền')), Tab(child: Text('Thu tiền ')), Tab(child: Text('Vay nợ'))],
        ),
        backgroundColor: Colors.white,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [Center(child: Text('Chi tiền')), Center(child: Text('Thu tiền')), Center(child: Text('Vay nợ'))],
      ),
    );
  }
}
