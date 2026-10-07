# gwf - sing-box 规则集和订阅管理工具

Clash 规则集转换为 sing-box 格式，支持自动更新和订阅管理。

## 📁 项目结构

```
gwf/
├── clash/
│   └── RuleSet/              # Clash 规则源文件（YAML）
├── singbox/
│   └── rule-set/             # sing-box 规则集
│       ├── *.json            # JSON 格式（35个）
│       └── *.srs             # SRS 二进制格式（35个）
├── scripts/                  # 脚本工具
│   ├── convert_rules.py      # Clash 规则转换工具
│   ├── subscription_converter.py  # 订阅转换工具
│   ├── config_manager.py     # 配置管理器
│   └── auto_update_subscription.sh  # 自动更新脚本
├── docs/                     # 文档
│   ├── SUBSCRIPTION.md       # 订阅转换文档
│   ├── CLASH_API.md          # Clash API 文档
│   └── CONFIG_SUBSCRIPTION.md  # 配置订阅文档
├── .github/
│   └── workflows/            # GitHub Actions
└── README.md                 # 本文档
```

## 🚀 快速开始

### 1. 转换 Clash 规则为 sing-box 格式

```bash
cd scripts
python3 convert_rules.py
```

### 2. 转换订阅

```bash
export CLASH_SUBSCRIPTION_URL='你的订阅地址'
cd scripts
python3 subscription_converter.py ../config_template.json output.json
```

### 3. 使用配置管理器

```bash
export CLASH_SUBSCRIPTION_URL='你的订阅地址'
cd scripts
python3 config_manager.py config_with_sub.json runtime.json once
```

## 📖 文档

- [订阅转换文档](docs/SUBSCRIPTION.md) - 订阅转换工具使用说明
- [Clash API 文档](docs/CLASH_API.md) - Clash API 使用指南
- [配置订阅文档](docs/CONFIG_SUBSCRIPTION.md) - 配置文件订阅管理

## 🔧 工具说明

### scripts/convert_rules.py

Clash 规则集转换为 sing-box 格式（JSON 和 SRS）。

```bash
python3 scripts/convert_rules.py
```

### scripts/subscription_converter.py

从 Clash 订阅 URL 获取节点并转换为 sing-box 配置。

```bash
export CLASH_SUBSCRIPTION_URL='订阅地址'
python3 scripts/subscription_converter.py template.json output.json
```

### scripts/config_manager.py

配置管理器，支持在配置文件中直接配置订阅 URL。

```bash
python3 scripts/config_manager.py config_with_sub.json runtime.json once
python3 scripts/config_manager.py config_with_sub.json runtime.json daemon
```

### scripts/auto_update_subscription.sh

自动更新脚本，定期更新订阅节点。

```bash
./scripts/auto_update_subscription.sh once   # 单次更新
./scripts/auto_update_subscription.sh daemon # 守护进程
```

## 🌐 规则集

### 远程规则集地址

- JSON: `https://raw.githubusercontent.com/iflyelf/gwf/main/singbox/rule-set/*.json`
- SRS: `https://raw.githubusercontent.com/iflyelf/gwf/main/singbox/rule-set/*.srs`

### 规则集列表

- **拦截规则**（6个）: XiaoNuoReject, BanAD, BanProgramAD 等
- **直连规则**（14个）: XiaoNuoDirect, ChinaIp, ChinaDomain 等
- **代理规则**（15个）: XiaoNuoProxy, ProxyGFWlist, Telegram 等

## 🔄 GitHub Actions

自动化工作流：
- 自动转换 Clash 规则为 JSON
- 自动编译为 SRS 二进制格式
- 自动提交并推送
- 自动清理旧运行记录

## 📦 相关项目

- [sing-box-docker](https://github.com/iflyelf/sing-box-docker) - sing-box Docker 配置

## 📄 许可证

MIT License
