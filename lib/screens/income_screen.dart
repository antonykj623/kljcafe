import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kljcafe/screens/incomelist.dart';

import '../databaseHelper/databasehelper.dart';
import '../design/ResponsiveInfo.dart'; // for date formatting

class AddIncomePage extends StatefulWidget {
   AddIncomePage();

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _paymentMode = "Cash";
  // today’s date (not changeable by user)
  final String _todayDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  Future<void> _saveIncome() async {
    final String amount = _amountController.text.trim();
    final String desc = _descController.text.trim();

    if (amount.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    // you can save data to DB / API here
    debugPrint("Income Saved: Amount=$amount, Date=$_todayDate, Desc=$desc");

    ResponsiveInfo.showLoaderDialog(context);
    Map<String,dynamic> mp=new HashMap();
    mp["type"]="income";
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
      const SnackBar(content: Text("Income added successfully ✅")),
    );




    Navigator.pop(context); // go back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Income"),actions: [

        Padding(padding: EdgeInsets.all(10),

        child: GestureDetector(

          child: Icon(Icons.list_alt,color: Colors.black,size: 25,),

          onTap: (){

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  IncomeListScreen()),
            );


          },
        ),


        )


      ],),
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
                prefixIcon: Icon(Icons.currency_rupee),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Date (non-editable, today’s date)
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
                onPressed: _saveIncome,
                icon: const Icon(Icons.save),
                label: const Text("Save Income"),
                style: ElevatedButton.styleFrom(
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
