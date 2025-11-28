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
}