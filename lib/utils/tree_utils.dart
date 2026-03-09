class TreeUtils {
  /// Flatten hierarchical structure with children
  static List<T> flatten<T>(
    List<T> items,
    List<T>? Function(T) childrenGetter,
  ) {
    final result = <T>[];

    for (var item in items) {
      if (!result.contains(item)) {
        result.add(item);
      }

      final children = childrenGetter(item);
      if (children != null && children.isNotEmpty) {
        result.addAll(children);
      }
    }

    return result;
  }

  /// Reconstruct hierarchical tree from flat list
  static List<T> buildTree<T, K>({
    required List<T> items,
    required K? Function(T) parentIdGetter,
    required K Function(T) idGetter,
    required void Function(T, List<T>) childrenSetter,
  }) {
    final Map<K, T> itemMap = {for (var item in items) idGetter(item): item};
    final List<T> roots = [];

    for (var item in items) {
      final parentId = parentIdGetter(item);
      if (parentId == null) {
        roots.add(item);
      } else {
        final parent = itemMap[parentId];
        if (parent != null) {
          // Note: This assumes the list of children is mutable or handled by setter
          // For immutable models, you'd need the setter to return a new object
        } else {
          // If parent not found, treat as root
          roots.add(item);
        }
      }
    }

    // Assign children
    for (var parentId in itemMap.keys) {
      final parent = itemMap[parentId]!;
      final children =
          items.where((item) => parentIdGetter(item) == parentId).toList();
      childrenSetter(parent, children);
    }

    return roots;
  }
}
