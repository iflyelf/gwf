#!/usr/bin/env python3
"""
Clash 订阅转换为 sing-box 配置
使用环境变量存储订阅地址以保护隐私
"""

import json
import yaml
import requests
import sys
import os
from pathlib import Path

def fetch_clash_subscription(url: str) -> dict:
    """从订阅 URL 获取 Clash 配置"""
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        clash_config = yaml.safe_load(response.text)
        return clash_config
    except Exception as e:
        print(f"错误: 无法获取订阅: {e}")
        return None

def convert_clash_proxy_to_singbox(clash_proxy: dict) -> dict:
    """将 Clash 代理节点转换为 sing-box 格式"""
    proxy_type = clash_proxy.get('type', '').lower()
    name = clash_proxy.get('name', 'Unknown')
    
    singbox_proxy = {'tag': name}
    
    if proxy_type in ['ss', 'shadowsocks']:
        singbox_proxy['type'] = 'shadowsocks'
        singbox_proxy['server'] = clash_proxy.get('server')
        singbox_proxy['server_port'] = clash_proxy.get('port')
        singbox_proxy['method'] = clash_proxy.get('cipher')
        singbox_proxy['password'] = clash_proxy.get('password')
        
        plugin = clash_proxy.get('plugin')
        if plugin:
            singbox_proxy['plugin'] = plugin
            singbox_proxy['plugin_opts'] = clash_proxy.get('plugin-opts', {})
    
    elif proxy_type == 'vmess':
        singbox_proxy['type'] = 'vmess'
        singbox_proxy['server'] = clash_proxy.get('server')
        singbox_proxy['server_port'] = clash_proxy.get('port')
        singbox_proxy['uuid'] = clash_proxy.get('uuid')
        singbox_proxy['security'] = clash_proxy.get('cipher', 'auto')
        singbox_proxy['alter_id'] = clash_proxy.get('alterId', 0)
        
        if clash_proxy.get('tls'):
            singbox_proxy['tls'] = {
                'enabled': True,
                'server_name': clash_proxy.get('servername', clash_proxy.get('sni', ''))
            }
            if clash_proxy.get('skip-cert-verify'):
                singbox_proxy['tls']['insecure'] = True
        
        if clash_proxy.get('network') == 'ws':
            singbox_proxy['transport'] = {
                'type': 'ws',
                'path': clash_proxy.get('ws-opts', {}).get('path', '/'),
                'headers': clash_proxy.get('ws-opts', {}).get('headers', {})
            }
    
    elif proxy_type == 'trojan':
        singbox_proxy['type'] = 'trojan'
        singbox_proxy['server'] = clash_proxy.get('server')
        singbox_proxy['server_port'] = clash_proxy.get('port')
        singbox_proxy['password'] = clash_proxy.get('password')
        
        singbox_proxy['tls'] = {
            'enabled': True,
            'server_name': clash_proxy.get('sni', clash_proxy.get('server'))
        }
        if clash_proxy.get('skip-cert-verify'):
            singbox_proxy['tls']['insecure'] = True
        
        if clash_proxy.get('network') == 'ws':
            singbox_proxy['transport'] = {
                'type': 'ws',
                'path': clash_proxy.get('ws-opts', {}).get('path', '/'),
                'headers': clash_proxy.get('ws-opts', {}).get('headers', {})
            }
    
    elif proxy_type in ['hysteria2', 'hy2']:
        singbox_proxy['type'] = 'hysteria2'
        singbox_proxy['server'] = clash_proxy.get('server')
        singbox_proxy['server_port'] = clash_proxy.get('port')
        singbox_proxy['password'] = clash_proxy.get('password')
        
        singbox_proxy['tls'] = {
            'enabled': True,
            'server_name': clash_proxy.get('sni', clash_proxy.get('server'))
        }
        if clash_proxy.get('skip-cert-verify'):
            singbox_proxy['tls']['insecure'] = True
    
    else:
        print(f"警告: 不支持的代理类型 '{proxy_type}' (节点: {name})")
        return None
    
    return singbox_proxy

def update_config_with_proxies(config_template: str, proxies: list, output_file: str):
    """更新配置文件添加代理节点"""
    try:
        with open(config_template, 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        # 获取代理节点的 tag 列表
        proxy_tags = [p['tag'] for p in proxies if p]
        
        # 移除旧的代理节点（保留选择器和特殊节点）
        new_outbounds = []
        for outbound in config['outbounds']:
            if outbound['type'] in ['selector', 'urltest', 'direct', 'block', 'dns']:
                new_outbounds.append(outbound)
        
        # 添加新的代理节点
        new_outbounds.extend([p for p in proxies if p])
        
        config['outbounds'] = new_outbounds
        
        # 更新代理组的 outbounds 引用
        for outbound in config['outbounds']:
            if outbound['type'] in ['selector', 'urltest']:
                if 'filter' in outbound:
                    # 地区筛选组，设置为所有节点
                    outbound['outbounds'] = proxy_tags
                elif outbound['tag'] in ['🌐 全部节点', '♻️ 自动选择', '🔯 故障转移', '🔮 负载均衡-轮询', '🔮 负载均衡-散列']:
                    outbound['outbounds'] = proxy_tags
                elif outbound['tag'].startswith('🎉 xiaonuo'):
                    outbound['outbounds'] = proxy_tags
        
        # 保存配置
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, ensure_ascii=False, indent=2)
        
        print(f"✓ 配置已更新: {output_file}")
        print(f"  添加了 {len(proxy_tags)} 个节点")
        return True
        
    except Exception as e:
        print(f"错误: 更新配置失败: {e}")
        return False

def main():
    # 从环境变量获取订阅地址（保护隐私）
    subscription_url = os.environ.get('CLASH_SUBSCRIPTION_URL')
    
    if not subscription_url:
        print("错误: 未设置订阅地址")
        print("")
        print("使用方法:")
        print("  export CLASH_SUBSCRIPTION_URL='你的订阅地址'")
        print("  python3 subscription_converter.py [配置模板] [输出文件]")
        print("")
        print("示例:")
        print("  export CLASH_SUBSCRIPTION_URL='https://example.com/subscription'")
        print("  python3 subscription_converter.py ../sing-box-docker/conf/config.json output.json")
        sys.exit(1)
    
    config_template = sys.argv[1] if len(sys.argv) > 1 else '../sing-box-docker/conf/config.json'
    output_file = sys.argv[2] if len(sys.argv) > 2 else 'config_with_proxies.json'
    
    print(f"正在获取订阅...")
    clash_config = fetch_clash_subscription(subscription_url)
    
    if not clash_config:
        print("错误: 无法获取订阅内容")
        sys.exit(1)
    
    if 'proxies' not in clash_config:
        print("错误: 订阅内容中没有找到代理节点")
        sys.exit(1)
    
    print(f"找到 {len(clash_config['proxies'])} 个节点，开始转换...")
    
    singbox_proxies = []
    for clash_proxy in clash_config['proxies']:
        singbox_proxy = convert_clash_proxy_to_singbox(clash_proxy)
        if singbox_proxy:
            singbox_proxies.append(singbox_proxy)
    
    print(f"成功转换 {len(singbox_proxies)} 个节点")
    
    if not singbox_proxies:
        print("错误: 没有可用的节点")
        sys.exit(1)
    
    print(f"正在更新配置文件...")
    if update_config_with_proxies(config_template, singbox_proxies, output_file):
        print("")
        print("✓ 订阅转换完成!")
        print("")
        print("下一步:")
        print(f"  1. 检查配置: sing-box check -c {output_file}")
        print(f"  2. 启动服务: sing-box run -c {output_file}")
    else:
        print("")
        print("✗ 订阅转换失败")
        sys.exit(1)

if __name__ == '__main__':
    main()
