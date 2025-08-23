import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kljcafe/databaseHelper/databasehelper.dart';
import 'dart:io';
import '../model/Employee.dart';
import 'package:share_plus/share_plus.dart';  // for Share.shareXFiles
import 'package:cross_file/cross_file.dart';  // for XFile


class EmployeeListPage extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const EmployeeListPage({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  List<Employee> employees = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _loadEmployees();
  }

  @override
  void dispose() {
    // Reset to allow all orientations when leaving this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    final list = await widget.dbHelper.getEmployees();
    setState(() {
      employees = list;
    });
  }

  Future<void> _shareEmployee(Employee emp) async {
    final buffer = StringBuffer();
    buffer.writeln("👤 Employee Details");
    buffer.writeln("Name: ${emp.name}");
    buffer.writeln("Age: ${emp.age}");
    buffer.writeln("Address: ${emp.address}");
    buffer.writeln("Phone: ${emp.phone}");
    buffer.writeln("Joining Date: ${emp.joiningDate.toString().split(' ')[0]}");

    final files = <XFile>[];
    if (emp.photo != null) files.add(XFile(emp.photo!));
    for (final doc in emp.documents.toString().split(",")) {
      files.add(XFile(doc));
    }

    if (files.isEmpty) {
      await Share.share(buffer.toString(), subject: "Employee: ${emp.name}");
    } else {
      await Share.shareXFiles(files, text: buffer.toString(), subject: "Employee: ${emp.name}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employees")),
      body: employees.isEmpty
          ? const Center(child: Text("No employees found"))
          : ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final emp = employees[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              leading: emp.photo != null
                  ? CircleAvatar(backgroundImage: FileImage(File(emp.photo!)))
                  : const CircleAvatar(child: Icon(Icons.person)),
              title: Text(emp.name),
              subtitle: Text(
                "Phone: ${emp.phone}\nJoined: ${emp.joiningDate.toString().split(' ')[0]}",
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareEmployee(emp),
              ),
            ),
          );
        },
      ),
    );
  }
}
