# gwf - Clash 规则集转换为 sing-box 格式

将 Clash 规则集转换为 sing-box 的 JSON 和 SRS 二进制格式。

## 📁 项目结构

```
gwf/
├── clash/
│   └── RuleSet/              # Clash 规则源文件（YAML）
├── singbox/
│   └── rule-set/             # sing-box 规则集
│       ├── *.json            # JSON 格式（34个）
│       └── *.srs             # SRS 二进制格式（34个）
├── scripts/
│   └── convert_rules.py      # 规则转换工具
├── .github/
│   └── workflows/            # GitHub Actions 自动转换
└── README.md                 # 本文档
```

## 🚀 使用方法

### 转换规则集

```bash
cd scripts
python3 convert_rules.py
```

脚本会自动：
1. 读取 `clash/RuleSet/*.yaml` 文件
2. 转换为 sing-box JSON 格式
3. 保存到 `singbox/rule-set/*.json`

### GitHub Actions 自动转换

当推送 Clash 规则文件到仓库时，GitHub Actions 会自动：
1. 转换为 JSON 格式
2. 编译为 SRS 二进制格式
3. 提交并推送到仓库

## 🌐 远程规则集地址

### JSON 格式
```
https://raw.githubusercontent.com/iflyelf/gwf/main/singbox/rule-set/*.json
```

### SRS 二进制格式（推荐）
```
https://raw.githubusercontent.com/iflyelf/gwf/main/singbox/rule-set/*.srs
```

## 📋 规则集列表（34个）

### 拦截规则（6个）
- XiaoNuoReject
- BanAD
- BanProgramAD
- BanEasyList
- BanEasyListChina
- BanEasyPrivacy

### 直连规则（14个）
- XiaoNuoDirect
- LocalAreaNetwork
- ChinaIp
- ChinaDomain
- ChinaCompanyIp
- Download
- UnBan
- ChinaMedia
- Bilibili
- OneDrive
- Microsoft
- Apple
- Epic
- Sony

### 代理规则（14个）
- Steam
- NetEaseMusic
- Dns
- Telegram
- AI
- OpenAi
- YouTube
- Netflix
- Bahamut
- ProxyMedia
- BilibiliHMT
- IqiyiHMT
- ProxyGFWlist
- XiaoNuoProxy

## 🔧 在 sing-box 中使用

在 sing-box 配置文件的 `route.rule_set` 中添加：

```json
{
  "route": {
    "rule_set": [
      {
        "tag": "Telegram",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/iflyelf/gwf/main/singbox/rule-set/Telegram.srs"
      }
    ]
  }
}
```

## 📦 相关项目

- [sing-box-docker](https://github.com/iflyelf/sing-box-docker) - sing-box 配置和订阅管理

## 📄 许可证

MIT License
