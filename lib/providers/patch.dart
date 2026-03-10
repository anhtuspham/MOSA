import 'dart:io';

void main() {
  final file = File('lib/providers/debt_provider.dart');
  var content = file.readAsStringSync();
  
  // Replace in createDebt (lendTransaction and borrowingTransaction)
  // Replace in payDebt
  // Replace in collectDebt
  // We can just find `syncId: generateSyncId(),\n      );` 
  // and replace it with `syncId: generateSyncId(),\n        debtId: newDebt.id,\n      );`
  
  // But wait, in `createDebt` it's `syncId: generateSyncId(),\n      );`
  // Actually, we can use a RegExp to find the exact block and inject `debtId: newDebt.id,`

  content = content.replaceAll(
    'syncId: generateSyncId(),\r\n      );', 
    'syncId: generateSyncId(),\r\n        debtId: newDebt.id,\r\n      );'
  );
  
  content = content.replaceAll(
    'syncId: generateSyncId(),\n      );', 
    'syncId: generateSyncId(),\n        debtId: newDebt.id,\n      );'
  );

  file.writeAsStringSync(content);
  print('Done replacing!');
}
