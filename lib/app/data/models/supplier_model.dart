class Supplier {
  final int id;
  final String name;
  final String? contact;
  final String? phone;

  Supplier({
    required this.id,
    required this.name,
    this.contact,
    this.phone,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      phone: json['phone'],
    );
  }
}
