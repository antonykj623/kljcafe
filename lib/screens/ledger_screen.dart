import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../databaseHelper/databasehelper.dart';
import '../model/ledger.dart';
import '../utils/ledgrexporter.dart';


class LedgerScreen extends StatefulWidget {
  @override
  _LedgerScreenState createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  List<Ledger> ledgerList = [];
  String selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  Map<String,dynamic> _balances = {};
  @override
  void initState() {
    super.initState();
    _fetchBalances();

  }

  Future<void> _fetchBalances() async {
    final parsedDate = DateFormat('dd/MM/yyyy').parse(selectedDate);

    // Then format to yyyy-MM-dd
    String d= DateFormat('yyyy-MM-dd').format(parsedDate);
    final data = await new DatabaseHelper().getOpeningBalanceByDate(d);
    setState(() {
      _balances = data;
    });
    _loadLedger();
  }

  Future<void> _loadLedger() async {
    final data = await DatabaseHelper().getLedgerByDate(selectedDate);
    setState(() {
      ledgerList = data;
    });
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,

      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
      _fetchBalances();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ledger - $selectedDate",style: TextStyle(fontSize: 13),),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: _pickDate,
          )
        ],
      ),
      body: ledgerList.isEmpty
          ? Center(child: Text("No transactions for $selectedDate"))
          : Column(
        children: [
          Center(child: Text(" opening balance : "+_balances["amount"].toString())),
          SizedBox(height: 10,),




          Expanded(child:ListView.builder(
            itemCount: ledgerList.length,
            itemBuilder: (context, index) {
              final ledger = ledgerList[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(
                    ledger.type == "income"
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: ledger.type == "income" ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    "₹ ${ledger.amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: ledger.type == "income"
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(ledger.description),
                  trailing: Text(ledger.date),
                ),
              );
            },
          ),flex: 3, ),
          Expanded(child: Column(
            children: [
// Single date example
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Export Ledger (Today)'),
                onPressed: () async {
                  final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
                  final file = await LedgerExporter.exportByDate(today);
                  // Optionally auto-share after save:
                  await LedgerExporter.shareFile(file);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ledger saved: ${file.path}')),
                  );
                },
              ),

// Date range example
              ElevatedButton.icon(
                icon: const Icon(Icons.file_download),
                label: const Text('Export Ledger (This Month)'),
                onPressed: () async {
                  final now = DateTime.now();
                  final from = DateFormat('dd/MM/yyyy').format(DateTime(now.year, now.month, 1));
                  final to = DateFormat('dd/MM/yyyy').format(DateTime(now.year, now.month + 1, 0));
                  final file = await LedgerExporter.exportByRange(from, to);
                  await LedgerExporter.shareFile(file);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ledger saved: ${file.path}')),
                  );
                },
              ),

            ],
          ),flex: 1,)

        ],
      )




    );
  }
}
