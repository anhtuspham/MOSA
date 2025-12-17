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
import '../utils/utils.dart';

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
    // For clean upgrade, drop all tables and recreate
    await _recreateDatabase(db);
  }

  Future<void> _recreateDatabase(Database db) async {
    log('🔄 Recreating database with latest schema');
    
    try {
      // Drop all existing tables
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.tableTransactions}');
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.tableWallets}');
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.tableTypeWallets}');
      
      // Recreate with latest schema
      await _createLatestSchema(db);
      
      log('Database recreated successfully');
    } catch (e) {
      log('Database recreation failed: $e');
      rethrow;
    }
  }

  Future<void> _seedTypeWallets(Database db) async {
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tableTypeWallets}'));

    if (count! > 0) {
      log('Type wallets existed, skip');
      return;
    }

    // Seed default type wallets
    final typeWallets = [
      {'id': 1, 'name': 'Tiền mặt', 'iconPath': 'assets/icons/cash.png'},
      {'id': 2, 'name': 'Ngân hàng', 'iconPath': 'assets/icons/bank.png'},
      {'id': 3, 'name': 'Ví điện tử', 'iconPath': 'assets/icons/ewallet.png'},
      {'id': 4, 'name': 'Thẻ tín dụng', 'iconPath': 'assets/icons/credit_card.png'},
    ];

    for (var data in typeWallets) {
      await db.insert(AppConstants.tableTypeWallets, data);
    }
    log('Type wallets seeded');
  }

  Future<void> _seedWallets(Database db) async {
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tableWallets}'));

    if (count! > 0) {
      log('Wallets existed, skip');
      return;
    }

    // Check if wallets.json exists, if not create default wallet
    try {
      final jsonString = await rootBundle.loadString('assets/data/wallets.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);

      for (var data in jsonData) {
        // Update JSON to use typeWalletId instead of typeWallet
        data['typeWalletId'] = data['typeWalletId'] ?? 1; // Default to cash
        final wallet = Wallet.fromJson(data);
        await db.insert(AppConstants.tableWallets, wallet.toMap());
      }
      log('Wallets seeded from JSON');
    } catch (e) {
      // If JSON doesn't exist, create default wallet
      await db.insert(AppConstants.tableWallets, {
        'name': 'Ví mặc định',
        'iconPath': 'assets/icons/cash.png',
        'balance': 0,
        'typeWalletId': 1, // Cash type
        'isDefault': 1,
        'isActive': 1,
        'createAt': DateTime.now().toIso8601String(),
        'isSynced': 0,
        'syncId': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      log('Default wallet created');
    }
  }

  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    log('📦 Database downgraded from version $oldVersion to $newVersion');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createLatestSchema(db);
    log('Database created successfully');
  }

  Future<void> _createLatestSchema(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    // Create type_wallets table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTypeWallets} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        iconPath TEXT NOT NULL
      )
    ''');

    // Create wallets table with typeWalletId
    await db.execute('''
      CREATE TABLE ${AppConstants.tableWallets} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        iconPath TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        typeWalletId INTEGER NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1,
        createAt TEXT NOT NULL,
        updateAt TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0,
        syncId TEXT NOT NULL,
        FOREIGN KEY (typeWalletId) REFERENCES ${AppConstants.tableTypeWallets}(id) ON DELETE RESTRICT
      )
    ''');

    // Create transactions table
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
        FOREIGN KEY (walletId) REFERENCES ${AppConstants.tableWallets}(id) ON DELETE RESTRICT
      )
    ''');

    // Create indexes for fast lookup
    await db.execute('CREATE INDEX idx_type_wallet_name ON ${AppConstants.tableTypeWallets}(name)');
    await db.execute('CREATE INDEX idx_wallet_name ON ${AppConstants.tableWallets}(name)');
    await db.execute('CREATE INDEX idx_wallet_typeWalletId ON ${AppConstants.tableWallets}(typeWalletId)');
    await db.execute('CREATE INDEX idx_wallet_default ON ${AppConstants.tableWallets}(isDefault)');
    await db.execute('CREATE INDEX idx_wallet_active ON ${AppConstants.tableWallets}(isActive)');
    await db.execute('CREATE INDEX idx_transaction_walletId ON ${AppConstants.tableTransactions}(walletId)');
    await db.execute('CREATE INDEX idx_transaction_date ON ${AppConstants.tableTransactions}(date)');

    // Seed default data
    await _seedTypeWallets(db);
    await _seedWallets(db);
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

      await _updateWalletBalance(transaction.walletId);

      log('Transaction inserted with id: $id ${transaction.title}');
      return id;
    } catch (e) {
      // Database lock issue - reset and retry
      if (e.toString().contains('readonly')) {
        log('Database readonly error, attempting to reset...');
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
      // we have 2 case, 1 is update in current wallet, another one is update using another wallet
      final db = await database;

      // get old transaction with old walletId
      final oldTransaction = await getTransactionById(transaction.id ?? -1);
      final count = await db.update(
        AppConstants.tableTransactions,
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );

      // update wallet balance
      await _updateWalletBalance(transaction.walletId);

      if (oldTransaction != null && oldTransaction.walletId != transaction.walletId) {
        await _updateWalletBalance(oldTransaction.walletId);
      }
      log('Transaction updated: $count rows affected');
      return count;
    } catch (e) {
      if (e.toString().contains('readonly')) {
        log('Database readonly error, attempting to reset...');
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

      // find transaction
      final transaction = await getTransactionById(id);
      final count = await db.delete(AppConstants.tableTransactions, where: 'id = ?', whereArgs: [id]);

      if (transaction != null && count > 0) {
        await _updateWalletBalance(transaction.walletId);
      }

      return count;
    } catch (e) {
      if (e.toString().contains('readonly')) {
        log('Database readonly error, attempting to reset...');
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

      log('Database file deleted successfully. Will be recreated on next access.');
    } catch (e) {
      log('Clear database failed: $e');
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

      log('Database imported successfully from $assetPath');
    } catch (e) {
      log('Import failed: $e');
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

      log('Database imported successfully');
    } catch (e) {
      log('Import failed: $e');
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
      type: getTransactionType(json['type'] as String),
      note: json['note'] as String?,
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
      syncId: json['syncId'] as String? ?? '',
    );
  }

  // Helper function to convert category type string to TransactionType enum


  // ==================== WALLET BALANCE HELPER ====================

  /// Update wallet balance based on transactions
  Future<void> _updateWalletBalance(int walletId) async {
    try {
      final db = await database;
      final calculatedBalance = await getWalletBalance(walletId);

      await db.update(
        AppConstants.tableWallets,
        {'balance': calculatedBalance, 'updateAt': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [walletId],
      );

      log('Wallet $walletId balance updated to: $calculatedBalance');
    } catch (e) {
      log('Update wallet balance failed: $e');
      rethrow;
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
    final List<Map<String, dynamic>> maps = await db.query(AppConstants.tableWallets, where: 'id = ?', whereArgs: [id]);

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
      final allMaps = await db.query(AppConstants.tableWallets, where: 'isActive = ?', whereArgs: [1], limit: 1);
      if (allMaps.isEmpty) return null;
      return Wallet.fromMap(allMaps.first);
    }

    return Wallet.fromMap(maps.first);
  }

  /// Calculate wallet balance from transactions
  Future<double> getWalletBalance(int walletId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
    SELECT
      SUM(CASE
        WHEN type IN ('income', 'borrowing', 'transferIn') THEN amount
        WHEN type IN ('expense', 'lend', 'transferOut') THEN -amount
        ELSE 0
      END) as balance
    FROM ${AppConstants.tableTransactions}
    WHERE walletId = ?
  ''',
      [walletId],
    );

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
      log('Wallet inserted with id: $id');
      return id;
    } catch (e) {
      log('Insert wallet failed: $e');
      rethrow;
    }
  }

  /// Update wallet
  Future<int> updateWallet(Wallet wallet) async {
    try {
      final db = await database;
      final count = await db.update(AppConstants.tableWallets, wallet.toMap(), where: 'id = ?', whereArgs: [wallet.id]);
      log('Wallet updated: $count rows affected');
      return count;
    } catch (e) {
      log('Update wallet failed: $e');
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
      log('Wallet deactivated: $count rows affected');
      return count;
    } catch (e) {
      log('Deactivate wallet failed: $e');
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
          'Please deactivate instead or move transactions to another wallet.',
        );
      }

      final count = await db.delete(AppConstants.tableWallets, where: 'id = ?', whereArgs: [id]);
      log('Wallet deleted: $count rows affected');
      return count;
    } catch (e) {
      log('Delete wallet failed: $e');
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
      log('Wallet activated: $count rows affected');
      return count;
    } catch (e) {
      log('Activate wallet failed: $e');
      rethrow;
    }
  }

  /// Set wallet as default (unsets all others)
  Future<void> setDefaultWallet(int id) async {
    try {
      final db = await database;

      // Unset all defaults
      await db.update(AppConstants.tableWallets, {'isDefault': 0});

      // Set new default
      await db.update(
        AppConstants.tableWallets,
        {'isDefault': 1, 'updateAt': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );

      log('Default wallet set to id: $id');
    } catch (e) {
      log('Set default wallet failed: $e');
      rethrow;
    }
  }

  /// Delete wallets table completely (DROP TABLE)
  Future<void> deleteWalletTable() async {
    try {
      final db = await database;

      // Drop the wallets table
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.tableWallets}');

      log('Wallets table deleted successfully');

      // Note: After dropping the table, you'll need to recreate it
      // by either calling _onCreate or upgrading the database version
    } catch (e) {
      log('Delete wallet table failed: $e');
      rethrow;
    }
  }

  // ==================== TYPE WALLET OPERATIONS ====================

  /// Get all type wallets
  Future<List<TypeWallet>> getAllTypeWallets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableTypeWallets,
      orderBy: 'id ASC',
    );

    return List.generate(maps.length, (i) => TypeWallet.fromMap(maps[i]));
  }

  /// Get type wallet by ID
  Future<TypeWallet?> getTypeWalletById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableTypeWallets,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return TypeWallet.fromMap(maps.first);
  }

  /// Insert new type wallet
  Future<int> insertTypeWallet(TypeWallet typeWallet) async {
    try {
      final db = await database;
      final id = await db.insert(
        AppConstants.tableTypeWallets,
        typeWallet.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      log('Type wallet inserted with id: $id');
      return id;
    } catch (e) {
      log('Insert type wallet failed: $e');
      rethrow;
    }
  }
}
