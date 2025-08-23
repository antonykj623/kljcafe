import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../databaseHelper/databasehelper.dart';
import '../model/ledger.dart';


class ExpenseListScreen extends StatefulWidget {
  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Ledger> expenseList = [];
  String selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _loadExpense();
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

  Future<void> _loadExpense() async {
    final data = await DatabaseHelper().getExpenseByDate(selectedDate);
    setState(() {
      expenseList = data;
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
      _loadExpense();
    }
  }

  Future<void> _editExpense(Ledger expense) async {
    TextEditingController amountController =
    TextEditingController(text: expense.amount.toString());
    TextEditingController descriptionController =
    TextEditingController(text: expense.description);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Expense"),
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
                    double.tryParse(amountController.text) ?? expense.amount;
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
                  whereArgs: [expense.id],
                );

                Navigator.pop(context);
                _loadExpense(); // refresh list
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
        title: Text("Expenses on $selectedDate",style: TextStyle(fontSize: 13),),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: _pickDate,
          )
        ],
      ),
      body: expenseList.isEmpty
          ? Center(child: Text("No expense records on $selectedDate"))
          : ListView.builder(
        itemCount: expenseList.length,
        itemBuilder: (context, index) {
          final expense = expenseList[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(Icons.arrow_downward, color: Colors.red),
              title: Text(
                "₹ ${expense.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(expense.description),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editExpense(expense),
              ),
            ),
          );
        },
      ),
    );
  }
}
