import 'dart:developer';

import 'package:mosa/models/wallets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../models/enums.dart';
import '../services/category_service.dart';
import '../utils/constants.dart';

class DatabaseService {
  static Database? _database;

  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
      singleInstance: true,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    log('📦 Database upgraded from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      await _migrateToVersion2(db);
    }
    if (oldVersion < 3) {
      await _migrateToVersion3(db);
    }
    if (oldVersion < 4) {
      await _migrateToVersion4(db);
    }
  }

  Future<void> _migrateToVersion2(Database db) async {
    log('Migrating to version 2: category name → categoryId');

    try {
      // 1. Add categoryId column
      await db.execute('ALTER TABLE ${AppConstants.tableTransactions} ADD COLUMN categoryId TEXT');

      // 2. Load categories to create name → id mapping
      final categories = await CategoryService.loadCategories();
      final categoryMap = <String, String>{};

      for (final category in categories) {
        categoryMap[category.name] = category.id;
      }

      // 3. Get all transactions
      final transactions = await db.query(AppConstants.tableTransactions);

      // 4. Update each transaction with categoryId
      for (final transaction in transactions) {
        final categoryName = transaction['category'] as String?;
        final categoryId = categoryName != null ? categoryMap[categoryName] : null;

        if (categoryId != null) {
          await db.update(
            AppConstants.tableTransactions,
            {'categoryId': categoryId},
            where: 'id = ?',
            whereArgs: [transaction['id']],
          );
        } else {
          // If no matching category found, use a default or create one
          log('No category found for: $categoryName');
          await db.update(
            AppConstants.tableTransactions,
            {'categoryId': 'default-category'},
            where: 'id = ?',
            whereArgs: [transaction['id']],
          );
        }
      }

      // 5. Make category column nullable (so we can use categoryId only)
      log('📝 Making category column nullable...');
      // SQLite doesn't support ALTER COLUMN directly, so we need to recreate the table
      // But for simplicity, we just set all category to NULL for now
      await db.execute('UPDATE ${AppConstants.tableTransactions} SET category = NULL');

      log('✅ Migration to version 2 completed');
    } catch (e) {
      log('❌ Migration failed: $e');
      rethrow;
    }
  }

  Future<void> _migrateToVersion3(Database db) async {
    log('🔄 Migrating to version 3: Recreate transactions table with nullable category');

    try {
      // 1. Create a new table with nullable category column
      await db.execute('''
        CREATE TABLE ${AppConstants.tableTransactions}_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          categoryId TEXT,
          wallet TEXT NOT NULL,
          date TEXT NOT NULL,
          type TEXT NOT NULL,
          note TEXT,
          createAt TEXT NOT NULL,
          updateAt TEXT,
          isSynced BOOLEAN NOT NULL DEFAULT FALSE,
          syncId TEXT NOT NULL
        )
      ''');

      // 2. Copy data from old table to new table
      await db.execute('''
        INSERT INTO ${AppConstants.tableTransactions}_new
        SELECT * FROM ${AppConstants.tableTransactions}
      ''');

      // 3. Drop old table
      await db.execute('DROP TABLE ${AppConstants.tableTransactions}');

      // 4. Rename new table to original name
      await db.execute('''
        ALTER TABLE ${AppConstants.tableTransactions}_new
        RENAME TO ${AppConstants.tableTransactions}
      ''');

      log('✅ Migration to version 3 completed');
    } catch (e) {
      log('❌ Migration failed: $e');
      rethrow;
    }
  }

  Future<void> _migrateToVersion4(Database db) async {
    log('🔄 Migrating to version 4: Add wallets table and update transactions');

    try {
      // 1. Enable foreign keys
      await db.execute('PRAGMA foreign_keys = ON');

      // 2. Create wallets table
      await db.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        iconPath TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        type TEXT NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1,
        createAt TEXT NOT NULL,
        updateAt TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0,
        syncId TEXT NOT NULL,
        CHECK (type IN ('cash', 'bank', 'ewallet', 'credit_card'))
      )
    ''');

      // 3. Create indexes
      await db.execute('CREATE INDEX idx_wallet_name ON wallets(name)');
      await db.execute('CREATE INDEX idx_wallet_type ON wallets(type)');
      await db.execute('CREATE INDEX idx_wallet_default ON wallets(isDefault)');
      await db.execute('CREATE INDEX idx_wallet_active ON wallets(isActive)');

      // 4. Seed wallets from JSON
      await _seedWallets(db);

      // 5. Build wallet name → id mapping
      final walletMaps = await db.query('wallets');
      final walletNameToId = <String, int>{};
      int? defaultWalletId;

      for (final map in walletMaps) {
        final name = (map['name'] as String).toLowerCase().trim();
        final id = map['id'] as int;
        walletNameToId[name] = id;
        if ((map['isDefault'] as int) == 1) {
          defaultWalletId = id;
        }
      }

      // 6. Ensure default wallet exists
      if (defaultWalletId == null) {
        log('⚠️ No default wallet found, creating one');
        defaultWalletId = await db.insert('wallets', {
          'name': 'Ví mặc định',
          'iconPath': 'assets/icons/cash.png',
          'balance': 0,
          'type': 'cash',
          'isDefault': 1,
          'isActive': 1,
          'createAt': DateTime.now().toIso8601String(),
          'isSynced': 0,
          'syncId': DateTime.now().millisecondsSinceEpoch.toString(),
        });
        walletNameToId['ví mặc định'] = defaultWalletId;
      }

      // 7. Create new transactions table with walletId
      await db.execute('''
      CREATE TABLE transactions_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        categoryId TEXT,
        walletId INTEGER NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        note TEXT,
        createAt TEXT NOT NULL,
        updateAt TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0,
        syncId TEXT NOT NULL,
        FOREIGN KEY (walletId) REFERENCES wallets(id) ON DELETE RESTRICT
      )
    ''');

      // 8. Copy transactions with wallet name → walletId mapping
      final oldTransactions = await db.query('transactions');
      int unmappedCount = 0;

      for (final transaction in oldTransactions) {
        final walletName = (transaction['wallet'] as String).toLowerCase().trim();
        final walletId = walletNameToId[walletName] ?? defaultWalletId;

        if (walletNameToId[walletName] == null) {
          log('⚠️ Unmapped wallet: "${transaction['wallet']}" → default wallet');
          unmappedCount++;
        }

        final newTransaction = Map<String, dynamic>.from(transaction);
        newTransaction.remove('wallet');
        newTransaction['walletId'] = walletId;

        await db.insert('transactions_new', newTransaction);
      }

      log('📊 Migration stats: ${oldTransactions.length} transactions, $unmappedCount unmapped');

      // 9. Drop old table and rename
      await db.execute('DROP TABLE transactions');
      await db.execute('ALTER TABLE transactions_new RENAME TO transactions');

      // 10. Create transaction indexes
      await db.execute('CREATE INDEX idx_transaction_walletId ON transactions(walletId)');
      await db.execute('CREATE INDEX idx_transaction_date ON transactions(date)');

      log('✅ Migration to version 4 completed');
    } catch (e) {
      log('❌ Migration to version 4 failed: $e');
      rethrow;
    }
  }

  Future<void> _seedWallets(Database db) async {
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM wallets'));

    if (count! > 0) {
      log('Wallets existed, skip');
      return;
    }

    final jsonString = await rootBundle.loadString('assets/data/wallets.json');
    final List<dynamic> jsonData = jsonDecode(jsonString);

    for (var data in jsonData) {
      final wallet = Wallet.fromJson(data);
      await db.insert(AppConstants.tableWallets, wallet.toMap());
    }
    log('Wallets seeded');
  }

  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    log('📦 Database downgraded from version $oldVersion to $newVersion');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableWallets}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        iconPath TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        type TEXT NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1,
        createAt TEXT NOT NULL,
        updateAt TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0,
        syncId TEXT NOT NULL,
        CHECK (type IN ('cash', 'bank', 'ewallet', 'credit_card'))
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableTransactions} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        categoryId TEXT,
        walletId INTEGER NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        note TEXT,
        createAt TEXT NOT NULL,
        updateAt TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0,
        syncId TEXT NOT NULL,
        FOREIGN KEY (walletId) REFERENCES wallets(id) ON DELETE RESTRICT
      )
    ''');

    // create indexes for fast lookup
    await db.execute('CREATE INDEX idx_wallet_name ON wallets(name)');
    await db.execute('CREATE INDEX idx_wallet_type ON wallets(type)');
    await db.execute('CREATE INDEX idx_wallet_default ON wallets(isDefault)');
    await db.execute('CREATE INDEX idx_wallet_active ON wallets(isActive)');
    await db.execute('CREATE INDEX idx_transaction_walletId ON transactions(walletId)');
    await db.execute('CREATE INDEX idx_transaction_date ON transactions(date)');

    await _seedWallets(db);

    log('✅ Database created successfully');
  }

  // CREATE
  Future<int> insertTransaction(TransactionModel transaction) async {
    try {
      final db = await database;
      final id = await db.insert(
        AppConstants.tableTransactions,
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      log('✅ Transaction inserted with id: $id');
      return id;
    } catch (e) {
      // Database lock issue - reset and retry
      if (e.toString().contains('readonly')) {
        log('⚠️ Database readonly error, attempting to reset...');
        await _resetDatabase();
        return await insertTransaction(transaction); // Retry once
      }
      rethrow;
    }
  }

  // Reset database instance
  Future<void> _resetDatabase() async {
    if (_database != null) {
      await _database!.close();
    }
    _database = null;
  }

  // READ ALL
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(AppConstants.tableTransactions, orderBy: 'date DESC');

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  // READ BY ID
  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return TransactionModel.fromMap(maps.first);
  }

  // UPDATE
  Future<int> updateTransaction(TransactionModel transaction) async {
    try {
      final db = await database;
      final count = await db.update(
        AppConstants.tableTransactions,
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      log('✅ Transaction updated: $count rows affected');
      return count;
    } catch (e) {
      if (e.toString().contains('readonly')) {
        log('⚠️ Database readonly error, attempting to reset...');
        await _resetDatabase();
        return await updateTransaction(transaction);
      }
      rethrow;
    }
  }

  // DELETE
  Future<int> deleteTransaction(int id) async {
    try {
      final db = await database;
      final count = await db.delete(AppConstants.tableTransactions, where: 'id = ?', whereArgs: [id]);
      log('✅ Transaction deleted: $count rows affected');
      return count;
    } catch (e) {
      if (e.toString().contains('readonly')) {
        log('⚠️ Database readonly error, attempting to reset...');
        await _resetDatabase();
        return await deleteTransaction(id);
      }
      rethrow;
    }
  }

  // FILTER by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableTransactions,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  // FILTER by type
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableTransactions,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // CLEAR DATABASE - Delete entire database file
  Future<void> clearDatabase() async {
    try {
      // Close the current database connection if it exists
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      
      // Get the database path and delete the file
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, AppConstants.dbName);
      await deleteDatabase(path);
      
      log('✅ Database file deleted successfully. Will be recreated on next access.');
    } catch (e) {
      log('❌ Clear database failed: $e');
      rethrow;
    }
  }

  // IMPORT DATABASE - Load transactions from JSON file in assets
  Future<void> importTransactionsFromAssets(String assetPath) async {
    try {
      // Load JSON file
      final jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = jsonDecode(jsonString);

      log('📥 Importing ${jsonList.length} transactions from $assetPath');

      // Convert JSON to TransactionModel and insert
      for (final json in jsonList) {
        final transaction = _parseTransactionFromJson(json);
        await insertTransaction(transaction);
      }

      log('✅ Database imported successfully from $assetPath');
    } catch (e) {
      log('❌ Import failed: $e');
      rethrow;
    }
  }

  // IMPORT DATABASE - Load transactions from JSON string
  Future<void> importDatabaseFromJsonString(String jsonString) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);

      log('📥 Importing ${jsonList.length} transactions');

      for (final json in jsonList) {
        final transaction = _parseTransactionFromJson(json);
        await insertTransaction(transaction);
      }

      log('✅ Database imported successfully');
    } catch (e) {
      log('❌ Import failed: $e');
      rethrow;
    }
  }

  // Parse transaction from JSON
  TransactionModel _parseTransactionFromJson(Map<String, dynamic> json) {
    return TransactionModel(
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      walletId: json['walletId'] as int,
      date: DateTime.parse(json['date'] as String),
      type: _getTransactionType(json['type'] as String),
      note: json['note'] as String?,
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
      syncId: json['syncId'] as String? ?? '',
    );
  }

  // Helper function to convert category type string to TransactionType enum
  TransactionType _getTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      case 'lend':
        return TransactionType.lend;
      case 'borrowing':
        return TransactionType.borrowing;
      default:
        return TransactionType.expense;
    }
  }

  // ==================== WALLET OPERATIONS ====================

/// Get all wallets (active only by default)
Future<List<Wallet>> getAllWallets({bool includeInactive = false}) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    AppConstants.tableWallets,
    where: includeInactive ? null : 'isActive = ?',
    whereArgs: includeInactive ? null : [1],
    orderBy: 'isDefault DESC, name ASC',
  );

  return List.generate(maps.length, (i) => Wallet.fromMap(maps[i]));
}

/// Get wallet by ID
Future<Wallet?> getWalletById(int id) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    AppConstants.tableWallets,
    where: 'id = ?',
    whereArgs: [id],
  );

  if (maps.isEmpty) return null;
  return Wallet.fromMap(maps.first);
}

/// Get default wallet
Future<Wallet?> getDefaultWallet() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    AppConstants.tableWallets,
    where: 'isDefault = ? AND isActive = ?',
    whereArgs: [1, 1],
    limit: 1,
  );

  if (maps.isEmpty) {
    // Fallback: return first active wallet
    final allMaps = await db.query(
      AppConstants.tableWallets,
      where: 'isActive = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (allMaps.isEmpty) return null;
    return Wallet.fromMap(allMaps.first);
  }

  return Wallet.fromMap(maps.first);
}

/// Calculate wallet balance from transactions
Future<double> getWalletBalance(int walletId) async {
  final db = await database;
  final result = await db.rawQuery('''
    SELECT
      SUM(CASE
        WHEN type IN ('income', 'borrowing') THEN amount
        WHEN type IN ('expense', 'lend') THEN -amount
        ELSE 0
      END) as balance
    FROM ${AppConstants.tableTransactions}
    WHERE walletId = ?
  ''', [walletId]);

  return (result.first['balance'] as num?)?.toDouble() ?? 0.0;
}

/// Insert new wallet
Future<int> insertWallet(Wallet wallet) async {
  try {
    final db = await database;
    final id = await db.insert(
      AppConstants.tableWallets,
      wallet.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log('✅ Wallet inserted with id: $id');
    return id;
  } catch (e) {
    log('❌ Insert wallet failed: $e');
    rethrow;
  }
}

/// Update wallet
Future<int> updateWallet(Wallet wallet) async {
  try {
    final db = await database;
    final count = await db.update(
      AppConstants.tableWallets,
      wallet.toMap(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
    log('✅ Wallet updated: $count rows affected');
    return count;
  } catch (e) {
    log('❌ Update wallet failed: $e');
    rethrow;
  }
}

/// Soft delete wallet (set isActive = 0)
Future<int> deactivateWallet(int id) async {
  try {
    final db = await database;
    final count = await db.update(
      AppConstants.tableWallets,
      {'isActive': 0, 'updateAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
    log('✅ Wallet deactivated: $count rows affected');
    return count;
  } catch (e) {
    log('❌ Deactivate wallet failed: $e');
    rethrow;
  }
}

/// Hard delete wallet (only if no transactions exist)
Future<int> deleteWallet(int id) async {
  try {
    final db = await database;

    // Check if wallet has transactions
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableTransactions} WHERE walletId = ?',
      [id],
    );
    final transactionCount = Sqflite.firstIntValue(result) ?? 0;

    if (transactionCount > 0) {
      throw Exception(
        'Cannot delete wallet with $transactionCount transaction(s). '
        'Please deactivate instead or move transactions to another wallet.'
      );
    }

    final count = await db.delete(
      AppConstants.tableWallets,
      where: 'id = ?',
      whereArgs: [id],
    );
    log('✅ Wallet deleted: $count rows affected');
    return count;
  } catch (e) {
    log('❌ Delete wallet failed: $e');
    rethrow;
  }
}

/// Restore deactivated wallet
Future<int> activateWallet(int id) async {
  try {
    final db = await database;
    final count = await db.update(
      AppConstants.tableWallets,
      {'isActive': 1, 'updateAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
    log('✅ Wallet activated: $count rows affected');
    return count;
  } catch (e) {
    log('❌ Activate wallet failed: $e');
    rethrow;
  }
}

/// Set wallet as default (unsets all others)
Future<void> setDefaultWallet(int id) async {
  try {
    final db = await database;

    // Unset all defaults
    await db.update(
      AppConstants.tableWallets,
      {'isDefault': 0},
    );

    // Set new default
    await db.update(
      AppConstants.tableWallets,
      {'isDefault': 1, 'updateAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );

    log('✅ Default wallet set to id: $id');
  } catch (e) {
    log('❌ Set default wallet failed: $e');
    rethrow;
  }
}

/// Delete wallets table completely (DROP TABLE)
Future<void> deleteWalletTable() async {
  try {
    final db = await database;
    
    // Drop the wallets table
    await db.execute('DROP TABLE IF EXISTS ${AppConstants.tableWallets}');
    
    log('✅ Wallets table deleted successfully');
    
    // Note: After dropping the table, you'll need to recreate it
    // by either calling _onCreate or upgrading the database version
  } catch (e) {
    log('❌ Delete wallet table failed: $e');
    rethrow;
  }
}
}
