#!/usr/bin/env python3
"""
智掌柜 - 测试进度汇报生成器
根据 JSON 报告生成格式化的测试进度汇报
"""

import json
import os
from datetime import datetime
from pathlib import Path

def generate_progress_report(json_path):
    """从 JSON 报告生成测试进度汇报"""
    
    # 读取 JSON 报告
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    report_time = datetime.fromisoformat(data['report_time']).strftime('%Y-%m-%d %H:%M:%S')
    summary = data['summary']
    results = data['results']
    
    # 生成报告
    report = f"""
═══════════════════════════════════════════════════════════════════════════
                    智掌柜 - 测试进度汇报
═══════════════════════════════════════════════════════════════════════════

📅 报告时间: {report_time}

───────────────────────────────────────────────────────────────────────────
                              📊 测试摘要
───────────────────────────────────────────────────────────────────────────

  测试统计:
    ┌─────────────────────────────────────┐
    │  总项目:      {summary['total']} 项                  │
    │  ✓ 通过:      {summary['pass']} 项                  │
    │  ✗ 失败:      {summary['fail']} 项                  │
    │  ⚠ 错误:      {summary['error']} 项                  │
    │  📈 通过率:   {summary['pass_rate']}                 │
    └─────────────────────────────────────┘

───────────────────────────────────────────────────────────────────────────
                            🔍 详细测试结果
───────────────────────────────────────────────────────────────────────────

"""
    
    # 详细结果
    test_names = {
        'flutter_analyze': 'Flutter 代码分析',
        'api_health': 'API 健康检查',
        'web_health': 'Web 健康检查',
        'source_files': '关键源文件检查'
    }
    
    for i, result in enumerate(results, 1):
        test_type = result['type']
        status = result['status']
        status_icon = '✓' if status == 'pass' else '✗'
        status_text = '通过' if status == 'pass' else '失败'
        
        report += f"  【{i}】{test_names.get(test_type, test_type)}\n"
        report += f"       状态: {status_icon} {status_text}\n"
        
        # 添加额外信息
        if test_type == 'api_health' and 'code' in result:
            report += f"       HTTP 状态码: {result['code']}\n"
            report += f"       响应时间: {result.get('response_time', 'N/A')}s\n"
        elif test_type == 'web_health' and 'code' in result:
            report += f"       HTTP 状态码: {result['code']}\n"
        elif test_type == 'source_files':
            report += f"       检查文件: {result.get('checked', 'N/A')} 个\n"
            report += f"       通过: {result.get('passed', 'N/A')} 个\n"
        
        report += "\n"
    
    report += """───────────────────────────────────────────────────────────────────────────
                            ⚠️ 问题分析
───────────────────────────────────────────────────────────────────────────

"""
    
    # 问题分析
    for result in results:
        test_type = result['type']
        status = result['status']
        
        if status != 'pass':
            if test_type == 'flutter_analyze':
                report += """  【Flutter 代码分析失败】
       可能原因:
         • 代码存在语法错误或警告
         • 依赖包未正确安装
         • analysis_options.yaml 配置问题
       建议操作:
         • 运行 `flutter analyze` 查看详细错误
         • 运行 `flutter pub get` 更新依赖

"""
            elif test_type == 'api_health':
                code = result.get('code', 'N/A')
                report += f"""  【API 健康检查失败】(HTTP {code})
       可能原因:
         • 服务器未启动或不可访问
         • 防火墙/安全组限制 (403 Forbidden)
         • API 端点配置错误
       建议操作:
         • 检查服务器状态: http://42.193.169.78:8090
         • 确认 Nginx/Apache 配置
         • 检查后端服务日志

"""
            elif test_type == 'web_health':
                code = result.get('code', 'N/A')
                report += f"""  【Web 健康检查失败】(HTTP {code})
       可能原因:
         • Web 服务器未启动
         • 静态资源未正确部署
         • 403 访问权限问题
       建议操作:
         • 检查 Web 服务状态
         • 确认文件权限配置

"""
            elif test_type == 'source_files':
                checked = result.get('checked', 'N/A')
                passed = result.get('passed', 'N/A')
                report += f"""  【关键源文件检查失败】
       统计: {passed}/{checked} 个文件检查通过
       可能原因:
         • 部分模块源文件缺失
         • 文件路径变更
         • 模块重构未完成
       建议操作:
         • 检查 lib/app/modules 目录结构
         • 确认各模块视图文件完整性

"""
    
    report += """───────────────────────────────────────────────────────────────────────────
                            💡 建议措施
───────────────────────────────────────────────────────────────────────────

  高优先级:
    1. 检查服务器运行状态，确保 API 和 Web 服务正常
    2. 解决 Flutter 代码分析问题，运行 `flutter analyze` 修复
    3. 检查并补全缺失的源文件

  中优先级:
    4. 配置自动化部署流程
    5. 设置服务健康监控告警

  长期规划:
    6. 完善集成测试用例
    7. 建立 CI/CD 自动化测试流程

───────────────────────────────────────────────────────────────────────────
                            📁 报告文件
───────────────────────────────────────────────────────────────────────────

  JSON 报告: """ + str(json_path) + """

═══════════════════════════════════════════════════════════════════════════
                        智掌柜测试团队
═══════════════════════════════════════════════════════════════════════════
"""
    
    return report

def main():
    """主函数"""
    # 查找最新的报告文件
    test_dir = Path('/workspace/zhiguanjia-app/test')
    
    # 获取最新的 report_*.json 文件
    json_files = sorted(test_dir.glob('report_*.json'), key=os.path.getmtime, reverse=True)
    
    if not json_files:
        print("❌ 未找到 JSON 报告文件")
        return
    
    latest_json = json_files[0]
    print(f"📄 使用报告: {latest_json.name}")
    
    # 生成进度汇报
    report = generate_progress_report(latest_json)
    
    # 保存报告
    report_filename = f"test_progress_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
    report_path = test_dir / report_filename
    
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write(report)
    
    # 输出到控制台
    print(report)
    print(f"\n📊 报告已保存: {report_path}")

if __name__ == "__main__":
    main()
