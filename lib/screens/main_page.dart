import 'package:flutter/material.dart';
import 'package:kljcafe/screens/expense_screen.dart';
import 'package:kljcafe/screens/income_screen.dart';
import 'package:intl/intl.dart';
import '../databaseHelper/databasehelper.dart';
import 'ledger_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double income = 0;
  double expense = 0;
  double ledgerBalance = 0;

  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      getDataByDate();
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      _selectedDate = DateTime.now();
    });

    getDataByDate();

  }



  getDataByDate()
  async {

    final String _todayDate = DateFormat('dd/MM/yyyy').format(DateTime.now());


    final totals = await DatabaseHelper().getTotalsByDate(_todayDate);

    setState(() {
      income = (totals['income'] as num?)?.toDouble() ?? 0.0;
      expense = (totals['expense'] as num?)?.toDouble() ?? 0.0;
      ledgerBalance = (totals['balance'] as num?)?.toDouble() ?? 0.0;



    });



  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(padding: EdgeInsets.all(10),

        child: Image.asset("assets/icon.png",width: 20,height: 20,) ,

        )

,
        title:  Text("Dashboard",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Container(
              width: double.infinity,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Select Date"),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    _selectedDate == null
                        ? "No date selected"
                        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),

            ),




            SizedBox(height: 10,),
            Row(
              children: [
                Expanded(child: _buildCard("Income", income, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildCard("Expense", expense, Colors.red)),
              ],
            ),
            const SizedBox(height: 12),
            _buildCard("Ledger Balance", ledgerBalance, Colors.blue),
            const SizedBox(height: 24),

            // Ledger List Section


          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, double amount, Color color) {
    return GestureDetector(

      child:Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                "₹ ${amount.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ) ,
      onTap: () async {
        if(title.compareTo("Income")==0)
          {

            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddIncomePage()),
            );

            if (result != null||result==null) {

             getDataByDate();

            }

          }
        else  if(title.compareTo("Expense")==0)
        {

          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpensePage()),
          );

          if (result != null||result==null) {

            getDataByDate();

          }
        }
        else{


          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LedgerScreen()),
          );

          if (result != null||result==null) {

            getDataByDate();

          }

        }
      },
    )



      ;
  }
}
