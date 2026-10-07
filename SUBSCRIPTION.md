# 订阅转换使用说明

## 🔐 保密订阅地址

为了保护订阅地址隐私，使用环境变量存储。

## 🚀 使用方法

### 1. 设置订阅地址环境变量

```bash
export CLASH_SUBSCRIPTION_URL='你的订阅地址'
```

### 2. 运行转换脚本

```bash
cd /path/to/gwf
python3 subscription_converter.py \
  /path/to/config.json \
  output_config.json
```

参数说明：
- 第一个参数：模板配置文件（包含代理组和规则）
- 第二个参数：输出文件路径

### 3. 验证和启动

```bash
# 验证配置
sing-box check -c output_config.json

# 启动服务
sing-box run -c output_config.json
```

## 📋 完整示例

```bash
# 1. 设置订阅地址（每个终端会话只需设置一次）
export CLASH_SUBSCRIPTION_URL='https://your-subscription-url'

# 2. 转换订阅
cd gwf
python3 subscription_converter.py \
  ../sing-box-docker/conf/config.json \
  /tmp/my_config.json

# 3. 验证配置
sing-box check -c /tmp/my_config.json

# 4. 启动 sing-box
sing-box run -c /tmp/my_config.json
```

## 🔄 自动化脚本

可以创建一个便捷脚本：

```bash
#!/bin/bash
# update_singbox_subscription.sh

# 订阅地址（保密，不要提交到 Git）
export CLASH_SUBSCRIPTION_URL='你的订阅地址'

# 转换订阅
python3 subscription_converter.py \
  ../sing-box-docker/conf/config.json \
  ../sing-box-docker/conf/config_with_proxies.json

# 重启服务
if systemctl is-active --quiet singbox; then
  sudo systemctl restart singbox
  echo "✓ sing-box 服务已重启"
else
  echo "⚠️ sing-box 服务未运行"
fi
```

## 🔒 安全建议

1. **不要**将订阅地址硬编码在脚本中提交到 Git
2. **使用**环境变量或独立的配置文件（添加到 .gitignore）
3. **定期**更新订阅以获取最新节点
4. **备份**你的订阅地址到安全的地方

## 💡 提示

转换后的配置文件包含：
- 原有的所有代理组
- 原有的所有路由规则
- 从订阅获取的最新节点

节点会自动分配到相应的地区分组（根据节点名称）。
