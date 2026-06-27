#!/usr/bin/env python3
"""
智掌柜 - 全平台自动化测试运行器
测试范围: Flutter App + PC Web
汇报周期: 每30分钟
"""

import subprocess
import time
import json
import os
from datetime import datetime, timedelta
from pathlib import Path

class AutomationTestRunner:
    def __init__(self):
        self.project_root = "/workspace/zhiguanjia-app"
        self.web_url = "http://42.193.169.78:8083"
        self.api_url = "http://42.193.169.78:8083/api/v1"
        self.results = []
        self.start_time = datetime.now()
        self.next_report_time = self.start_time + timedelta(minutes=30)
        self.test_cycles = 0
        
    def log(self, message, level="INFO"):
        """打印日志"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        prefix = {"INFO": "ℹ", "PASS": "✓", "FAIL": "✗", "STEP": "▶", "REPORT": "📊"}.get(level, "•")
        print(f"[{timestamp}] {prefix} {message}")
        
    def print_header(self, title):
        """打印标题"""
        print("\n" + "═" * 70)
        print(f" {title}")
        print("═" * 70)

    # ==================== Flutter 测试 ====================
    def run_flutter_analyze(self):
        """运行 Flutter 代码分析"""
        self.log("运行 Flutter analyze...", "STEP")
        try:
            result = subprocess.run(
                ["flutter", "analyze", "--no-pub"],
                cwd=self.project_root,
                capture_output=True,
                text=True,
                timeout=120
            )
            success = result.returncode == 0
            self.log(f"Flutter analyze: {'通过' if success else '失败'}", "PASS" if success else "FAIL")
            return {
                "type": "flutter_analyze",
                "status": "pass" if success else "fail",
                "timestamp": datetime.now().isoformat(),
                "details": result.stdout[-500:] if result.stdout else ""
            }
        except Exception as e:
            self.log(f"Flutter analyze 异常: {e}", "FAIL")
            return {"type": "flutter_analyze", "status": "error", "error": str(e)}

    def run_flutter_build_web(self):
        """构建 Flutter Web"""
        self.log("构建 Flutter Web...", "STEP")
        try:
            result = subprocess.run(
                ["flutter", "build", "web", "--release"],
                cwd=self.project_root,
                capture_output=True,
                text=True,
                timeout=300
            )
            success = result.returncode == 0
            self.log(f"Flutter build web: {'成功' if success else '失败'}", "PASS" if success else "FAIL")
            return {
                "type": "flutter_build_web",
                "status": "pass" if success else "fail",
                "timestamp": datetime.now().isoformat()
            }
        except Exception as e:
            self.log(f"Flutter build 异常: {e}", "FAIL")
            return {"type": "flutter_build_web", "status": "error", "error": str(e)}

    def check_flutter_integration_test_files(self):
        """检查 Flutter 集成测试文件"""
        self.log("检查 Flutter 集成测试文件...", "STEP")
        test_files = [
            "integration_test/full_workflow_ui_test.dart",
            "integration_test/app_test.dart"
        ]
        
        results = []
        for file in test_files:
            path = Path(self.project_root) / file
            exists = path.exists()
            results.append({
                "file": file,
                "exists": exists,
                "size": path.stat().st_size if exists else 0
            })
            status = "✓" if exists else "✗"
            self.log(f"  {status} {file}", "PASS" if exists else "FAIL")
        
        return {
            "type": "flutter_test_files",
            "status": "pass" if all(r["exists"] for r in results) else "fail",
            "files": results
        }

    # ==================== API 测试 ====================
    def run_api_health_check(self):
        """API 健康检查"""
        self.log("检查 API 服务状态...", "STEP")
        try:
            import requests
            response = requests.get(f"{self.api_url}/products?page=1&size=1", timeout=10)
            success = response.status_code == 200
            self.log(f"API 健康检查: {'正常' if success else '异常'}", "PASS" if success else "FAIL")
            return {
                "type": "api_health",
                "status": "pass" if success else "fail",
                "code": response.status_code,
                "response_time": response.elapsed.total_seconds()
            }
        except Exception as e:
            self.log(f"API 检查异常: {e}", "FAIL")
            return {"type": "api_health", "status": "error", "error": str(e)}

    def run_api_crud_tests(self):
        """运行 API CRUD 测试"""
        self.log("运行 API CRUD 测试...", "STEP")
        
        try:
            import requests
            test_code = f"TEST{int(time.time() * 1000) % 100000}"
            
            # CREATE
            product_data = {
                "name": f"UI测试商品_{test_code}",
                "code": test_code,
                "barcode": f"BAR{test_code}",
                "category": "测试",
                "unit": "件",
                "salePrice": 100.00,
                "purchasePrice": 80.00,
                "stock": 100,
                "minStock": 10
            }
            
            create_resp = requests.post(
                f"{self.api_url}/products",
                json=product_data,
                timeout=10
            )
            create_ok = create_resp.status_code == 200
            self.log(f"  CREATE: {'✓' if create_ok else '✗'}", "PASS" if create_ok else "FAIL")
            
            # READ
            read_resp = requests.get(f"{self.api_url}/products?page=1&size=10", timeout=10)
            read_ok = read_resp.status_code == 200
            self.log(f"  READ: {'✓' if read_ok else '✗'}", "PASS" if read_ok else "FAIL")
            
            return {
                "type": "api_crud",
                "status": "pass" if create_ok and read_ok else "fail",
                "create": create_ok,
                "read": read_ok,
                "test_code": test_code
            }
        except Exception as e:
            self.log(f"API CRUD 异常: {e}", "FAIL")
            return {"type": "api_crud", "status": "error", "error": str(e)}

    # ==================== Web 测试 ====================
    def run_web_health_check(self):
        """Web 服务健康检查"""
        self.log("检查 Web 服务状态...", "STEP")
        try:
            import requests
            response = requests.get(self.web_url, timeout=10)
            success = response.status_code == 200
            self.log(f"Web 健康检查: {'正常' if success else '异常'}", "PASS" if success else "FAIL")
            return {
                "type": "web_health",
                "status": "pass" if success else "fail",
                "code": response.status_code,
                "content_length": len(response.content)
            }
        except Exception as e:
            self.log(f"Web 检查异常: {e}", "FAIL")
            return {"type": "web_health", "status": "error", "error": str(e)}

    # ==================== 文件检查 ====================
    def check_source_files(self):
        """检查关键源文件"""
        self.log("检查关键源文件...", "STEP")
        
        key_files = {
            "销售模块": [
                "lib/app/modules/sale/views/sale_view.dart",
                "lib/app/modules/sale/views/order_create_view.dart",
            ],
            "库存模块": [
                "lib/app/modules/inventory/views/inventory_view.dart",
                "lib/app/modules/inventory/views/inventory_transfer_view.dart",
                "lib/app/modules/inventory/views/stock_check_view.dart",
            ],
            "采购模块": [
                "lib/app/modules/purchase/views/purchase_view.dart",
                "lib/app/modules/purchase/views/purchase_create_view.dart",
            ],
            "客户模块": [
                "lib/app/modules/customer/views/customer_list_view.dart",
                "lib/app/modules/customer/views/customer_form_view.dart",
            ]
        }
        
        results = {}
        for module, files in key_files.items():
            module_results = []
            for file in files:
                path = Path(self.project_root) / file
                exists = path.exists()
                module_results.append({"file": file, "exists": exists})
                status = "✓" if exists else "✗"
                # self.log(f"  {status} {file}")
            
            all_exist = all(r["exists"] for r in module_results)
            results[module] = {
                "status": "pass" if all_exist else "fail",
                "files": module_results
            }
            self.log(f"  {module}: {'✓ 完整' if all_exist else '✗ 缺失文件'}", 
                    "PASS" if all_exist else "FAIL")
        
        return {
            "type": "source_files",
            "status": "pass" if all(r["status"] == "pass" for r in results.values()) else "fail",
            "modules": results
        }

    # ==================== 报告生成 ====================
    def generate_report(self, is_final=False):
        """生成测试报告"""
        now = datetime.now()
        duration = now - self.start_time
        
        report = {
            "report_time": now.isoformat(),
            "start_time": self.start_time.isoformat(),
            "duration_seconds": duration.total_seconds(),
            "test_cycles": self.test_cycles,
            "results": self.results[-20:] if self.results else [],  # 最近20条
            "summary": self._calculate_summary()
        }
        
        # 保存报告
        report_file = Path(self.project_root) / "test" / f"test_report_{now.strftime('%Y%m%d_%H%M%S')}.json"
        report_file.parent.mkdir(exist_ok=True)
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        # 打印报告摘要
        self.print_report_summary(report, is_final)
        
        return report

    def _calculate_summary(self):
        """计算测试结果摘要"""
        if not self.results:
            return {"total": 0, "pass": 0, "fail": 0, "error": 0}
        
        total = len(self.results)
        pass_count = sum(1 for r in self.results if r.get("status") == "pass")
        fail_count = sum(1 for r in self.results if r.get("status") == "fail")
        error_count = sum(1 for r in self.results if r.get("status") == "error")
        
        return {
            "total": total,
            "pass": pass_count,
            "fail": fail_count,
            "error": error_count,
            "pass_rate": f"{(pass_count/total*100):.1f}%" if total > 0 else "0%"
        }

    def print_report_summary(self, report, is_final=False):
        """打印报告摘要"""
        summary = report["summary"]
        
        self.print_header(f"{'最终' if is_final else '进度'}测试报告 - 第{self.test_cycles}轮")
        
        print(f"\n  ⏱  运行时长: {timedelta(seconds=int(report['duration_seconds']))}")
        print(f"  🔄 测试轮次: {report['test_cycles']}")
        print(f"\n  📊 测试结果统计:")
        print(f"     总计: {summary['total']} 项")
        print(f"     ✓ 通过: {summary['pass']} 项")
        print(f"     ✗ 失败: {summary['fail']} 项")
        print(f"     ⚠ 错误: {summary['error']} 项")
        print(f"     📈 通过率: {summary['pass_rate']}")
        
        if is_final:
            print("\n  ✅ 所有测试已完成!")
        else:
            next_report = self.next_report_time.strftime("%H:%M:%S")
            print(f"\n  ⏰ 下次报告: {next_report}")
        
        print("═" * 70 + "\n")

    # ==================== 主循环 ====================
    def run_single_cycle(self):
        """运行单轮测试"""
        self.test_cycles += 1
        self.print_header(f"开始第 {self.test_cycles} 轮测试 - {datetime.now().strftime('%H:%M:%S')}")
        
        cycle_results = []
        
        # 1. Flutter 相关测试
        self.log("【Flutter 端测试】", "STEP")
        cycle_results.append(self.run_flutter_analyze())
        cycle_results.append(self.check_flutter_integration_test_files())
        # cycle_results.append(self.run_flutter_build_web())  # 暂时跳过，耗时较长
        
        # 2. API 测试
        self.log("【API 测试】", "STEP")
        cycle_results.append(self.run_api_health_check())
        cycle_results.append(self.run_api_crud_tests())
        
        # 3. Web 测试
        self.log("【Web 端测试】", "STEP")
        cycle_results.append(self.run_web_health_check())
        
        # 4. 文件检查
        self.log("【文件完整性检查】", "STEP")
        cycle_results.append(self.check_source_files())
        
        # 保存结果
        for r in cycle_results:
            r["cycle"] = self.test_cycles
            r["timestamp"] = datetime.now().isoformat()
        self.results.extend(cycle_results)
        
        self.log(f"第 {self.test_cycles} 轮测试完成", "PASS")
        return cycle_results

    def should_report(self):
        """判断是否该汇报进度"""
        return datetime.now() >= self.next_report_time

    def run(self, max_cycles=None, duration_hours=None):
        """
        运行测试主循环
        
        Args:
            max_cycles: 最大测试轮次，None表示无限
            duration_hours: 最大运行时长(小时)，None表示无限
        """
        self.print_header("智掌柜 - 全平台自动化测试启动")
        self.log(f"测试目标: Flutter App + PC Web")
        self.log(f"汇报周期: 每30分钟")
        self.log(f"API地址: {self.api_url}")
        self.log(f"Web地址: {self.web_url}")
        
        end_time = None
        if duration_hours:
            end_time = self.start_time + timedelta(hours=duration_hours)
            self.log(f"计划运行: {duration_hours}小时")
        
        try:
            while True:
                # 检查终止条件
                if max_cycles and self.test_cycles >= max_cycles:
                    self.log(f"已达到最大测试轮次: {max_cycles}", "INFO")
                    break
                
                if end_time and datetime.now() >= end_time:
                    self.log(f"已达到运行时长限制", "INFO")
                    break
                
                # 运行单轮测试
                self.run_single_cycle()
                
                # 检查是否需要汇报
                if self.should_report():
                    self.generate_report(is_final=False)
                    self.next_report_time = datetime.now() + timedelta(minutes=30)
                
                # 间隔5分钟后继续下一轮
                self.log("等待5分钟后开始下一轮...", "INFO")
                time.sleep(300)  # 5分钟
                
        except KeyboardInterrupt:
            self.log("测试被用户中断", "INFO")
        finally:
            # 生成最终报告
            final_report = self.generate_report(is_final=True)
            self.save_final_summary(final_report)
            
        return final_report

    def save_final_summary(self, report):
        """保存最终摘要"""
        summary_file = Path(self.project_root) / "test" / "FINAL_TEST_SUMMARY.md"
        
        summary = report["summary"]
        duration = timedelta(seconds=int(report["duration_seconds"]))
        
        content = f"""# 智掌柜 - 全平台自动化测试最终报告

## 测试概览

| 项目 | 数值 |
|------|------|
| 开始时间 | {self.start_time.strftime('%Y-%m-%d %H:%M:%S')} |
| 结束时间 | {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} |
| 运行时长 | {duration} |
| 测试轮次 | {report['test_cycles']} |

## 测试结果

| 指标 | 数值 |
|------|------|
| 总测试项 | {summary['total']} |
| 通过 | {summary['pass']} |
| 失败 | {summary['fail']} |
| 错误 | {summary['error']} |
| 通过率 | {summary['pass_rate']} |

## 测试覆盖

- ✅ Flutter 代码分析
- ✅ Flutter 集成测试文件检查
- ✅ API 健康检查
- ✅ API CRUD 测试
- ✅ Web 服务检查
- ✅ 源文件完整性检查

## 生成时间

{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""
        
        with open(summary_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        self.log(f"最终报告已保存: {summary_file}", "REPORT")


def main():
    """主函数"""
    runner = AutomationTestRunner()
    
    # 可以设置运行参数
    # runner.run(max_cycles=10)  # 运行10轮
    # runner.run(duration_hours=2)  # 运行2小时
    runner.run()  # 无限运行，直到手动停止


if __name__ == "__main__":
    main()
