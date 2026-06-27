import '../../../../app/core/data/index.dart';

/// 客户数据模型
class CustomerModel implements DataItem {
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

  CustomerModel({
    this.id,
    required this.name,
    this.code,
    this.contact,
    this.phone,
    this.address,
    this.remark,
    this.balance,
    this.isActive = true,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'],
      contact: json['contact'],
      phone: json['phone'],
      address: json['address'],
      remark: json['remark'],
      balance: (json['balance'] as num?)?.toDouble(),
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
    'isActive': isActive,
  };

  CustomerModel copyWith({
    int? id,
    String? name,
    String? code,
    String? contact,
    String? phone,
    String? address,
    String? remark,
    double? balance,
    bool? isActive,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      contact: contact ?? this.contact,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      remark: remark ?? this.remark,
      balance: balance ?? this.balance,
      isActive: isActive ?? this.isActive,
    );
  }
}