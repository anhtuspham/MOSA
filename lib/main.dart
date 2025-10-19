import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/screens/home_screen.dart';
import 'package:mosa/utils/test_data.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionProvider()..loadTransaction(),
      child: MaterialApp(
        title: 'Finance Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const TestDatabaseScreen(),
      ),
    );
  }
}

class TestDatabaseScreen extends StatelessWidget {
  const TestDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Test screen'), backgroundColor: Colors.blue),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('Total transactions ${provider.transactions.length}'),
                Text('Income ${provider.totalIncome}đ'),
                Text('Outcome ${provider.totalExpense}đ'),
                Text('Balance ${provider.balance}đ', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child:
                provider.isLoading
                    ? const CircularProgressIndicator()
                    : ListView.builder(
                      itemCount: provider.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = provider.transactions[index];
                        return ListTile(
                          leading: Icon(
                            transaction.type == 'income'
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: transaction.type == 'income' ? Colors.green : Colors.red,
                          ),
                          title: Text(transaction.title),
                          subtitle: Text(
                            '${transaction.category} - ${transaction.date.day}/${transaction.date.month}',
                          ),
                          trailing: Text(transaction.amount.toString()),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () async {
              final testDummyData = TestData.getDummyTransactions();
              for (var transaction in testDummyData) {
                await provider.addTransaction(transaction);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Thêm dữ liệu thành công')));
              }
            },
            child: Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'clear',
            backgroundColor: Colors.red,
            onPressed: () async {
              final ids = provider.transactions.map((e) => e.id).toList();
              for (var item in ids) {
                await provider.deleteTransaction(item!);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('All data cleared!')));
              }
            },
            child: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
