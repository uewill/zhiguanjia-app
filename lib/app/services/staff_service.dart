// 职员服务
import 'package:dio/dio.dart';
import '../data/models/staff_model.dart';
import 'api_service.dart';

class StaffService {
  final ApiService _apiService;

  StaffService(this._apiService);

  // 获取职员列表
  Future<List<Staff>> getStaffList({String? departmentId, int? status}) async {
    try {
      final response = await _apiService.dio.get('/staff', queryParameters: {
        if (departmentId != null) 'departmentId': departmentId,
        if (status != null) 'status': status,
      });
      if (response.data['code'] == 200) {
        return (response.data['data'] as List)
            .map((e) => Staff.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      print('获取职员列表失败: $e');
      return _getMockStaffList();
    }
  }

  // 获取职员详情
  Future<Staff?> getStaffDetail(String staffId) async {
    try {
      final response = await _apiService.dio.get('/staff/$staffId');
      if (response.data['code'] == 200) {
        return Staff.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('获取职员详情失败: $e');
      return null;
    }
  }

  // 创建职员
  Future<bool> createStaff(Staff staff) async {
    try {
      final response = await _apiService.dio.post('/staff', data: staff.toJson());
      return response.data['code'] == 200;
    } catch (e) {
      print('创建职员失败: $e');
      return false;
    }
  }

  // 更新职员
  Future<bool> updateStaff(String staffId, Staff staff) async {
    try {
      final response = await _apiService.dio.put('/staff/$staffId', data: staff.toJson());
      return response.data['code'] == 200;
    } catch (e) {
      print('更新职员失败: $e');
      return false;
    }
  }

  // 删除职员
  Future<bool> deleteStaff(String staffId) async {
    try {
      final response = await _apiService.dio.delete('/staff/$staffId');
      return response.data['code'] == 200;
    } catch (e) {
      print('删除职员失败: $e');
      return false;
    }
  }

  // 分配角色
  Future<bool> assignRoles(String staffId, List<String> roleIds) async {
    try {
      final response = await _apiService.dio.put(
        '/staff/$staffId/roles',
        data: {'roleIds': roleIds},
      );
      return response.data['code'] == 200;
    } catch (e) {
      print('分配角色失败: $e');
      return false;
    }
  }

  // 获取部门列表
  Future<List<Department>> getDepartments() async {
    try {
      final response = await _apiService.dio.get('/departments');
      if (response.data['code'] == 200) {
        return (response.data['data'] as List)
            .map((e) => Department.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      print('获取部门列表失败: $e');
      return _getMockDepartments();
    }
  }

  // Mock数据
  List<Staff> _getMockStaffList() {
    return [
      Staff(
        id: '1',
        name: '张三',
        phone: '13800138000',
        departmentId: '1',
        departmentName: '销售部',
        position: '销售员',
        roleIds: ['salesperson'],
        createTime: DateTime(2024, 1, 1),
        updateTime: DateTime(2024, 1, 1),
      ),
      Staff(
        id: '2',
        name: '李四',
        phone: '13800138001',
        departmentId: '2',
        departmentName: '采购部',
        position: '采购员',
        roleIds: ['purchaser'],
        createTime: DateTime(2024, 1, 1),
        updateTime: DateTime(2024, 1, 1),
      ),
      Staff(
        id: '3',
        name: '王五',
        phone: '13800138002',
        departmentId: '3',
        departmentName: '仓库',
        position: '库管',
        roleIds: ['warehouse'],
        createTime: DateTime(2024, 1, 1),
        updateTime: DateTime(2024, 1, 1),
      ),
    ];
  }

  List<Department> _getMockDepartments() {
    return [
      Department(id: '1', name: '销售部', sort: 1, createTime: DateTime.now()),
      Department(id: '2', name: '采购部', sort: 2, createTime: DateTime.now()),
      Department(id: '3', name: '仓库', sort: 3, createTime: DateTime.now()),
      Department(id: '4', name: '财务部', sort: 4, createTime: DateTime.now()),
      Department(id: '5', name: '行政部', sort: 5, createTime: DateTime.now()),
    ];
  }
}
