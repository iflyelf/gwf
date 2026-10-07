# sing-box 订阅配置说明

## 📝 在配置文件中直接配置订阅 URL

与 Clash 的 `proxy-providers` 类似，你可以在配置文件中直接配置订阅地址。

## 配置格式

在配置文件顶部添加 `_subscription` 字段：

```json
{
  "_subscription": {
    "_comment": "订阅配置 - 类似 Clash 的 proxy-providers",
    "url": "env:CLASH_SUBSCRIPTION_URL",
    "update_interval": 3600,
    "auto_update": true,
    "user_agent": "clash"
  },
  "log": {
    ...
  },
  ...
}
```

### 配置选项

| 字段 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| `url` | string | 订阅地址，支持 `env:变量名` | 必填 |
| `update_interval` | int | 更新间隔（秒） | 3600 |
| `auto_update` | bool | 是否自动更新 | true |
| `user_agent` | string | 请求 User-Agent | clash |

### URL 配置方式

**方式 1：使用环境变量（推荐）**
```json
"url": "env:CLASH_SUBSCRIPTION_URL"
```

**方式 2：直接写入（不推荐）**
```json
"url": "https://your-subscription-url"
```

> 推荐使用环境变量，避免订阅地址泄露到 Git

## 使用方法

### 1. 准备配置文件

使用包含 `_subscription` 的配置模板：

```bash
# 示例配置
config_with_sub.json
```

### 2. 设置订阅地址

```bash
export CLASH_SUBSCRIPTION_URL='你的订阅地址'
```

### 3. 生成运行时配置

**单次更新：**

```bash
python3 config_manager.py config_with_sub.json runtime_config.json once
```

**守护进程模式（自动更新）：**

```bash
python3 config_manager.py config_with_sub.json runtime_config.json daemon
```

### 4. 启动 sing-box

```bash
sing-box run -c runtime_config.json
```

## 完整示例

### 步骤 1：创建配置文件

`my_config.json`:

```json
{
  "_subscription": {
    "url": "env:CLASH_SUBSCRIPTION_URL",
    "update_interval": 3600
  },
  "log": {
    "level": "info",
    "timestamp": true
  },
  "experimental": {
    "clash_api": {
      "external_controller": ":9090",
      "secret": "@admin123"
    }
  },
  ...
}
```

### 步骤 2：运行配置管理器

```bash
# 设置订阅地址
export CLASH_SUBSCRIPTION_URL='https://your-subscription-url'

# 单次更新
python3 config_manager.py my_config.json runtime.json once

# 验证配置
sing-box check -c runtime.json

# 启动服务
sing-box run -c runtime.json
```

### 步骤 3：自动更新（可选）

**使用守护进程：**

```bash
# 在后台运行配置管理器
nohup python3 config_manager.py my_config.json runtime.json daemon > update.log 2>&1 &

# sing-box 会定期重载配置（通过 Clash API）
```

**使用 crontab：**

```bash
crontab -e

# 添加：每小时更新一次
0 * * * * export CLASH_SUBSCRIPTION_URL='订阅地址' && cd /path/to/gwf && python3 config_manager.py config.json runtime.json once
```

## 与 Clash 对比

| 功能 | Clash | sing-box |
|------|-------|----------|
| 配置位置 | `proxy-providers` | `_subscription` |
| 自动更新 | 内置支持 | 配置管理器支持 |
| 更新间隔 | 配置文件 | 配置文件 |
| 环境变量 | 不支持 | 支持 `env:VAR` |
| 运行时配置 | 同一文件 | 分离（模板 → 运行时） |

## 工作原理

```
配置模板 (含订阅)          运行时配置 (无订阅)
    ↓                          ↓
my_config.json  →  [配置管理器]  →  runtime.json
    |                          |
    |-- _subscription          |-- inbounds
    |-- log                    |-- outbounds (含实际节点)
    |-- experimental           |-- route
    |-- inbounds               |-- experimental
    |-- outbounds (占位)       └-- ...
    └-- route
```

配置管理器会：
1. 读取模板配置
2. 从订阅 URL 获取节点
3. 转换节点格式
4. 更新 outbounds
5. 移除 `_subscription` 等元数据
6. 生成运行时配置

## 优势

✅ **订阅 URL 集中管理**：在配置文件中统一配置
✅ **环境变量支持**：保护敏感信息
✅ **自动更新**：守护进程或定时任务
✅ **类似 Clash**：配置方式更接近 Clash
✅ **运行时分离**：模板配置与运行时配置分离

## 配置管理器命令

```bash
# 查看帮助
python3 config_manager.py

# 单次更新
python3 config_manager.py <模板配置> <运行时配置> once

# 守护进程
python3 config_manager.py <模板配置> <运行时配置> daemon

# 停止守护进程
kill <进程ID>  # 或 Ctrl+C
```

## systemd 服务示例

创建 `/etc/systemd/system/singbox-updater.service`：

```ini
[Unit]
Description=sing-box Configuration Updater
After=network.target

[Service]
Type=simple
Environment="CLASH_SUBSCRIPTION_URL=你的订阅地址"
WorkingDirectory=/path/to/gwf
ExecStart=/usr/bin/python3 config_manager.py config.json runtime.json daemon
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启用服务：

```bash
sudo systemctl daemon-reload
sudo systemctl enable singbox-updater
sudo systemctl start singbox-updater
```

## 故障排查

### 订阅更新失败

1. 检查环境变量是否设置
2. 检查订阅 URL 是否可访问
3. 查看错误日志

### 配置验证失败

1. 确保使用 `runtime_config.json`（不是模板）
2. 检查节点格式是否正确
3. 运行 `sing-box check -c runtime_config.json`

### 节点没有更新

1. 检查配置管理器是否在运行
2. 查看更新日志
3. 手动运行一次更新测试

## 参考

- [subscription_converter.py](./subscription_converter.py) - 基础订阅转换工具
- [config_manager.py](./config_manager.py) - 配置管理器
- [auto_update_subscription.sh](./auto_update_subscription.sh) - Shell 更新脚本
- [CLASH_API.md](./CLASH_API.md) - Clash API 文档
