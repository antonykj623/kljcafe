import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/ledger.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  // Initialize DB
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "cafe_ledger.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,         -- income or expense
            amount REAL NOT NULL,
            date TEXT NOT NULL,         -- stored as YYYY-MM-DD
            description TEXT
          )
        ''');
      },
    );
  }

  // Insert transaction
  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final dbClient = await db;
    return await dbClient.insert("transactions", row);
  }

  // Get all transactions
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final dbClient = await db;
    return await dbClient.query("transactions", orderBy: "date DESC");
  }

  // Get transactions by date
  Future<List<Map<String, dynamic>>> getTransactionsByDate(String date) async {
    final dbClient = await db;
    return await dbClient.query(
      "transactions",
      where: "date = ?",
      whereArgs: [date],
      orderBy: "id DESC",
    );
  }


  Future<List<Ledger>> getLedgerByDate(String date) async {
    final dbClient = await db;
    final result = await dbClient.query(
      "transactions",
      where: "date = ?",
      whereArgs: [date],
      orderBy: "id DESC",
    );

    return result.map((e) => Ledger.fromMap(e)).toList();
  }

  Future<List<Ledger>> getIncomeByDate(String date) async {
    final dbClient = await db;
    final result = await dbClient.query(
      "transactions",
      where: "type = ? AND date = ?",
      whereArgs: ["income", date],
      orderBy: "id DESC",
    );
    return result.map((e) => Ledger.fromMap(e)).toList();
  }

  Future<List<Ledger>> getExpenseByDate(String date) async {
    final dbClient = await db;
    final result = await dbClient.query(
      "transactions",
      where: "type = ? AND date = ?",
      whereArgs: ["expense", date],
      orderBy: "id DESC",
    );
    return result.map((e) => Ledger.fromMap(e)).toList();
  }



  Future<Map<String, double>> getTotalsByDate(String date) async {
    final dbClient = await db;

    final incomeResult = await dbClient.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'income' AND date = ?",
      [date],
    );

    final expenseResult = await dbClient.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense' AND date = ?",
      [date],
    );

    final income = (incomeResult.first["total"] as num?)?.toDouble() ?? 0.0;
    final expense = (expenseResult.first["total"] as num?)?.toDouble() ?? 0.0;

    return {"income": income, "expense": expense, "balance": income - expense};
  }






  // Get totals (income & expense)
  Future<Map<String, double>> getTotals() async {
    final dbClient = await db;
    final incomeResult = await dbClient.rawQuery(
        "SELECT SUM(amount) as total FROM transactions WHERE type = 'income'");
    final expenseResult = await dbClient.rawQuery(
        "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense'");

    final income = incomeResult.first["total"] as double? ?? 0.0;
    final expense = expenseResult.first["total"] as double? ?? 0.0;

    return {"income": income, "expense": expense, "balance": income - expense};
  }

  // Delete transaction
  Future<int> deleteTransaction(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      "transactions",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // Update transaction
  Future<int> updateTransaction(Map<String, dynamic> row) async {
    final dbClient = await db;
    return await dbClient.update(
      "transactions",
      row,
      where: "id = ?",
      whereArgs: [row["id"]],
    );
  }
}
