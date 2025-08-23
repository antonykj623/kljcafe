import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../databaseHelper/databasehelper.dart';
import '../model/ledger.dart';


class IncomeListScreen extends StatefulWidget {
  @override
  _IncomeListScreenState createState() => _IncomeListScreenState();
}

class _IncomeListScreenState extends State<IncomeListScreen> {
  List<Ledger> incomeList = [];
  String selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _loadIncome();
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

  Future<void> _loadIncome() async {
    final data = await DatabaseHelper().getIncomeByDate(selectedDate);
    setState(() {
      incomeList = data;
    });
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
      _loadIncome();
    }
  }

  Future<void> _editIncome(Ledger income) async {
    TextEditingController amountController =
    TextEditingController(text: income.amount.toString());
    TextEditingController descriptionController =
    TextEditingController(text: income.description);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Income"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                double updatedAmount =
                    double.tryParse(amountController.text) ?? income.amount;
                String updatedDescription = descriptionController.text;

                // Update database
                final db = await DatabaseHelper().db;
                await db.update(
                  "transactions",
                  {
                    "amount": updatedAmount,
                    "description": updatedDescription,
                  },
                  where: "id = ?",
                  whereArgs: [income.id],
                );

                Navigator.pop(context);
                _loadIncome(); // refresh list
              },
              child: Text("Save"),
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
        title: Text("Income on $selectedDate",style: TextStyle(fontSize: 13),),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: _pickDate,
          )
        ],
      ),
      body: incomeList.isEmpty
          ? Center(child: Text("No income records on $selectedDate"))
          : ListView.builder(
        itemCount: incomeList.length,
        itemBuilder: (context, index) {
          final income = incomeList[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(Icons.arrow_upward, color: Colors.green),
              title: Text(
                "₹ ${income.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(income.description),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editIncome(income),
              ),
            ),
          );
        },
      ),
    );
  }
}
