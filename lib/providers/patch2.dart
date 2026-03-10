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
  
  file.writeAsStringSync(newLines.join('\r\n'));
  print('Patch applied successfully!');
}
