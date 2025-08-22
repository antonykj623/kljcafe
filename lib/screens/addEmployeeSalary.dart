import 'package:flutter/material.dart';
import 'package:kljcafe/databaseHelper/databasehelper.dart';

import '../model/Employee.dart';
import 'package:intl/intl.dart';
import 'employee_salarylist.dart';

class EmployeeSalaryPage extends StatefulWidget {
  const EmployeeSalaryPage({super.key});

  @override
  State<EmployeeSalaryPage> createState() => _EmployeeSalaryPageState();
}

class _EmployeeSalaryPageState extends State<EmployeeSalaryPage> {
  final _formKey = GlobalKey<FormState>();

  // Dummy employee list (You can load from DB later)
List<Employee> _employees = [

  ];

  Employee? _selectedEmployee;
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _salaryDate = DateTime.now();
  String _paymentMode = "Cash";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    final list = await new DatabaseHelper() .getEmployees();
    setState(() {
      _employees = list;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text("Employee Salary",style: TextStyle(fontSize: 14),),
      
        actions: [
          
          Padding(padding: EdgeInsets.all(10),
          
          
          child: GestureDetector(
            
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  EmployeeSalaryListPage()),
              );

            },
            child: Icon(Icons.list_alt,size: 25,color: Colors.black,),
            
            
            
            
            
          ),
          
          )
          
          
          
        ],
      
      
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Employee Dropdown
              DropdownButtonFormField<Employee>(
                decoration:  InputDecoration(
                  labelText: "Select Employee",
                  border: OutlineInputBorder(),
                ),
                value: _selectedEmployee,
                items: _employees.map((emp) {
                  return DropdownMenuItem(
                    value: emp,
                    child: Text(emp.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEmployee = value;
                  });
                },
                validator: (value) =>
                value == null ? "Please select an employee" : null,
              ),
              const SizedBox(height: 16),

              // Salary
              // TextFormField(
              //   controller: _salaryController,
              //   decoration: const InputDecoration(
              //     labelText: "Salary",
              //     border: OutlineInputBorder(),
              //   ),
              //   keyboardType: TextInputType.number,
              //   validator: (value) =>
              //   value!.isEmpty ? "Enter salary" : null,
              // ),
              // const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? "Enter amount" : null,
              ),
              const SizedBox(height: 16),

              // Salary Date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Salary Date: ${_salaryDate.toLocal().toString().split(' ')[0]}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _salaryDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _salaryDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Payment Mode (Radio)
              Row(
                children: [
                  const Text("Payment Mode: "),
                  Expanded(
                    child: Row(
                      children: [
                        Radio<String>(
                          value: "Cash",
                          groupValue: _paymentMode,
                          onChanged: (value) {
                            setState(() {
                              _paymentMode = value!;
                            });
                          },
                        ),
                        const Text("Cash"),
                        Radio<String>(
                          value: "Online",
                          groupValue: _paymentMode,
                          onChanged: (value) {
                            setState(() {
                              _paymentMode = value!;
                            });
                          },
                        ),
                        const Text("Online"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final String _todayDate = DateFormat('dd/MM/yyyy').format(_salaryDate);
                    final String _currdate = DateFormat('dd/MM/yyyy').format(DateTime.now());


                    await new DatabaseHelper().insertSalary({
                      "employee_id": _selectedEmployee!.id,
                      "salary": double.parse(_amountController.text),
                      "salary_date": _todayDate,
                      "amount": double.parse(_amountController.text),
                      "payment_mode": _paymentMode,
                      "created_at":_currdate
                    });
                    _amountController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Salary details saved"),
                      ),
                    );
                  }
                },
                child: const Text("Save Salary"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
