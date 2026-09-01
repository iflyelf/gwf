# gwf

GFW / 国内直连 / 广告拒绝 规则库，自动更新，支持 Clash、SmartDNS 及 GeoIP 数据库。

## 域名 / IP 列表

- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/direct.txt
- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/proxy.txt
- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/ip/ChinaIp.txt
- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/ip/ChinaIpv4.txt
- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/ip/ChinaIpv6.txt

## SmartDNS

- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/smartdns/smartdns_gfw_domain.conf
- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/smartdns/smartdns_xiaonuo_domain.conf

## Clash RuleSet

- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/clash/RuleSet/XiaoNuoProxy.yaml
- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/clash/RuleSet/XiaoNuoDirect.yaml
- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/clash/RuleSet/XiaoNuoReject.yaml
- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/clash/RuleSet/ChinaIp.yaml

## GeoIP 数据库

- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/country.mmdb
- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/geoip.dat
- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/geoip.metadb
- https://cdn.jsdelivr.net/gh/danxiaonuo/gwf/geosite.dat

## 自动更新

通过 GitHub Actions 每 30 分钟自动执行 `default/gwf.sh` 更新规则库。
