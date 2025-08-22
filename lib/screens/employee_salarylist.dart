import 'package:flutter/material.dart';
import '../databaseHelper/databasehelper.dart';
import 'package:intl/intl.dart';

import '../utils/salaryexport.dart';

class EmployeeSalaryListPage extends StatefulWidget {
  const EmployeeSalaryListPage({super.key});

  @override
  State<EmployeeSalaryListPage> createState() => _EmployeeSalaryListPageState();
}

class _EmployeeSalaryListPageState extends State<EmployeeSalaryListPage> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _salaryList = [];

  @override
  void initState() {
    super.initState();
    _loadSalaries();
  }

  Future<void> _loadSalaries() async {
   // String date = _selectedDate.toIso8601String().split('T')[0]; // yyyy-MM-dd
    final String date = DateFormat('dd/MM/yyyy').format(_selectedDate);


    final data = await DatabaseHelper().getSalariesByDate(date);
    setState(() {
      _salaryList = data;
    });
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _loadSalaries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text("Employee Salary Records",style: TextStyle(fontSize: 14),),

      actions: [
        Padding(padding: EdgeInsets.all(4),

        child: ElevatedButton.icon(
          icon: const Icon(Icons.share),
          label: const Text("Export & Share"),
          onPressed: () async {
            try {
            //  String date = _selectedDate.toIso8601String().split('T')[0]; // yyyy-MM-dd

               String date = DateFormat('dd/MM/yyyy').format(_selectedDate);



              await SalaryExporter.exportAndShare(date);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
        ),


        )


      ],

      ),
      body: Column(
        children: [
          // Date Picker Row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Selected Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Pick Date"),
                  onPressed: _pickDate,
                ),
              ],
            ),
          ),

          const Divider(),

          // Salary List
          Expanded(
            child: _salaryList.isEmpty
                ? const Center(
              child: Text("No salary records found for this date"),
            )
                : ListView.builder(
              itemCount: _salaryList.length,
              itemBuilder: (context, index) {
                final record = _salaryList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: Text(record['employee_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "Salary: ${record['salary']} \nAmount: ${record['amount']} \nMode: ${record['payment_mode']}",
                    ),
                    trailing: Text(
                      record['salary_date'].toString().split('T')[0],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
