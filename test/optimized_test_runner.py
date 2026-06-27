#!/usr/bin/env python3
"""
智掌柜 - 智能优化测试运行器
特性:
1. 智能缓存 - 跳过上轮通过的测试
2. 失败重试 - 自动重试失败项(最多3次)
3. 并行执行 - 独立测试并发运行
4. 优先级调度 - 核心功能优先
5. 增量测试 - 只测变更模块
6. 自适应间隔 - 根据成功率调整频率
"""

import subprocess
import time
import json
import os
import hashlib
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Any, Optional
import requests

class OptimizedTestRunner:
    def __init__(self):
        self.project_root = "/workspace/zhiguanjia-app"
        self.cache_file = Path(self.project_root) / "test" / ".test_cache.json"
        self.state_file = Path(self.project_root) / "test" / ".test_state.json"
        self.web_url = "http://42.193.169.78:8083"
        self.api_url = "http://42.193.169.78:8083/api/v1"
        
        # 测试配置
        self.config = {
            "max_retries": 3,           # 失败最大重试次数
            "retry_delay": 5,           # 重试间隔(秒)
            "parallel_workers": 4,      # 并行线程数
            "cache_ttl": 1800,          # 缓存有效期(30分钟)
            "adaptive_interval": True,  # 自适应间隔
            "base_interval": 300,       # 基础间隔(5分钟)
            "min_interval": 60,         # 最小间隔(1分钟)
            "max_interval": 1800,       # 最大间隔(30分钟)
        }
        
        # 加载缓存和状态
        self.cache = self._load_cache()
        self.state = self._load_state()
        
        # 测试统计
        self.stats = {
            "start_time": datetime.now(),
            "cycles": 0,
            "total_tests": 0,
            "passed": 0,
            "failed": 0,
            "retried": 0,
            "skipped": 0,
            "time_saved": 0,
        }
        
    def _load_cache(self) -> Dict:
        """加载测试缓存"""
        if self.cache_file.exists():
            try:
                with open(self.cache_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except:
                pass
        return {}
    
    def _save_cache(self):
        """保存测试缓存"""
        self.cache_file.parent.mkdir(exist_ok=True)
        with open(self.cache_file, 'w', encoding='utf-8') as f:
            json.dump(self.cache, f, ensure_ascii=False, indent=2)
    
    def _load_state(self) -> Dict:
        """加载测试状态"""
        if self.state_file.exists():
            try:
                with open(self.state_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except:
                pass
        return {"last_run": None, "consecutive_failures": 0, "consecutive_passes": 0}
    
    def _save_state(self):
        """保存测试状态"""
        with open(self.state_file, 'w', encoding='utf-8') as f:
            json.dump(self.state, f, ensure_ascii=False, indent=2)
    
    def _get_file_hash(self, filepath: str) -> str:
        """计算文件哈希(用于增量测试)"""
        try:
            with open(filepath, 'rb') as f:
                return hashlib.md5(f.read()).hexdigest()[:8]
        except:
            return ""
    
    def _should_skip_test(self, test_id: str, filepath: str = None) -> bool:
        """判断是否应该跳过测试(缓存命中且未过期)"""
        if test_id not in self.cache:
            return False
        
        cached = self.cache[test_id]
        cache_time = datetime.fromisoformat(cached.get("timestamp", "2000-01-01"))
        
        # 检查缓存是否过期
        if datetime.now() - cache_time > timedelta(seconds=self.config["cache_ttl"]):
            return False
        
        # 检查文件是否变更(增量测试)
        if filepath and filepath != cached.get("filepath"):
            return False
        
        if filepath:
            current_hash = self._get_file_hash(filepath)
            if current_hash != cached.get("file_hash"):
                return False
        
        return cached.get("status") == "pass"
    
    def _update_cache(self, test_id: str, result: Dict, filepath: str = None):
        """更新测试缓存"""
        self.cache[test_id] = {
            "status": result.get("status"),
            "timestamp": datetime.now().isoformat(),
            "filepath": filepath,
            "file_hash": self._get_file_hash(filepath) if filepath else "",
            "duration": result.get("duration", 0),
        }
        self._save_cache()
    
    def _calculate_adaptive_interval(self) -> int:
        """计算自适应间隔"""
        if not self.config["adaptive_interval"]:
            return self.config["base_interval"]
        
        # 根据连续成功/失败次数调整间隔
        consecutive_passes = self.state.get("consecutive_passes", 0)
        consecutive_failures = self.state.get("consecutive_failures", 0)
        
        if consecutive_passes >= 3:
            # 连续通过,增加间隔
            interval = min(self.config["base_interval"] * (1 + consecutive_passes * 0.5), 
                          self.config["max_interval"])
        elif consecutive_failures >= 2:
            # 连续失败,减少间隔
            interval = max(self.config["base_interval"] / (consecutive_failures + 1), 
                          self.config["min_interval"])
        else:
            interval = self.config["base_interval"]
        
        return int(interval)
    
    def log(self, message: str, level: str = "INFO"):
        """打印日志"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        icons = {
            "INFO": "ℹ", "PASS": "✓", "FAIL": "✗", 
            "STEP": "▶", "REPORT": "📊",
            "SKIP": "⏭", "RETRY": "🔄", "OPTIMIZE": "⚡"
        }
        prefix = icons.get(level, "•")
        print(f"[{timestamp}] {prefix} {message}")

    # ==================== 具体测试实现 ====================
    
    def test_api_health(self) -> Dict:
        """API 健康检查"""
        test_id = "api_health"
        
        # 检查缓存
        if self._should_skip_test(test_id):
            self.stats["skipped"] += 1
            return {"test_id": test_id, "status": "cached", "cached": True}
        
        start = time.time()
        try:
            response = requests.get(f"{self.api_url}/products?page=1&size=1", timeout=10)
            success = response.status_code == 200
            duration = time.time() - start
            
            result = {
                "test_id": test_id,
                "status": "pass" if success else "fail",
                "duration": duration,
                "code": response.status_code,
            }
        except Exception as e:
            result = {
                "test_id": test_id,
                "status": "fail",
                "duration": time.time() - start,
                "error": str(e),
            }
        
        self._update_cache(test_id, result)
        return result
    
    def test_api_create_product(self) -> Dict:
        """API 创建商品测试"""
        test_id = "api_create_product"
        
        if self._should_skip_test(test_id):
            self.stats["skipped"] += 1
            return {"test_id": test_id, "status": "cached", "cached": True}
        
        start = time.time()
        test_code = f"OPT{int(time.time() * 1000) % 100000}"
        
        try:
            product_data = {
                "name": f"优化测试_{test_code}",
                "code": test_code,
                "barcode": f"BAR{test_code}",
                "category": "测试",
                "unit": "件",
                "salePrice": 100.00,
                "purchasePrice": 80.00,
                "stock": 100,
                "minStock": 10,
            }
            
            response = requests.post(
                f"{self.api_url}/products",
                json=product_data,
                timeout=10
            )
            
            success = response.status_code == 200
            result = {
                "test_id": test_id,
                "status": "pass" if success else "fail",
                "duration": time.time() - start,
                "test_code": test_code,
            }
        except Exception as e:
            result = {
                "test_id": test_id,
                "status": "fail",
                "duration": time.time() - start,
                "error": str(e),
            }
        
        self._update_cache(test_id, result)
        return result
    
    def test_web_health(self) -> Dict:
        """Web 健康检查"""
        test_id = "web_health"
        
        if self._should_skip_test(test_id):
            self.stats["skipped"] += 1
            return {"test_id": test_id, "status": "cached", "cached": True}
        
        start = time.time()
        try:
            response = requests.get(self.web_url, timeout=10)
            success = response.status_code == 200
            result = {
                "test_id": test_id,
                "status": "pass" if success else "fail",
                "duration": time.time() - start,
                "code": response.status_code,
            }
        except Exception as e:
            result = {
                "test_id": test_id,
                "status": "fail",
                "duration": time.time() - start,
                "error": str(e),
            }
        
        self._update_cache(test_id, result)
        return result
    
    def test_file_inventory(self) -> Dict:
        """库存模块文件检查"""
        test_id = "file_inventory"
        filepath = f"{self.project_root}/lib/app/modules/inventory/views/inventory_view.dart"
        
        if self._should_skip_test(test_id, filepath):
            self.stats["skipped"] += 1
            return {"test_id": test_id, "status": "cached", "cached": True}
        
        start = time.time()
        files_to_check = [
            Path(self.project_root) / "lib/app/modules/inventory/views/inventory_view.dart",
            Path(self.project_root) / "lib/app/modules/inventory/views/inventory_transfer_view.dart",
            Path(self.project_root) / "lib/app/modules/inventory/views/stock_check_view.dart",
        ]
        
        all_exist = all(f.exists() for f in files_to_check)
        
        result = {
            "test_id": test_id,
            "status": "pass" if all_exist else "fail",
            "duration": time.time() - start,
            "files_checked": len(files_to_check),
        }
        
        self._update_cache(test_id, result, filepath)
        return result
    
    def test_file_sale(self) -> Dict:
        """销售模块文件检查"""
        test_id = "file_sale"
        filepath = f"{self.project_root}/lib/app/modules/sale/views/sale_view.dart"
        
        if self._should_skip_test(test_id, filepath):
            self.stats["skipped"] += 1
            return {"test_id": test_id, "status": "cached", "cached": True}
        
        start = time.time()
        exists = Path(filepath).exists()
        
        result = {
            "test_id": test_id,
            "status": "pass" if exists else "fail",
            "duration": time.time() - start,
        }
        
        self._update_cache(test_id, result, filepath)
        return result
    
    def test_flutter_integration_file(self) -> Dict:
        """Flutter 集成测试文件检查"""
        test_id = "flutter_integration_file"
        filepath = f"{self.project_root}/integration_test/full_workflow_ui_test.dart"
        
        if self._should_skip_test(test_id, filepath):
            self.stats["skipped"] += 1
            return {"test_id": test_id, "status": "cached", "cached": True}
        
        start = time.time()
        exists = Path(filepath).exists()
        
        result = {
            "test_id": test_id,
            "status": "pass" if exists else "fail",
            "duration": time.time() - start,
        }
        
        self._update_cache(test_id, result, filepath)
        return result

    # ==================== 测试执行引擎 ====================
    
    def run_test_with_retry(self, test_func, test_name: str) -> Dict:
        """带重试机制的测试执行"""
        for attempt in range(1, self.config["max_retries"] + 1):
            result = test_func()
            
            if result.get("status") == "pass" or result.get("cached"):
                if attempt > 1:
                    self.stats["retried"] += 1
                    self.log(f"{test_name} 第{attempt}次重试通过", "RETRY")
                return result
            
            if attempt < self.config["max_retries"]:
                self.log(f"{test_name} 失败, {self.config['retry_delay']}秒后重试({attempt}/{self.config['max_retries']-1})...", "RETRY")
                time.sleep(self.config["retry_delay"])
        
        return result
    
    def run_all_tests_parallel(self) -> List[Dict]:
        """并行执行所有测试"""
        tests = [
            (self.test_api_health, "API健康检查"),
            (self.test_api_create_product, "API创建商品"),
            (self.test_web_health, "Web健康检查"),
            (self.test_file_inventory, "库存文件检查"),
            (self.test_file_sale, "销售文件检查"),
            (self.test_flutter_integration_file, "Flutter集成测试文件"),
        ]
        
        results = []
        
        # 使用线程池并行执行
        with ThreadPoolExecutor(max_workers=self.config["parallel_workers"]) as executor:
            future_to_test = {
                executor.submit(self.run_test_with_retry, func, name): (func, name) 
                for func, name in tests
            }
            
            for future in as_completed(future_to_test):
                func, name = future_to_test[future]
                try:
                    result = future.result(timeout=60)
                    results.append(result)
                    
                    status = result.get("status")
                    if status == "cached":
                        self.log(f"{name}: ⏭ 跳过(缓存)", "SKIP")
                    elif status == "pass":
                        self.log(f"{name}: ✓ 通过 ({result.get('duration', 0):.2f}s)", "PASS")
                    else:
                        self.log(f"{name}: ✗ 失败 - {result.get('error', '未知错误')}", "FAIL")
                        
                except Exception as e:
                    self.log(f"{name}: ✗ 异常 - {e}", "FAIL")
                    results.append({"test_id": name, "status": "error", "error": str(e)})
        
        return results
    
    def run_single_cycle(self) -> List[Dict]:
        """运行单轮测试(优化版)"""
        self.stats["cycles"] += 1
        cycle_num = self.stats["cycles"]
        
        print("\n" + "="*70)
        print(f" 🚀 第 {cycle_num} 轮优化测试 - {datetime.now().strftime('%H:%M:%S')}")
        print("="*70)
        
        # 显示优化信息
        cached_count = sum(1 for v in self.cache.values() if v.get("status") == "pass")
        self.log(f"当前缓存: {cached_count} 项通过测试可跳过", "OPTIMIZE")
        
        start_time = time.time()
        results = self.run_all_tests_parallel()
        elapsed = time.time() - start_time
        
        # 统计结果
        passed = sum(1 for r in results if r.get("status") == "pass")
        failed = sum(1 for r in results if r.get("status") == "fail")
        cached = sum(1 for r in results if r.get("status") == "cached")
        
        self.stats["total_tests"] += len(results)
        self.stats["passed"] += passed
        self.stats["failed"] += failed
        
        # 更新状态
        if failed == 0:
            self.state["consecutive_passes"] = self.state.get("consecutive_passes", 0) + 1
            self.state["consecutive_failures"] = 0
        else:
            self.state["consecutive_failures"] = self.state.get("consecutive_failures", 0) + 1
            self.state["consecutive_passes"] = 0
        
        self.state["last_run"] = datetime.now().isoformat()
        self._save_state()
        
        # 显示本轮摘要
        print(f"\n  ⏱  本轮耗时: {elapsed:.2f}s")
        print(f"  ✅ 通过: {passed} | ❌ 失败: {failed} | ⏭ 跳过: {cached}")
        
        interval = self._calculate_adaptive_interval()
        print(f"  ⚡ 自适应间隔: {interval//60}分钟")
        print("="*70 + "\n")
        
        return results
    
    def generate_optimized_report(self) -> str:
        """生成优化测试报告"""
        duration = datetime.now() - self.stats["start_time"]
        
        # 计算节省时间
        avg_test_time = 2.0  # 假设平均每个测试2秒
        time_saved = self.stats["skipped"] * avg_test_time
        
        report = f"""
📊 **智能优化测试报告** - {datetime.now().strftime('%H:%M:%S')}

| 指标 | 数值 |
|------|------|
| 运行时长 | {duration} |
| 测试轮次 | {self.stats['cycles']} |
| 总测试项 | {self.stats['total_tests']} |
| 通过 | {self.stats['passed']} ✅ |
| 失败 | {self.stats['failed']} ❌ |
| 跳过(缓存) | {self.stats['skipped']} ⏭ |
| 重试次数 | {self.stats['retried']} 🔄 |
| 节省时间 | ~{time_saved:.0f}秒 |

**优化效果:**
- 并行执行: {self.config['parallel_workers']} 线程同时运行
- 智能缓存: 跳过未变更的通过测试
- 失败重试: 最多 {self.config['max_retries']} 次自动重试
- 自适应间隔: 根据成功率动态调整 ({self._calculate_adaptive_interval()//60}分钟)

**当前状态:**
- 连续通过: {self.state.get('consecutive_passes', 0)} 轮
- 连续失败: {self.state.get('consecutive_failures', 0)} 轮
"""
        return report
    
    def run(self, max_cycles: int = None, duration_hours: float = None):
        """运行优化测试主循环"""
        print("\n" + "="*70)
        print(" 🎯 智掌柜 - 智能优化测试运行器")
        print("="*70)
        print(f"\n  ⚡ 优化特性:")
        print(f"     • 智能缓存 - 跳过上轮通过的测试")
        print(f"     • 失败重试 - 自动重试最多{self.config['max_retries']}次")
        print(f"     • 并行执行 - {self.config['parallel_workers']}线程并发")
        print(f"     • 自适应间隔 - 根据成功率动态调整")
        print(f"     • 增量测试 - 只测变更的模块")
        print(f"\n  🎯 测试目标: Flutter App + PC Web")
        print(f"  📊 汇报周期: 每30分钟")
        print("="*70 + "\n")
        
        end_time = None
        if duration_hours:
            end_time = datetime.now() + timedelta(hours=duration_hours)
        
        try:
            while True:
                # 检查终止条件
                if max_cycles and self.stats["cycles"] >= max_cycles:
                    self.log(f"已达到最大测试轮次: {max_cycles}", "INFO")
                    break
                
                if end_time and datetime.now() >= end_time:
                    self.log("已达到运行时长限制", "INFO")
                    break
                
                # 执行一轮测试
                self.run_single_cycle()
                
                # 计算下次运行间隔
                interval = self._calculate_adaptive_interval()
                next_run = datetime.now() + timedelta(seconds=interval)
                
                self.log(f"下次测试: {next_run.strftime('%H:%M:%S')} (间隔{interval//60}分钟)", "INFO")
                
                # 等待
                time.sleep(interval)
                
        except KeyboardInterrupt:
            self.log("测试被用户中断", "INFO")
        finally:
            # 生成最终报告
            print("\n" + self.generate_optimized_report())
            self._save_cache()
            self._save_state()


def main():
    import argparse
    parser = argparse.ArgumentParser(description='智能优化测试运行器')
    parser.add_argument('--single-cycle', action='store_true', help='只运行一轮测试')
    parser.add_argument('--max-cycles', type=int, default=None, help='最大运行轮次')
    parser.add_argument('--duration', type=float, default=None, help='运行时长(小时)')
    args = parser.parse_args()
    
    runner = OptimizedTestRunner()
    
    if args.single_cycle:
        runner.run_single_cycle()
        print(runner.generate_optimized_report())
    else:
        runner.run(max_cycles=args.max_cycles, duration_hours=args.duration)


if __name__ == "__main__":
    main()
