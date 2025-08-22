import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../databaseHelper/databasehelper.dart';


class SalaryExporter {
  static Future<void> exportAndShare(String date) async {
    // 1. Get records from DB
    final db = DatabaseHelper();
    final records = await db.getSalariesByDate(date);

    if (records.isEmpty) {
      throw Exception("No salary records found for $date");
    }

    // 2. Build text content
    StringBuffer buffer = StringBuffer();
    buffer.writeln("Employee Salary Records for $date\n");
    buffer.writeln("--------------------------------------------------");

    for (var record in records) {
      buffer.writeln("Employee: ${record['employee_name']}");
      buffer.writeln("Salary  : ${record['salary']}");
      buffer.writeln("Amount  : ${record['amount']}");
      buffer.writeln("Mode    : ${record['payment_mode']}");
      buffer.writeln("Date    : ${record['salary_date']}");
      buffer.writeln("Created Date    : ${record['created_at']}");
      buffer.writeln("--------------------------------------------------");
    }

    DateTime date1 = DateFormat('dd/MM/yyyy').parse(date);
    String dt=DateFormat('dd-MM-yyyy').format(date1);

    // 3. Save to file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/salary_records_$dt.txt";
    final file = File(filePath);
    await file.writeAsString(buffer.toString());

    // 4. Share file
    await Share.shareXFiles([XFile(file.path)], text: "Salary records for $date");
  }
}
