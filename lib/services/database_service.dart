import 'dart:developer';

import 'package:mosa/models/debt.dart';
import 'package:mosa/models/person.dart';
import 'package:mosa/models/wallets.dart';
import 'package:mosa/models/category.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../models/enums.dart';
import '../services/category_service.dart';
import '../services/person_service.dart';
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
        data['typeWalletId'] = data['typeWalletId'] ?? 1; // Default to cash
        final wallet = Wallet.fromJson(data);
        await db.insert(AppConstants.tableWallets, wallet.toMap());
      }
      log('Wallets seeded from JSON');
    } catch (e, stackTrace) {
      // If JSON doesn't exist, create default wallet
      await db.insert(AppConstants.tableWallets, {
        'name': 'Ví mặc định',
        'iconPath': 'assets/icons/cash.png',
        'initialBalance': 0,
        'balance': 0,
        'typeWalletId': 1, // Cash type
        'isDefault': 1,
        'isActive': 1,
        'createAt': DateTime.now().toIso8601String(),
        'isSynced': 0,
        'syncId': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      log('Default wallet created cuz have bug', name: 'DatabaseService', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _seedTransactions(Database db) async {
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tableTransactions}'));

    if (count! > 0) {
      log('Transactions existed, skip');
      return;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/transactions.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);

      for (final json in jsonData) {
        final transaction = _parseTransactionFromJson(json);
        await db.insert(AppConstants.tableTransactions, transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }

      log('Transactions seeded from JSON');
    } catch (e, stackTrace) {
      log('Transactions seeding failed', name: 'DatabaseService', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _seedPersons(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tablePersons}'),
    );

    if (count! > 0) {
      log('Persons already exist, skip seeding');
      return;
    }

    // Load from JSON only if database is empty
    try {
      final persons = await PersonService.loadPersons();
      for (var person in persons) {
        await db.insert(
          AppConstants.tablePersons,
          person.toJson(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      log('Persons seeded from JSON: ${persons.length} entries');
    } catch (e, stackTrace) {
      log('Person seeding failed',
          name: 'DatabaseService', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _seedCategories(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tableCategories}'),
    );

    if (count! > 0) {
      log('Categories already exist, skip seeding');
      return;
    }

    // Load from JSON only if database is empty
    try {
      final categories = await CategoryService.loadCategories();
      final List<Category> flatCategories = [];

      for (var category in categories) {
        flatCategories.add(category);
        if (category.children != null) {
          flatCategories.addAll(category.children!);
        }
      }

      for (var category in flatCategories) {
        await db.insert(
          AppConstants.tableCategories,
          category.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      log('Categories seeded: ${flatCategories.length} entries');
    } catch (e, stackTrace) {
      log('Person seeding failed',
          name: 'DatabaseService', error: e, stackTrace: stackTrace);
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
        initialBalance REAL NOT NULL DEFAULT 0,
        balance REAL NOT NULL DEFAULT 0,
        typeWalletId INTEGER NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1,
        createAt TEXT NOT NULL,
        updateAt TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0,
        syncId TEXT NOT NULL,
        note TEXT,
        bankId INTEGER,
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

    await db.execute('''
      CREATE TABLE ${AppConstants.tablePersons}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        iconPath TEXT NOT NULL
        )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableDebts}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        personId INTEGER NOT NULL,
        amount REAL NOT NULL,
        paidAmount REAL NOT NULL DEFAULT 0,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        description TEXT NOT NULL,
        createdDate INTEGER NOT NULL,
        dueDate INTEGER,
        walletId INTEGER NOT NULL,
        FOREIGN KEY (personId) REFERENCES ${AppConstants.tablePersons}(id) ON DELETE RESTRICT,
        FOREIGN KEY (walletId) REFERENCES ${AppConstants.tableWallets}(id) ON DELETE RESTRICT
        )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableCategories}(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        iconType TEXT NOT NULL,
        iconPath TEXT NOT NULL,
        color TEXT,
        parentId TEXT,
        FOREIGN KEY (parentId) REFERENCES ${AppConstants.tableCategories}(id) ON DELETE RESTRICT
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
    await db.execute('CREATE INDEX idx_debt_personId ON ${AppConstants.tableDebts}(personId)');
    await db.execute('CREATE INDEX idx_debt_categoriesId ON ${AppConstants.tableCategories}(id)');

    // Seed default data
    await _seedTypeWallets(db);
    await _seedWallets(db);
    await _seedTransactions(db);
    await _seedPersons(db);
    await _seedCategories(db);
  }

  Future<void> initializeDatabase({bool clearExisting = false}) async {
    try {
      if (clearExisting) {
        await clearDatabase();
        _database = null;

        await Future.delayed(const Duration(milliseconds: 100));
      }
      await database;
    } catch (e) {
      log('Database initialization failed', error: e);
    }
  }

  // CREATE
  Future<int> insertTransaction(TransactionModel transaction) async {
    try {
      final db = await database;
      final id = await db.insert(AppConstants.tableTransactions, transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

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

  Future<List<Debt>> getAllDebt() async {
    final db = await database;
    final List<Map<String, dynamic>> map = await db.query(AppConstants.tableDebts, orderBy: 'createdDate DESC');

    return List.generate(map.length, (index) {
      return Debt.fromJson(map[index]);
    });
  }

  Future<List<Debt>> getDebtByType(DebtType type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableDebts,
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'createdDate DESC',
    );
    return List.generate(maps.length, (index) {
      return Debt.fromJson(maps[index]);
    });
  }

  Future<int> createDebt(Debt debt) async {
    try {
      final db = await database;
      final id = await db.insert(AppConstants.tableDebts, debt.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      await _updateWalletBalance(debt.walletId ?? -1);
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDebt(Debt debt) async {
    try {
      final db = await database;
      await db.update(AppConstants.tableDebts, debt.toJson(), where: 'id = ?', whereArgs: [debt.id]);
      await _updateWalletBalance(debt.walletId ?? -1);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDebt(Debt debt) async {
    try {
      final db = await database;
      await db.delete(AppConstants.tableDebts, where: 'id = ?', whereArgs: [debt.id]);
      await _updateWalletBalance(debt.walletId ?? -1);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getDebtByPersonId(Debt debt) async {
    try {
      final db = await database;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== PERSON OPERATIONS ====================

  /// Get all persons ordered by name
  Future<List<Person>> getAllPersons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tablePersons,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Person.fromJson(maps[i]));
  }

  /// Get person by ID
  Future<Person?> getPersonById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tablePersons,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Person.fromJson(maps.first);
  }

  /// Insert new person
  Future<int> insertPerson(Person person) async {
    try {
      final db = await database;

      // Check for duplicate name
      final existing = await db.query(
        AppConstants.tablePersons,
        where: 'name = ?',
        whereArgs: [person.name],
      );
      if (existing.isNotEmpty) {
        throw 'Tên người đã tồn tại';
      }

      final id = await db.insert(AppConstants.tablePersons, person.toJson());
      log('Person inserted with id: $id');
      return id;
    } catch (e) {
      log('Insert person failed: $e');
      if (e.toString().contains('UNIQUE constraint')) {
        throw 'Tên người đã tồn tại';
      }
      rethrow;
    }
  }

  /// Update person (name and iconPath only, cannot change id)
  Future<int> updatePerson(Person person) async {
    try {
      final db = await database;

      // Check if another person has the same name
      final existing = await db.query(
        AppConstants.tablePersons,
        where: 'name = ? AND id != ?',
        whereArgs: [person.name, person.id],
      );
      if (existing.isNotEmpty) {
        throw 'Tên người đã tồn tại';
      }

      final count = await db.update(
        AppConstants.tablePersons,
        person.toJson(),
        where: 'id = ?',
        whereArgs: [person.id],
      );
      log('Person updated: $count rows affected');
      return count;
    } catch (e) {
      log('Update person failed: $e');
      rethrow;
    }
  }

  // ==================== CATEGORIES OPERATIONS ====================

  /// Get all category ordered by name
  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCategories,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromJson(maps[i]));
  }

  /// Insert new category
  Future<int> insertCategory(Category category) async {
    try {
      final db = await database;

      // Check for duplicate name
      final existing = await db.query(
        AppConstants.tablePersons,
        where: 'name = ?',
        whereArgs: [category.name],
      );
      if (existing.isNotEmpty) {
        throw 'Tên category đã tồn tại';
      }

      final id = await db.insert(AppConstants.tablePersons, category.toJson());
      log('Person inserted with id: $id');
      return id;
    } catch (e) {
      log('Insert category failed: $e');
      if (e.toString().contains('UNIQUE constraint')) {
        throw 'Tên category đã tồn tại';
      }
      rethrow;
    }
  }

  /// Update category (name and iconPath only, cannot change id)
  Future<int> updateCategory(Category category) async {
    try {
      final db = await database;

      // Check if another person has the same name
      final existing = await db.query(
        AppConstants.tableCategories,
        where: 'name = ? AND id != ?',
        whereArgs: [category.name, category.id],
      );
      if (existing.isNotEmpty) {
        throw 'Tên category đã tồn tại';
      }

      final count = await db.update(
        AppConstants.tableCategories,
        category.toJson(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
      log('category updated: $count rows affected');
      return count;
    } catch (e) {
      log('Update category failed: $e');
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
    final List<Map<String, dynamic>> maps = await db.query(AppConstants.tableTransactions, where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return TransactionModel.fromMap(maps.first);
  }

  /// Lấy tổng số tiền của tất cả giao dịch theo category ID
  Future<double> getTotalAmountByCategoryId(String categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM ${AppConstants.tableTransactions} WHERE categoryId = ?',
      [categoryId],
    );

    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  // UPDATE
  Future<int> updateTransaction(TransactionModel transaction) async {
    try {
      // we have 2 case, 1 is update in current wallet, another one is update using another wallet
      final db = await database;

      // get old transaction with old walletId
      final oldTransaction = await getTransactionById(transaction.id ?? -1);
      final count = await db.update(AppConstants.tableTransactions, transaction.toMap(), where: 'id = ?', whereArgs: [transaction.id]);

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
      log('calculateBalance: $calculatedBalance');

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

    // Query với calculated balance
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT 
      w.*,
      COALESCE(w.initialBalance, 0) + COALESCE(
        (SELECT SUM(CASE
          WHEN t.type IN ('income', 'borrowing', 'transferIn') THEN t.amount
          WHEN t.type IN ('expense', 'lend', 'transferOut') THEN -t.amount
          WHEN t.type = 'adjustBalance' THEN t.amount
          ELSE 0
        END) FROM ${AppConstants.tableTransactions} t WHERE t.walletId = w.id),
        0
      ) as calculatedBalance
    FROM ${AppConstants.tableWallets} w
    ${includeInactive ? '' : 'WHERE w.isActive = 1'}
    ORDER BY w.isDefault DESC, w.name ASC
  ''');

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['balance'] = map['calculatedBalance'] ?? map['balance'] ?? 0.0;
      log('Get all wallets: ${map['name']} - ${map['balance']}');
      return Wallet.fromMap(map);
    });
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
      COALESCE(w.initialBalance, 0) + 
      SUM(CASE
        WHEN t.type IN ('income', 'borrowing', 'transferIn') THEN t.amount
        WHEN t.type IN ('expense', 'lend', 'transferOut') THEN -t.amount
        WHEN t.type = 'adjustBalance' THEN t.amount
        ELSE 0
      END) as balance
    FROM ${AppConstants.tableWallets} w
    LEFT JOIN ${AppConstants.tableTransactions} t ON w.id = t.walletId
    WHERE w.id = ?
    GROUP BY w.id
  ''',
      [walletId],
    );

    if (result.isEmpty) return 0.0;

    return (result.first['balance'] as num?)?.toDouble() ?? 0.0;
  }

  /// Insert new wallet
  Future<int> insertWallet(Wallet wallet) async {
    try {
      final db = await database;

      final existing = await db.query(AppConstants.tableWallets, where: 'name = ?', whereArgs: [wallet.name]);
      if (existing.isNotEmpty) {
        throw 'Tên ví đã tồn tại';
      }

      final id = await db.insert(AppConstants.tableWallets, wallet.toMap());
      log('Wallet inserted with id: $id');
      return id;
    } catch (e) {
      log('Insert wallet failed: $e');

      final errorMsg = e.toString();

      if (errorMsg.contains('has no column named')) {
        throw 'Database lỗi. Vui lòng xóa và cài lại app.';
      }

      if (errorMsg.contains('UNIQUE constraint')) {
        throw 'Tên ví đã tồn tại';
      }

      if (errorMsg.contains('FOREIGN KEY constraint')) {
        throw 'Loại ví không hợp lệ';
      }

      // Default error
      throw 'Không thể lưu ví. Vui lòng thử lại.';
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
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.tableTransactions} WHERE walletId = ?', [id]);
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
    final List<Map<String, dynamic>> maps = await db.query(AppConstants.tableTypeWallets, orderBy: 'id ASC');

    return List.generate(maps.length, (i) => TypeWallet.fromMap(maps[i]));
  }

  /// Get type wallet by ID
  Future<TypeWallet?> getTypeWalletById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(AppConstants.tableTypeWallets, where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return TypeWallet.fromMap(maps.first);
  }

  /// Insert new type wallet
  Future<int> insertTypeWallet(TypeWallet typeWallet) async {
    try {
      final db = await database;
      final id = await db.insert(AppConstants.tableTypeWallets, typeWallet.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      log('Type wallet inserted with id: $id');
      return id;
    } catch (e) {
      log('Insert type wallet failed: $e');
      rethrow;
    }
  }

  /// Delete type wallet (only if no wallets are using it)
  Future<int> deleteTypeWallet(int id) async {
    try {
      final db = await database;

      // Check if any wallets are using this type
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.tableWallets} WHERE typeWalletId = ?', [id]);
      final walletCount = Sqflite.firstIntValue(result) ?? 0;

      if (walletCount > 0) {
        throw Exception(
          'Cannot delete type wallet with $walletCount wallet(s) using it. '
          'Please change wallet types or delete wallets first.',
        );
      }

      final count = await db.delete(AppConstants.tableTypeWallets, where: 'id = ?', whereArgs: [id]);
      log('Type wallet deleted: $count rows affected');
      return count;
    } catch (e) {
      log('Delete type wallet failed: $e');
      rethrow;
    }
  }
}
