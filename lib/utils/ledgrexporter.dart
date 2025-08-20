import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../databaseHelper/databasehelper.dart';
import '../model/ledger.dart';

class LedgerExporter {
  /// Export ledger for a single date (YYYY-MM-DD)
  static Future<File> exportByDate(String date) async {
    final db = DatabaseHelper();
    final List<Ledger> tx = await db.getLedgerByDate(date);
    final totals = await db.getTotalsByDate(date);

    final content = _buildTextReport(
      title: 'Ledger Report (Date: $date)',
      transactions: tx,
      income: (totals['income'] as num?)?.toDouble() ?? 0.0,
      expense: (totals['expense'] as num?)?.toDouble() ?? 0.0,
      balance: (totals['balance'] as num?)?.toDouble() ?? 0.0,
    );

    return _writeAndReturnFile(
      fileName: 'ledger_$date.txt',
      content: content,
    );
  }

  /// Export ledger for a date range inclusive (YYYY-MM-DD)
  static Future<File> exportByRange(String from, String to) async {
    final dbClient = await DatabaseHelper().db;

    // fetch transactions in range
    final rows = await dbClient.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [from, to],
      orderBy: 'date ASC, id ASC',
    );
    final tx = rows.map((e) => Ledger.fromMap(e)).toList();

    // totals in range
    final incomeQ = await dbClient.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type='income' AND date BETWEEN ? AND ?",
      [from, to],
    );
    final expenseQ = await dbClient.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type='expense' AND date BETWEEN ? AND ?",
      [from, to],
    );

    final income = (incomeQ.first['total'] as num?)?.toDouble() ?? 0.0;
    final expense = (expenseQ.first['total'] as num?)?.toDouble() ?? 0.0;
    final balance = income - expense;

    final content = _buildTextReport(
      title: 'Ledger Report (Range: $from → $to)',
      transactions: tx,
      income: income,
      expense: expense,
      balance: balance,
    );

    return _writeAndReturnFile(
      fileName: 'ledger_${from}_to_${to}.txt',
      content: content,
    );
  }

  static String _buildTextReport({
    required String title,
    required List<Ledger> transactions,
    required double income,
    required double expense,
    required double balance,
  }) {
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final buf = StringBuffer()
      ..writeln(title)
      ..writeln('Generated: $now')
      ..writeln('-' * 60)
      ..writeln('Totals')
      ..writeln('  Income : ₹ ${income.toStringAsFixed(2)}')
      ..writeln('  Expense: ₹ ${expense.toStringAsFixed(2)}')
      ..writeln('  Balance: ₹ ${balance.toStringAsFixed(2)}')
      ..writeln('-' * 60)
      ..writeln('Transactions')
      ..writeln('  (date)  (type)     (amount)    description')
      ..writeln('-' * 60);

    if (transactions.isEmpty) {
      buf.writeln('  No transactions found.');
    } else {
      for (final t in transactions) {
        final amt = t.amount.toStringAsFixed(2).padLeft(8);
        final typ = t.type.padRight(8);
        final dat = t.date;
        final desc = (t.description).replaceAll('\n', ' ');
        buf.writeln('  $dat  $typ  ₹ $amt   $desc');
      }
    }

    buf.writeln('-' * 60);
    return buf.toString();
  }



  static Future<File> _writeAndReturnFile({
    required String fileName,
    required String content,
  }) async {
    // Ensure no illegal characters in file name
    final safeFileName = fileName.replaceAll("/", "-");

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$safeFileName');
    await file.writeAsString(content, flush: true);
    return file;
  }


  /// Optional: share the file via system share UI
  static Future<void> shareFile(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'Ledger report');
  }
}
