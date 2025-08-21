import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kljcafe/screens/openingbalancelist.dart';
import '../databaseHelper/databasehelper.dart';
// your db helper file

class OpeningBalanceScreen extends StatefulWidget {
  const OpeningBalanceScreen({super.key});

  @override
  State<OpeningBalanceScreen> createState() => _OpeningBalanceScreenState();
}

class _OpeningBalanceScreenState extends State<OpeningBalanceScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  Future<void> _saveOpeningBalance() async {
    if (_dateController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all fields")),
      );
      return;
    }

    double? amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid amount")),
      );
      return;
    }

    await new DatabaseHelper().insertOpeningBalance(_dateController.text, amount);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Opening Balance Saved")),
    );

    _dateController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Opening Balance",style: TextStyle(fontSize: 14),),
        centerTitle: true,
        actions: [

          Padding(padding: EdgeInsets.all(10),

            child: GestureDetector(

              child: Icon(Icons.list_alt,color: Colors.black,size: 25,),

              onTap: (){

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  OpeningBalanceScreenList()),
                );


              },
            ),


          )


        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Date",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Opening Balance Amount",
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveOpeningBalance,
              icon: const Icon(Icons.save),
              label: const Text("Save Opening Balance"),
            ),
          ],
        ),
      ),
    );
  }
}
