import '../../../../app/core/data/index.dart';

/// 供应商数据模型
class SupplierModel implements DataItem {
  @override
  final int? id;
  @override
  final String name;
  @override
  final String? code;
  @override
  final bool isActive;
  
  final String? contact;
  final String? phone;
  final String? address;
  final String? remark;
  final double? balance;
  final String? email;

  SupplierModel({
    this.id,
    required this.name,
    this.code,
    this.contact,
    this.phone,
    this.address,
    this.remark,
    this.balance,
    this.email,
    this.isActive = true,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'],
      contact: json['contact'],
      phone: json['phone'],
      address: json['address'],
      remark: json['remark'],
      balance: (json['balance'] as num?)?.toDouble(),
      email: json['email'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'contact': contact,
    'phone': phone,
    'address': address,
    'remark': remark,
    'balance': balance,
    'email': email,
    'isActive': isActive,
  };
}