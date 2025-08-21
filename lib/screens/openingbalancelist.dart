import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../databaseHelper/databasehelper.dart';
 // your db helper file

class OpeningBalanceScreenList extends StatefulWidget {
  const OpeningBalanceScreenList({super.key});

  @override
  State<OpeningBalanceScreenList> createState() => _OpeningBalanceScreenState();
}

class _OpeningBalanceScreenState extends State<OpeningBalanceScreenList> {
  final TextEditingController _dateController = TextEditingController();
 Map<String,dynamic> _balances = {};

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat("yyyy-MM-dd").format(DateTime.now());
    _fetchBalances(); // load for today's date
  }

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
      _fetchBalances();
    }
  }

  Future<void> _fetchBalances() async {
    final data = await new DatabaseHelper().getOpeningBalanceByDate(_dateController.text);
    setState(() {
      _balances = data;
    });
  }

 _editBalance(int id, String oldDate, double oldAmount) async {
    final TextEditingController amountController =
    TextEditingController(text: oldAmount.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Opening Balance"),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Amount"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                double? updatedAmount = double.tryParse(amountController.text);
                if (updatedAmount != null) {
                  await new DatabaseHelper() .updateOpeningBalance(id, oldDate, updatedAmount);
                  Navigator.pop(context);
                  _fetchBalances();
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Opening Balance",style: TextStyle(fontSize: 13),),
        centerTitle: true,
        actions: [

          Padding(padding: EdgeInsets.all(10),

          child:  GestureDetector(

      child: Icon(Icons.edit,color: Colors.black,size: 25,),

    onTap:() {
      _editBalance(_balances["id"], _dateController.text, _balances["amount"]);
    }),
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
                labelText: "Select Date",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child:   Center(child: Text(" opening balance : "+_balances["amount"].toString()))

            ),
          ],
        ),
      ),
    );
  }
}
