import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kljcafe/screens/employeelist.dart';

import '../databaseHelper/databasehelper.dart';
import '../model/Employee.dart';

class EmployeeScreen extends StatefulWidget {
  @override
  _EmployeeScreenState createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _joiningDateCtrl = TextEditingController();

  String? photoPath;
  String? documentPath;

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
    final data = await DatabaseHelper().getEmployees();
    setState(() {
      employees = data;
    });
  }

  Future<void> _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      final emp = Employee(
        name: _nameCtrl.text,
        age: int.tryParse(_ageCtrl.text) ?? 0,
        address: _addressCtrl.text,
        phone: _phoneCtrl.text,
        photo: photoPath,
        documents: documentPath,
        joiningDate: _joiningDateCtrl.text,
      );

      await DatabaseHelper().insertEmployee(emp);
      _clearForm();
      _loadEmployees();
    }
  }

  void _clearForm() {
    _nameCtrl.clear();
    _ageCtrl.clear();
    _addressCtrl.clear();
    _phoneCtrl.clear();
    _joiningDateCtrl.clear();
    photoPath = null;
    documentPath = null;
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _joiningDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickPhoto() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        photoPath = pickedFile.path;
      });
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        documentPath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Employees",style: TextStyle(fontSize: 13),),actions: [
        
        GestureDetector(
          
          onTap: () async {


            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EmployeeListPage(dbHelper: new DatabaseHelper())));

          },
          child: Padding(
            
            padding: EdgeInsets.all(10),
            child: Icon(Icons.person,color: Colors.black,size: 30,),
          ),
        )
        
        
      ],),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(labelText: "Name"),
                      validator: (v) => v!.isEmpty ? "Enter name" : null,
                    ),
                    TextFormField(
                      controller: _ageCtrl,
                      decoration: InputDecoration(labelText: "Age"),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: InputDecoration(labelText: "Address"),
                    ),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: InputDecoration(labelText: "Phone"),
                      keyboardType: TextInputType.phone,
                    ),
                    TextFormField(
                      controller: _joiningDateCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Joining Date",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: _pickDate,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Photo Picker
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickPhoto,
                          icon: Icon(Icons.photo),
                          label: Text("Pick Photo"),
                        ),
                        SizedBox(width: 10),
                        photoPath != null
                            ? Image.file(File(photoPath!), width: 50, height: 50, fit: BoxFit.cover)
                            : Text("No photo"),
                      ],
                    ),

                    SizedBox(height: 10),

                    // Document Picker
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickDocument,
                          icon: Icon(Icons.attach_file),
                          label: Text("Pick Document"),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(documentPath ?? "No document"),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _saveEmployee,
                      child: Text("Save Employee"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(),

        ],
      ),
    );
  }
}
