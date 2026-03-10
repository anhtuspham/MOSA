import 'dart:io';

void main() {
  final file = File('lib/providers/debt_provider.dart');
  var lines = file.readAsLinesSync();
  var newLines = <String>[];
  
  for (var i = 0; i < lines.length; i++) {
    newLines.add(lines[i]);
    if (lines[i].contains('syncId: generateSyncId(),')) {
      if (i + 1 < lines.length && !lines[i+1].contains('debtId:')) {
        var spaces = lines[i].substring(0, lines[i].indexOf('syncId'));
        newLines.add(spaces + 'debtId: newDebt.id,');
      }
    }
  }
  
  var content = newLines.join('\r\n');
  content += '\r\n\r\n/// Provider danh sách nợ đã quá hạn\r\nfinal overdueDebtsProvider = FutureProvider<List<Debt>>((ref) async {\r\n  final dbService = ref.read(databaseServiceProvider);\r\n  return await dbService.getOverdueDebts();\r\n});\r\n';
  
  file.writeAsStringSync(content);
  print('Patch 3 applied successfully!');
}
