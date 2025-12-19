class CollectionUtils {
  /// Generic grouping by key
  static Map<K, List<V>> groupBy<K, V>(
    Iterable<V> items,
    K Function(V) keySelector,
  ) {
    final grouped = <K, List<V>>{};
    for (var item in items) {
      final key = keySelector(item);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  /// Group and sort by key
  static Map<K, List<V>> groupByAndSort<K extends Comparable, V>(
    Iterable<V> items,
    K Function(V) keySelector, {
    bool descending = false,
  }) {
    final grouped = groupBy(items, keySelector);
    final sortedKeys =
        grouped.keys.toList()
          ..sort((a, b) => descending ? b.compareTo(a) : a.compareTo(b));
    return Map.fromEntries(sortedKeys.map((e) => MapEntry(e, grouped[e]!)));
  }

  /// Safe lookup with fallback
  static T? safeLookup<T>(List<T> collections, bool Function(T) predicate) {
    try {
      return collections.firstWhere(predicate);
    } catch (e) {
      return null;
    }
  }
}
