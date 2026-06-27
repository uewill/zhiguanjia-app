import '../../../../app/core/data/index.dart';

/// 仓库数据模型
class WarehouseModel implements DataItem {
  @override
  final int? id;
  @override
  final String name;
  @override
  final String? code;
  @override
  final bool isActive;
  
  final String? address;
  final String? remark;
  final bool isDefault;
  final int? managerId;
  final String? managerName;

  WarehouseModel({
    this.id,
    required this.name,
    this.code,
    this.address,
    this.remark,
    this.isDefault = false,
    this.managerId,
    this.managerName,
    this.isActive = true,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'],
      address: json['address'],
      remark: json['remark'],
      isDefault: json['isDefault'] ?? false,
      managerId: json['managerId'],
      managerName: json['managerName'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'address': address,
    'remark': remark,
    'isDefault': isDefault,
    'managerId': managerId,
    'managerName': managerName,
    'isActive': isActive,
  };
}