import 'dart:developer';

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

  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    log('📦 Database downgraded from version $oldVersion to $newVersion');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTransactions} (
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
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableTransactions,
      orderBy: 'date DESC',
    );

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
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
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

  // CLEAR DATABASE - Delete all transactions
  Future<void> clearDatabase() async {
    try {
      final db = await database;
      await db.delete(AppConstants.tableTransactions);
      log('✅ Database cleared successfully');
    } catch (e) {
      log('❌ Clear database failed: $e');
      rethrow;
    }
  }

  // IMPORT DATABASE - Load transactions from JSON file in assets
  Future<void> importDatabaseFromAssets(String assetPath) async {
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
      wallet: json['wallet'] as String,
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
        return TransactionType.outcome;
      case 'lend':
        return TransactionType.lend;
      case 'borrowing':
        return TransactionType.borrowing;
      default:
        return TransactionType.outcome;
    }
  }
}
