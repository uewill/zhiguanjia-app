import 'package:get/get.dart';
import '../../../../app/core/data/index.dart';
import '../models/supplier_model_new.dart';

/// 供应商管理控制器 - 使用抽象框架
class SupplierControllerNew extends DataController<SupplierModel> {
  @override
  DataPageConfig get config => DataPageConfig.supplier;

  @override
  SupplierModel fromJson(Map<String, dynamic> json) => 
      SupplierModel.fromJson(json);

  @override
  List<SupplierModel> getMockData() => [
    SupplierModel(
      id: 1,
      name: '百事可乐有限公司',
      contact: '张经理',
      phone: '13800138001',
      address: '北京市朝阳区建国路88号',
      balance: 10000.00,
    ),
    SupplierModel(
      id: 2,
      name: '可口可乐(中国)',
      contact: '李经理',
      phone: '13800138002',
      address: '上海市浦东新区世纪大道1号',
      balance: 8000.00,
    ),
    SupplierModel(
      id: 3,
      name: '康师傅控股',
      contact: '王经理',
      phone: '13800138003',
      address: '天津市滨海新区开发区',
      balance: 5000.00,
    ),
  ];
}