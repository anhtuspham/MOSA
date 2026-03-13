import os
import re

directories = [
    "lib/screens",
    "lib/widgets"
]

replacements = [
    # Backgrounds
    (r"AppColors\.lightBackGroundColor", "Theme.of(context).colorScheme.surfaceContainerHighest"),
    (r"AppColors\.firstBackGroundColor", "Theme.of(context).colorScheme.surface"),
    (r"AppColors\.background", "Theme.of(context).colorScheme.surface"),
    (r"AppColors\.surface", "Theme.of(context).colorScheme.surface"),
    (r"AppColors\.secondaryBackground", "Theme.of(context).colorScheme.surfaceContainer"),
    (r"AppColors\.primaryBackground", "Theme.of(context).colorScheme.surfaceContainer"),
    # Texts
    (r"AppColors\.textPrimary", "Theme.of(context).colorScheme.onSurface"),
    (r"AppColors\.textSecondary", "Theme.of(context).colorScheme.onSurfaceVariant"),
    (r"AppColors\.textHint", "Theme.of(context).colorScheme.onSurfaceVariant"),
    (r"AppColors\.textWhite", "Theme.of(context).colorScheme.onPrimary"),
    # Borders
    (r"AppColors\.border(?!Light|Lighter)", "Theme.of(context).colorScheme.outline"),
    (r"AppColors\.borderLight(?!er)", "Theme.of(context).colorScheme.outlineVariant"),
    (r"AppColors\.borderLighter", "Theme.of(context).colorScheme.outlineVariant"),
    (r"AppColors\.lightBorder", "Theme.of(context).colorScheme.outlineVariant"),
    (r"AppColors\.lineColor", "Theme.of(context).colorScheme.outline"),
    # Primary Elements
    (r"AppColors\.primary(?!\w)", "Theme.of(context).colorScheme.primary"),
    (r"AppColors\.buttonPrimary", "Theme.of(context).colorScheme.primary"),
    # Colors class
    (r"Colors\.black(?![0-9a-zA-Z])", "Theme.of(context).colorScheme.onSurface"),
    (r"Colors\.black87", "Theme.of(context).colorScheme.onSurface"),
    (r"Colors\.black54", "Theme.of(context).colorScheme.onSurfaceVariant"),
    (r"Colors\.black45", "Theme.of(context).colorScheme.onSurfaceVariant"),
    (r"Colors\.grey(?![a-zA-Z0-9\[])", "Theme.of(context).colorScheme.onSurfaceVariant"),
    (r"Colors\.grey\[[0-9]+\]", "Theme.of(context).colorScheme.outlineVariant"),
]

def process_file(filepath):
    if not filepath.endswith(".dart"):
        return
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    for old, new in replacements:
        new_content = re.sub(old, new, new_content)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for path in directories:
    if os.path.isfile(path):
        process_file(path)
    elif os.path.isdir(path):
        for root, dirs, files in os.walk(path):
            for file in files:
                process_file(os.path.join(root, file))
