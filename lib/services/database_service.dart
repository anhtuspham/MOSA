import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
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
    print('📦 Database upgraded from version $oldVersion to $newVersion');
  }

  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    print('📦 Database downgraded from version $oldVersion to $newVersion');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTransactions} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        note TEXT,
        createAt TEXT NOT NULL,
        updateAt TEXT,
        isSynced BOOLEAN NOT NULL DEFAULT FALSE,
        syncId TEXT NOT NULL
      )
    ''');

    print('✅ Database created successfully');
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
      print('✅ Transaction inserted with id: $id');
      return id;
    } catch (e) {
      // Database lock issue - reset and retry
      if (e.toString().contains('readonly')) {
        print('⚠️ Database readonly error, attempting to reset...');
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
      print('✅ Transaction updated: $count rows affected');
      return count;
    } catch (e) {
      if (e.toString().contains('readonly')) {
        print('⚠️ Database readonly error, attempting to reset...');
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
      print('✅ Transaction deleted: $count rows affected');
      return count;
    } catch (e) {
      if (e.toString().contains('readonly')) {
        print('⚠️ Database readonly error, attempting to reset...');
        await _resetDatabase();
        return await deleteTransaction(id);
      }
      rethrow;
    }
  }

  // DELETE ALL
  Future<int> deleteAllTransactions() async {
    final db = await database;
    return await db.delete(AppConstants.tableTransactions);
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
}
