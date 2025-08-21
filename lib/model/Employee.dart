class Employee {
  final int? id;
  final String name;
  final int age;
  final String? photo;
  final String address;
  final String phone;
  final String? documents;
  final String joiningDate; // YYYY-MM-DD

  Employee({
    this.id,
    required this.name,
    required this.age,
    this.photo,
    required this.address,
    required this.phone,
    this.documents,
    required this.joiningDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'photo': photo,
      'address': address,
      'phone': phone,
      'documents': documents,
      'joiningDate': joiningDate,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      photo: map['photo'],
      address: map['address'],
      phone: map['phone'],
      documents: map['documents'],
      joiningDate: map['joiningDate'],
    );
  }
}
