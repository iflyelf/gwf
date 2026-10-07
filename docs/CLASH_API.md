# sing-box Clash API 和订阅管理

## 🎯 功能对齐 Clash

sing-box 已配置 Clash API，功能与 Clash 保持一致：

- ✅ Clash API 接口（端口 9090）
- ✅ 远程订阅自动更新（类似 proxy-providers）
- ✅ 通过 API 管理节点
- ✅ 支持 Clash 面板

## 📡 Clash API 配置

```json
{
  "external_controller": ":9090",
  "external_ui": "ui",
  "secret": "@admin123",
  "default_mode": "rule"
}
```

### 访问信息

- **API 地址**: `http://127.0.0.1:9090`
- **Secret**: `@admin123`
- **面板地址**: `http://127.0.0.1:9090/ui`

### API 使用示例

```bash
# 获取配置信息
curl -H "Authorization: Bearer @admin123" http://127.0.0.1:9090/configs

# 获取代理信息
curl -H "Authorization: Bearer @admin123" http://127.0.0.1:9090/proxies

# 切换代理
curl -X PUT -H "Authorization: Bearer @admin123" \
  -H "Content-Type: application/json" \
  -d '{"name":"节点名称"}' \
  http://127.0.0.1:9090/proxies/🚀%20节点选择

# 测试延迟
curl -H "Authorization: Bearer @admin123" \
  http://127.0.0.1:9090/proxies/节点名称/delay?timeout=5000&url=https://www.gstatic.com/generate_204
```

## 🔄 自动更新订阅

### 方式一：使用自动更新脚本（推荐）

```bash
# 设置订阅地址
export CLASH_SUBSCRIPTION_URL='你的订阅地址'

# 单次更新
./auto_update_subscription.sh once

# 守护进程模式（每小时自动更新）
./auto_update_subscription.sh daemon
```

### 方式二：手动更新

```bash
# 设置订阅地址
export CLASH_SUBSCRIPTION_URL='你的订阅地址'

# 转换订阅
python3 subscription_converter.py \
  ../sing-box-docker/conf/config.json \
  /tmp/singbox_config.json

# 重启服务
sudo systemctl restart singbox
```

### 方式三：定时任务（crontab）

```bash
# 编辑 crontab
crontab -e

# 添加以下行（每小时更新一次）
0 * * * * export CLASH_SUBSCRIPTION_URL='你的订阅地址' && /path/to/gwf/auto_update_subscription.sh once >> /var/log/singbox-update.log 2>&1
```

## 🎨 Clash 面板

### 推荐面板

1. **Yacd** (Yet Another Clash Dashboard)
   ```bash
   git clone https://github.com/haishanh/yacd.git
   cd yacd
   # 构建或使用预构建版本
   ```

2. **Clash Dashboard**
   ```bash
   git clone https://github.com/Dreamacro/clash-dashboard.git
   ```

### 配置面板

将面板文件放到 `ui` 目录：

```bash
# 创建 ui 目录
mkdir -p ui

# 下载预构建的面板（以 yacd 为例）
wget https://github.com/haishanh/yacd/releases/download/v0.3.8/yacd.tar.xz
tar -xf yacd.tar.xz -C ui

# 或者克隆仓库
git clone --depth=1 https://github.com/MetaCubeX/Yacd-meta.git ui
```

访问面板：`http://127.0.0.1:9090/ui`

## 📊 与 Clash 的对比

| 功能 | Clash | sing-box | 状态 |
|------|-------|----------|------|
| API 端口 | 9090 | 9090 | ✅ 一致 |
| Secret | 支持 | 支持 | ✅ 一致 |
| 节点管理 | API | API | ✅ 一致 |
| 远程订阅 | proxy-providers | 转换脚本 | ✅ 实现 |
| 自动更新 | 内置 | 脚本支持 | ✅ 实现 |
| Web 面板 | 支持 | 支持 | ✅ 一致 |
| 切换代理 | API | API | ✅ 一致 |
| 延迟测试 | API | API | ✅ 一致 |

## 🔧 配置说明

### 自动更新脚本配置

编辑 `auto_update_subscription.sh`：

```bash
# 配置模板路径
CONFIG_TEMPLATE="${SCRIPT_DIR}/../sing-box-docker/conf/config.json"

# 输出配置路径
OUTPUT_CONFIG="/tmp/singbox_config.json"

# 是否使用 systemd
USE_SYSTEMD=true
SERVICE_NAME="singbox"

# 更新间隔（秒）
UPDATE_INTERVAL=3600  # 1小时
```

### systemd 服务配置

如果使用 systemd 管理 sing-box：

```bash
# 修改脚本
USE_SYSTEMD=true
SERVICE_NAME="singbox"

# 脚本会自动使用 systemctl restart 重启服务
```

## 📝 节点分组说明

订阅转换工具会自动根据节点名称分配到对应地区组：

| 地区组 | 匹配关键词 |
|--------|-----------|
| 🇹🇼 台湾 | 台, tw, taiwan, TW, Taiwan |
| 🇭🇰 香港 | 港, hk, hongkong, HK, HongKong |
| 🇯🇵 日本 | 日, jp, japan, JP, Japan |
| 🇸🇬 新加坡 | 新, sg, singapore, SG, Singapore |
| 🇰🇷 韩国 | 韩, 🇰🇷, KR, Korea |
| 🇷🇺 俄罗斯 | 🇷🇺, RU, 俄罗斯, Russia |
| 🇨🇦 加拿大 | 🇨🇦, CA, 加拿大, Canada |
| 🇺🇸 美国 | 美, us, unitedstates, US, USA |
| 🇬🇧 英国 | 🇬🇧, GB, 英国, UK, Britain |
| 🇫🇷 法国 | 🇫🇷, FR, 法国, France |
| 🇩🇪 德国 | 🇩🇪, DE, 德国, Germany |
| 🇧🇷 巴西 | 🇧🇷, BR, 巴西, Brazil |
| 🇳🇱 荷兰 | 🇳🇱, NL, 荷兰, Netherlands |

不匹配任何地区的节点会自动归入"🚞 其它地区"组。

## 🚀 快速开始

### 1. 首次配置

```bash
# 设置订阅地址
export CLASH_SUBSCRIPTION_URL='你的订阅地址'

# 转换订阅生成配置
cd gwf
python3 subscription_converter.py \
  ../sing-box-docker/conf/config.json \
  /tmp/singbox_config.json

# 验证配置
sing-box check -c /tmp/singbox_config.json
```

### 2. 启动服务

```bash
# 直接运行
sing-box run -c /tmp/singbox_config.json

# 或使用 Docker
docker run -d --name sing-box --network host \
  -v /tmp/singbox_config.json:/etc/sing-box/config.json:ro \
  swr.cn-east-3.myhuaweicloud.com/iflyelf/sing-box:latest \
  run -c /etc/sing-box/config.json
```

### 3. 访问面板

浏览器打开：`http://127.0.0.1:9090/ui`

- Host: `127.0.0.1`
- Port: `9090`
- Secret: `@admin123`

### 4. 设置自动更新

```bash
# 守护进程模式
export CLASH_SUBSCRIPTION_URL='你的订阅地址'
./auto_update_subscription.sh daemon

# 或添加到 crontab
crontab -e
# 添加: 0 * * * * export CLASH_SUBSCRIPTION_URL='你的订阅' && /path/to/auto_update_subscription.sh once
```

## 🐛 故障排查

### API 无法访问

1. 检查服务是否运行
2. 检查端口是否被占用：`netstat -tlnp | grep 9090`
3. 检查防火墙设置

### 订阅更新失败

1. 检查订阅地址是否正确
2. 检查网络连接
3. 查看日志输出

### 面板无法打开

1. 确认 `ui` 目录存在且包含面板文件
2. 检查 `external_ui` 配置路径
3. 确认 API 服务正常

## 📖 参考资料

- [sing-box Clash API 文档](https://sing-box.sagernet.org/configuration/experimental/clash-api/)
- [Clash API 文档](https://clash.gitbook.io/doc/restful-api)
- [Yacd 面板](https://github.com/haishanh/yacd)
- [Clash Dashboard](https://github.com/Dreamacro/clash-dashboard)
