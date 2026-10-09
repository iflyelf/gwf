#!/usr/bin/env python3
"""
Clash 规则集转换为 sing-box 规则集
将 Clash YAML 格式规则转换为 sing-box JSON 格式
"""

import yaml
import json
import os
import sys
from pathlib import Path

def parse_clash_rule(rule_line):
    """解析 Clash 规则行"""
    parts = rule_line.strip().split(',')
    if len(parts) < 2:
        return None
    
    rule_type = parts[0].strip()
    rule_value = parts[1].strip()
    no_resolve = 'no-resolve' in rule_line
    
    return {
        'type': rule_type,
        'value': rule_value,
        'no_resolve': no_resolve
    }

def clash_to_singbox_rule(clash_rule):
    """将 Clash 规则转换为 sing-box 规则"""
    if not clash_rule:
        return None
    
    rule_type = clash_rule['type']
    value = clash_rule['value']
    
    singbox_rule = {}
    
    if rule_type == 'DOMAIN':
        singbox_rule['domain'] = [value]
    elif rule_type == 'DOMAIN-SUFFIX':
        singbox_rule['domain_suffix'] = [value]
    elif rule_type == 'DOMAIN-KEYWORD':
        singbox_rule['domain_keyword'] = [value]
    elif rule_type == 'IP-CIDR':
        singbox_rule['ip_cidr'] = [value]
    elif rule_type == 'IP-CIDR6':
        singbox_rule['ip_cidr'] = [value]
    elif rule_type == 'GEOIP':
        singbox_rule['geoip'] = [value]
    elif rule_type == 'GEOSITE':
        singbox_rule['geosite'] = [value]
    elif rule_type == 'SRC-IP-CIDR':
        singbox_rule['source_ip_cidr'] = [value]
    elif rule_type == 'SRC-PORT':
        singbox_rule['source_port'] = [int(value)]
    elif rule_type == 'DST-PORT':
        singbox_rule['port'] = [int(value)]
    elif rule_type == 'PROCESS-NAME':
        singbox_rule['process_name'] = [value]
    else:
        return None
    
    return singbox_rule

def merge_singbox_rules(rules):
    """合并多个 sing-box 规则为一个规则对象"""
    merged = {
        'version': 2,
        'rules': []
    }
    
    # 按类型分组
    grouped = {
        'domain': [],
        'domain_suffix': [],
        'domain_keyword': [],
        'ip_cidr': [],
        'geoip': [],
        'geosite': [],
        'source_ip_cidr': [],
        'source_port': [],
        'port': [],
        'process_name': []
    }
    
    for rule in rules:
        if not rule:
            continue
        for key, value in rule.items():
            if key in grouped and isinstance(value, list):
                grouped[key].extend(value)
    
    # 创建单个规则对象包含所有分类
    rule_obj = {}
    for key, values in grouped.items():
        if values:
            # 去重
            if key in ['source_port', 'port']:
                rule_obj[key] = sorted(list(set(values)))
            else:
                rule_obj[key] = sorted(list(set(values)))
    
    if rule_obj:
        merged['rules'].append(rule_obj)
    
    return merged

def convert_clash_to_singbox(clash_file, singbox_file):
    """转换 Clash 规则文件到 sing-box 格式"""
    try:
        with open(clash_file, 'r', encoding='utf-8') as f:
            clash_data = yaml.safe_load(f)
        
        if not clash_data or 'payload' not in clash_data:
            print(f"警告: {clash_file} 没有 payload 字段，跳过")
            return False
        
        payload = clash_data['payload']
        if not isinstance(payload, list):
            print(f"警告: {clash_file} 的 payload 不是列表，跳过")
            return False
        
        singbox_rules = []
        for rule_line in payload:
            if not rule_line or rule_line.strip().startswith('#'):
                continue
            
            clash_rule = parse_clash_rule(rule_line)
            singbox_rule = clash_to_singbox_rule(clash_rule)
            
            if singbox_rule:
                singbox_rules.append(singbox_rule)
        
        # 合并规则
        merged_rules = merge_singbox_rules(singbox_rules)
        
        # 写入 JSON 文件
        with open(singbox_file, 'w', encoding='utf-8') as f:
            json.dump(merged_rules, f, ensure_ascii=False, indent=2)
        
        print(f"✓ 已转换: {os.path.basename(clash_file)} -> {os.path.basename(singbox_file)}")
        return True
        
    except Exception as e:
        print(f"✗ 转换失败 {clash_file}: {e}")
        return False

def main():
    # 路径配置 - 使用相对路径
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    clash_dir = repo_root / 'clash' / 'RuleSet'
    singbox_dir = repo_root / 'singbox' / 'ruleset'
    
    # 确保输出目录存在
    singbox_dir.mkdir(parents=True, exist_ok=True)
    
    # 需要转换的规则文件列表
    rule_files = [
        'XiaoNuoReject.yaml',
        'BanAD.yaml',
        'BanProgramAD.yaml',
        'BanEasyList.yaml',
        'BanEasyListChina.yaml',
        'BanEasyPrivacy.yaml',
        'XiaoNuoDirect.yaml',
        'LocalAreaNetwork.yaml',
        'ChinaIp.yaml',
        'ChinaDomain.yaml',
        'ChinaCompanyIp.yaml',
        'Download.yaml',
        'UnBan.yaml',
        'ChinaMedia.yaml',
        'Bilibili.yaml',
        'OneDrive.yaml',
        'Microsoft.yaml',
        'Apple.yaml',
        'Epic.yaml',
        'Sony.yaml',
        'Steam.yaml',
        'NetEaseMusic.yaml',
        'dns.yaml',
        'Telegram.yaml',
        'AI.yaml',
        'OpenAi.yaml',
        'YouTube.yaml',
        'Netflix.yaml',
        'Bahamut.yaml',
        'ProxyMedia.yaml',
        'BilibiliHMT.yaml',
        'IqiyiHMT.yaml',
        'ProxyGFWlist.yaml',
        'XiaoNuoProxy.yaml',
    ]
    
    success_count = 0
    fail_count = 0
    
    print("开始转换 Clash 规则集到 sing-box 格式...\n")
    
    for rule_file in rule_files:
        clash_file = clash_dir / rule_file
        singbox_file = singbox_dir / rule_file.replace('.yaml', '.json')
        
        if not clash_file.exists():
            print(f"✗ 文件不存在: {rule_file}")
            fail_count += 1
            continue
        
        if convert_clash_to_singbox(clash_file, singbox_file):
            success_count += 1
        else:
            fail_count += 1
    
    print(f"\n转换完成!")
    print(f"成功: {success_count} 个")
    print(f"失败: {fail_count} 个")
    
    if success_count > 0:
        print(f"\n规则集已保存到: {singbox_dir}")
        print("\n注意: sing-box 使用二进制规则集(.srs)性能更好")
        print("请使用 sing-box 的 rule-set compile 命令编译 JSON 为 SRS 格式:")
        print(f"  cd {singbox_dir}")
        print("  for file in *.json; do")
        print("    sing-box rule-set compile $file -o $(basename $file .json).srs")
        print("  done")

if __name__ == '__main__':
    main()
