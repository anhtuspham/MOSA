import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/database_service.dart';

/// Provider cung cấp singleton DatabaseService
final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService(),
);
