import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/Employee.dart';
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
        await db.execute('''
       CREATE TABLE opening_balance (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT,
  amount REAL
);
        ''');
        await db.execute('''
  CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    age INTEGER,
    photo TEXT,
    address TEXT,
    phone TEXT,
    documents TEXT,
    joiningDate TEXT
  );
''');


        await db.execute('''
CREATE TABLE employee_salary (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    salary_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_mode  NOT NULL,
    created_at TEXT NOT NULL
);

''');
      },
    );
  }



  Future<int> insertSalary(Map<String, dynamic> record) async {
    final db = await DatabaseHelper().db;
    return await db.insert("employee_salary", record);
  }

  Future<List<Map<String, dynamic>>> getSalariesByDate(String date) async {
    final dbClient = await db;
    return await dbClient.rawQuery('''
      SELECT es.id, e.name AS employee_name, es.salary, es.amount, es.salary_date, es.payment_mode
      FROM employee_salary es
      JOIN employees e ON es.employee_id = e.id
      WHERE es.salary_date = ?
      ORDER BY es.salary_date DESC
    ''', [date]);
  }



  // Get SUM of opening balance between two dates (inclusive)
  Future<double> getSumOfOpeningBalance(String fromDate, String toDate) async {
    final dbClient = await db;
    final result = await dbClient.rawQuery(
      '''
    SELECT SUM(amount) as total 
    FROM opening_balance
    WHERE date BETWEEN ? AND ?
    ''',
      [fromDate, toDate],
    );

    if (result.isNotEmpty) {
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }


  //opening balance methodes
   Future<int> insertOpeningBalance(String date, double amount) async {
     final dbClient = await db;
    return await dbClient.insert("opening_balance", {
      "date": date,
      "amount": amount,
    });
  }

  /// 🔹 Get All Opening Balances
   Future<List<Map<String, dynamic>>> getAllOpeningBalances() async {
    final dbClient = await db;
    return await dbClient.query("opening_balance", orderBy: "date ASC");
  }

  /// 🔹 Get Opening Balance by Date
   Future<dynamic> getOpeningBalanceByDate(String date) async {
     final dbClient = await db;
    final res = await dbClient.query(
      "opening_balance",
      where: "date = ?",
      whereArgs: [date],
      limit: 1,
    );

    if (res.isNotEmpty) {
      return {"amount":res.first["amount"] as double,"id":res.first["id"]};
    } else {
      return {"amount":0.0,"id":0};
    }
  }

  /// 🔹 Update Opening Balance
   Future<int> updateOpeningBalance(int id,String date, double amount) async {
    final dbClient = await db;
    return await dbClient.update(
      "opening_balance",
      {"amount": amount,"date":date},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  /// 🔹 Delete Opening Balance
   Future<int> deleteOpeningBalance(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      "opening_balance",
      where: "id = ?",
      whereArgs: [id],
    );
  }


















  Future<int> insertEmployee(Employee emp) async {
    final dbClient = await db;
    return await dbClient.insert("employees", emp.toMap());
  }

  Future<List<Employee>> getEmployees() async {
    final dbClient = await db;
    final res = await dbClient.query("employees", orderBy: "id DESC");
    return res.map((e) => Employee.fromMap(e)).toList();
  }

  Future<int> updateEmployee(Employee emp) async {
    final dbClient = await db;
    return await dbClient.update(
      "employees",
      emp.toMap(),
      where: "id = ?",
      whereArgs: [emp.id],
    );
  }

  Future<int> deleteEmployee(int id) async {
    final dbClient = await db;
    return await dbClient.delete("employees", where: "id = ?", whereArgs: [id]);
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
