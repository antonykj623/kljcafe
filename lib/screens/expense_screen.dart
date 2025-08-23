import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kljcafe/design/ResponsiveInfo.dart';
import 'package:kljcafe/screens/expenselistscreen.dart';

import '../databaseHelper/databasehelper.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _paymentMode = "Cash";
  // today’s date (fixed)
  final String _todayDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  Future<void> _saveExpense() async {
    final String amount = _amountController.text.trim();
    final String desc = _descController.text.trim();

    if (amount.isEmpty ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    // save to DB / API here
    debugPrint("Expense Saved: Amount=$amount, Date=$_todayDate, Desc=$desc");

    ResponsiveInfo.showLoaderDialog(context);

    Map<String,dynamic> mp=new HashMap();
    mp["type"]="expense";
    mp["amount"]=_amountController.text.trim();
    mp["description"]=desc;
    mp["date"]=_todayDate;
    mp["payment_mode"]=_paymentMode;
    await DatabaseHelper().insertTransaction(mp);

    Navigator.pop(context);

    setState(() {

      _amountController.clear();
      _descController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Expense added successfully ✅")),
    );

    Navigator.pop(context); // go back after saving
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense",style: TextStyle(fontSize: 13),),
        actions: [
          Padding(padding: EdgeInsets.all(10),

            child: GestureDetector(

              child: Icon(Icons.list_alt,color: Colors.black,size: 25,),

              onTap: (){

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  ExpenseListScreen()),
                );


              },
            ),


          )

        ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                prefixIcon: Icon(Icons.money_off),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Date (non-editable, today)
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Date",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
                hintText: _todayDate,
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveExpense,
                icon: const Icon(Icons.save),
                label: const Text("Save Expense"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // highlight for expense
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
