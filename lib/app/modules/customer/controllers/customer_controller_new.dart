import 'package:flutter/material.dart';
import '../../../../app/core/data/index.dart';
import '../models/customer_model.dart';

/// 客户管理控制器 - 使用抽象框架
class CustomerControllerNew extends DataController<CustomerModel> {
  @override
  DataPageConfig get config => DataPageConfig.customer;

  @override
  CustomerModel fromJson(Map<String, dynamic> json) => CustomerModel.fromJson(json);

  @override
  List<CustomerModel> getMockData() => [
    CustomerModel(
      id: 1,
      name: '零售客户',
      contact: '散客',
      phone: '',
      balance: 0,
    ),
    CustomerModel(
      id: 2,
      name: '永辉便利店',
      contact: '王老板',
      phone: '13900139001',
      address: '北京市朝阳区建国路88号',
      balance: 5000.00,
    ),
    CustomerModel(
      id: 3,
      name: '美佳超市',
      contact: '李经理',
      phone: '13900139002',
      address: '上海市浦东新区浦东路100号',
      balance: 12000.00,
    ),
    CustomerModel(
      id: 4,
      name: '阳光便利店',
      contact: '张老板',
      phone: '13900139003',
      address: '广州市天河区天河路50号',
      balance: 8000.00,
    ),
  ];
}