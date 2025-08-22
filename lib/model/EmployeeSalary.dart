class EmployeeSalary {
  final int employeeId;
  final double salary;
  final DateTime salaryDate;
  final double amount;
  final String paymentMode; // "Cash" or "Online"

  EmployeeSalary({
    required this.employeeId,
    required this.salary,
    required this.salaryDate,
    required this.amount,
    required this.paymentMode,
  });

  Map<String, dynamic> toMap() {
    return {
      'employee_id': employeeId,
      'salary': salary,
      'salary_date': salaryDate.toIso8601String(),
      'amount': amount,
      'payment_mode': paymentMode,
    };
  }
}
