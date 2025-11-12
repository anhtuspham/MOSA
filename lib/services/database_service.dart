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

    return await openDatabase(path, version: AppConstants.dbVersion, onCreate: _onCreate);
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
        isSynced INTEGER NOT NULL DEFAULT 0,
        syncId TEXT NOT NULL
      )
    ''');

    print('✅ Database created successfully');
  }

  // CREATE
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    final id = await db.insert(
      AppConstants.tableTransactions,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ Transaction inserted with id: $id');
    return id;
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
    final db = await database;
    final count = await db.update(
      AppConstants.tableTransactions,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    print('✅ Transaction updated: $count rows affected');
    return count;
  }

  // DELETE
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    final count = await db.delete(AppConstants.tableTransactions, where: 'id = ?', whereArgs: [id]);
    print('✅ Transaction deleted: $count rows affected');
    return count;
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
