import 'dart:io';

void main() {
  final directories = [
    'lib/screens',
    'lib/widgets',
  ];

  final replacements = {
    // Backgrounds
    RegExp(r'AppColors\.lightBackGroundColor'): 'Theme.of(context).colorScheme.surfaceContainerHighest',
    RegExp(r'AppColors\.firstBackGroundColor'): 'Theme.of(context).colorScheme.surface',
    RegExp(r'AppColors\.background'): 'Theme.of(context).colorScheme.surface',
    RegExp(r'AppColors\.surface'): 'Theme.of(context).colorScheme.surface',
    RegExp(r'AppColors\.secondaryBackground'): 'Theme.of(context).colorScheme.surfaceContainer',
    RegExp(r'AppColors\.primaryBackground'): 'Theme.of(context).colorScheme.surfaceContainer',
    // Texts
    RegExp(r'AppColors\.textPrimary'): 'Theme.of(context).colorScheme.onSurface',
    RegExp(r'AppColors\.textSecondary'): 'Theme.of(context).colorScheme.onSurfaceVariant',
    RegExp(r'AppColors\.textHint'): 'Theme.of(context).colorScheme.onSurfaceVariant',
    RegExp(r'AppColors\.textWhite'): 'Theme.of(context).colorScheme.onPrimary',
    // Borders
    RegExp(r'AppColors\.border(?!Light|Lighter)'): 'Theme.of(context).colorScheme.outline',
    RegExp(r'AppColors\.borderLight(?!er)'): 'Theme.of(context).colorScheme.outlineVariant',
    RegExp(r'AppColors\.borderLighter'): 'Theme.of(context).colorScheme.outlineVariant',
    RegExp(r'AppColors\.lightBorder'): 'Theme.of(context).colorScheme.outlineVariant',
    RegExp(r'AppColors\.lineColor'): 'Theme.of(context).colorScheme.outline',
    // Primary Elements
    RegExp(r'AppColors\.primary(?!\w)'): 'Theme.of(context).colorScheme.primary',
    RegExp(r'AppColors\.buttonPrimary'): 'Theme.of(context).colorScheme.primary',
    // Colors class
    RegExp(r'Colors\.black(?![0-9a-zA-Z])'): 'Theme.of(context).colorScheme.onSurface',
    RegExp(r'Colors\.black87'): 'Theme.of(context).colorScheme.onSurface',
    RegExp(r'Colors\.black54'): 'Theme.of(context).colorScheme.onSurfaceVariant',
    RegExp(r'Colors\.black45'): 'Theme.of(context).colorScheme.onSurfaceVariant',
    RegExp(r'Colors\.grey(?![a-zA-Z0-9\[])'): 'Theme.of(context).colorScheme.onSurfaceVariant',
    RegExp(r'Colors\.grey\[[0-9]+\]'): 'Theme.of(context).colorScheme.outlineVariant',
  };

  void processFile(File file) {
    if (!file.path.endsWith('.dart')) return;
    
    final content = file.readAsStringSync();
    var newContent = content;
    
    replacements.forEach((pattern, replacement) {
      newContent = newContent.replaceAll(pattern, replacement);
    });
    
    if (newContent != content) {
      file.writeAsStringSync(newContent);
      print('Updated ${file.path}');
    }
  }

  for (final path in directories) {
    final dir = Directory(path);
    if (!dir.existsSync()) continue;
    
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File) {
        processFile(entity);
      }
    }
  }
}
