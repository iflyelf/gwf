# IP库
mkdir -p ip
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://ispip.clang.cn/all_cn.txt' > ip/ChinaIpv4.txt
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://ispip.clang.cn/all_cn_ipv6.txt' > ip/ChinaIpv6.txt
cat ip/ChinaIpv4.txt > ip/ChinaIp.txt
cat ip/ChinaIpv6.txt >> ip/ChinaIp.txt

# clash 规则
mkdir -p clash
cat ip/ChinaIpv4.txt | perl -ne '/(.+\/\d+)/ && print "IP-CIDR,$1,no-resolve\n"' | sed "s/|/'/g" > clash/RuleSet/ChinaIpv4.list
cat ip/ChinaIpv6.txt | perl -ne '/(.+\/\d+)/ && print "IP-CIDR6,$1,no-resolve\n"' | sed "s/|/'/g" > clash/RuleSet/ChinaIpv6.list
cat clash/RuleSet/ChinaIpv4.list > clash/RuleSet/ChinaIp.list
cat clash/RuleSet/ChinaIpv6.list >> clash/RuleSet/ChinaIp.list

# cat ip/ChinaIpv4.txt | perl -ne '/(.+\/\d+)/ && print "  - IP-CIDR,$1,no-resolve\n"' | sed "s/|/'/g" > clash/RuleSet/ChinaIpv4.yaml
# cat ip/ChinaIpv6.txt | perl -ne '/(.+\/\d+)/ && print "  - IP-CIDR6,$1,no-resolve\n"' | sed "s/|/'/g" > clash/RuleSet/ChinaIpv6.yaml
cat ip/ChinaIpv4.txt | perl -ne '/(.+\/\d+)/ && print "  - $1\n"' | sed "s/|/'/g" > clash/RuleSet/ChinaIpv4.yaml
cat ip/ChinaIpv6.txt | perl -ne '/(.+\/\d+)/ && print "  - $1\n"' | sed "s/|/'/g" > clash/RuleSet/ChinaIpv6.yaml
cat clash/RuleSet/ChinaIpv4.yaml > clash/RuleSet/ChinaIp.yaml
cat clash/RuleSet/ChinaIpv6.yaml >> clash/RuleSet/ChinaIp.yaml
sed -i '1 i\payload:' clash/RuleSet/ChinaIp.yaml
sed -i '1 i\payload:' clash/RuleSet/ChinaIpv4.yaml
sed -i '1 i\payload:' clash/RuleSet/ChinaIpv6.yaml

# 直连域名
# direct
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/apple.china.conf' > apple.china.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/domain-list-custom/release/icloud.txt' > icloud.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt' > direct-list.tmp

cat icloud.tmp | grep -E "^(full|domain):" | awk -F ':' '{printf "%s\n", $2}' | sed "s/|/'/g" > direct.tmp
cat apple.china.tmp | perl -ne '/^server=\/([^\/]+)\// && print "$1\n"' | sed "s/|/'/g" >> direct.tmp
cat direct-list.tmp | grep -Ev "^(regexp|keyword|full):" | perl -ne '/^(domain:|full:)?([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$2\n"' | sed "s/|/'/g" >> direct.tmp
cat direct.tmp | xargs -n 1 | sort -u | uniq | sed "s/|/'/g" > direct.txt
sed -i '/cloudflare/d' direct.txt
sed -i '/cn$/d' direct.txt

# clash
mkdir -p clash/RuleSet
cat clash/RuleSet/XiaoNuoDirect.list.tmp > clash/RuleSet/XiaoNuoDirect.list
cat direct.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "DOMAIN-SUFFIX,$1\n"' | sed "s/|/'/g" >> clash/RuleSet/XiaoNuoDirect.list
cat clash/RuleSet/XiaoNuoDirect.yaml.tmp > clash/RuleSet/XiaoNuoDirect.yaml
cat direct.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "  - DOMAIN-SUFFIX,$1\n"' | sed "s/|/'/g" >> clash/RuleSet/XiaoNuoDirect.yaml
sed -i '/,cn$/d' clash/RuleSet/XiaoNuoDirect.list
sed -i '/,cn$/d' clash/RuleSet/XiaoNuoDirect.yaml

# smartdns
mkdir -p smartdns
cat direct.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "nameserver /.$1/xiaonuo\n"' | sed "s/|/'/g" > smartdns/smartdns_xiaonuo_domain.conf
cat direct.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$1\n"' | sed "s/|/'/g" > smartdns/smartdns_xiaonuo_domain_list.conf

# 代理域名
# proxy

curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/google.china.conf' > google.china.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt' > proxy-list.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt' > gwf.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/greatfire.txt' > greatfire.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/domain-list-custom/release/tld-!cn.txt' | perl -ne '/^domain:([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$1\n"' | sed "s/|/'/g" | xargs -n 1 | sort -u | uniq > tld-not-cn.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/danxiaonuo/gwf/refs/heads/main/smartdns/smartdns_gfw_tmp_domain.conf' > smartdns_gfw_tmp_domain.tmp

cat tld-not-cn.tmp > proxy.tmp
cat google.china.tmp | perl -ne '/^server=\/([^\/]+)\// && print "$1\n"' | sed "s/|/'/g" >> proxy.tmp
cat proxy-list.tmp | grep -Ev "^(regexp|keyword|full):" | perl -ne '/^(domain:|full:)?([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$2\n"' | sed "s/|/'/g" >> proxy.tmp
cat gwf.tmp | grep -Ev "^(regexp|keyword|full):" | perl -ne '/^(domain:|full:)?([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$2\n"' | sed "s/|/'/g" >> proxy.tmp
cat greatfire.tmp | grep -Ev "^(regexp|keyword|full):" | perl -ne '/^(domain:|full:)?([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$2\n"' | sed "s/|/'/g" >> proxy.tmp
cat smartdns_gfw_tmp_domain.tmp | sed "s/|/'/g" >> proxy.tmp
cat proxy.tmp | xargs -n 1 | sort -u | uniq | sed "s/|/'/g" > proxy.txt

# clash
mkdir -p clash/RuleSet
cat clash/RuleSet/XiaoNuoProxy.list.tmp> clash/RuleSet/XiaoNuoProxy.list
cat proxy.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "DOMAIN-SUFFIX,$1\n"' | sed "s/|/'/g" >> clash/RuleSet/XiaoNuoProxy.list
cat clash/RuleSet/XiaoNuoProxy.yaml.tmp > clash/RuleSet/XiaoNuoProxy.yaml
cat proxy.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "  - DOMAIN-SUFFIX,$1\n"' | sed "s/|/'/g" >> clash/RuleSet/XiaoNuoProxy.yaml

# 拒绝域名
# reject
mkdir -p clash/RuleSet
cat clash/RuleSet/XiaoNuoReject.list.tmp> clash/RuleSet/XiaoNuoReject.list
cat clash/RuleSet/XiaoNuoReject.yaml.tmp > clash/RuleSet/XiaoNuoReject.yaml

# smartdns
mkdir -p smartdns
cat proxy.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "nameserver /.$1/gwf\n"' | sed "s/|/'/g" > smartdns/smartdns_gfw_domain.conf
cat proxy.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$1\n"' | sed "s/|/'/g" > smartdns/smartdns_gfw_domain_list.conf

# MMDB库
curl -L -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb' -O country.mmdb
curl -L -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat' -O geoip.dat
curl -L -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat' -O geosite.dat
curl -L -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb' -O geoip.metadb

# ACL4SSR 规则集
# 说明：统一下载到项目内 clash/RuleSet 目录，与上方 gwf.sh 生成的
# XiaoNuo*/ChinaIp 规则共存，故此处不再清空目录、也不重复下载本仓库自有规则。
clash_ruleset="clash/RuleSet"
mkdir -p ${clash_ruleset}

acl4ssr="https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash"

# 通用下载函数：$1 为远程路径，$2 为本地文件名
acl_get() {
  curl -L -s -m 10 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url "${acl4ssr}/$1" -o "${clash_ruleset}/$2"
}

# Providers
acl_get "Providers/LocalAreaNetwork.yaml"          "LocalAreaNetwork.yaml"
acl_get "Providers/UnBan.yaml"                     "UnBan.yaml"
acl_get "Providers/BanAD.yaml"                     "BanAD.yaml"
acl_get "Providers/BanProgramAD.yaml"              "BanProgramAD.yaml"
acl_get "Providers/BanEasyList.yaml"               "BanEasyList.yaml"
acl_get "Providers/BanEasyListChina.yaml"          "BanEasyListChina.yaml"
acl_get "BanEasyPrivacy.list"                      "BanEasyPrivacy.yaml"
acl_get "Providers/Ruleset/GoogleFCM.yaml"         "GoogleFCM.yaml"
acl_get "Providers/Ruleset/GoogleCN.yaml"          "GoogleCN.yaml"
acl_get "Providers/Ruleset/OneDrive.yaml"          "OneDrive.yaml"
acl_get "Providers/Ruleset/Microsoft.yaml"         "Microsoft.yaml"
acl_get "Providers/Ruleset/Apple.yaml"             "Apple.yaml"
acl_get "Providers/Ruleset/Telegram.yaml"          "Telegram.yaml"
acl_get "Providers/Ruleset/AI.yaml"                "AI.yaml"
acl_get "Providers/Ruleset/OpenAi.yaml"            "OpenAi.yaml"
acl_get "Providers/Ruleset/NetEaseMusic.yaml"      "NetEaseMusic.yaml"
acl_get "Providers/Ruleset/Epic.yaml"              "Epic.yaml"
acl_get "Providers/Ruleset/Sony.yaml"              "Sony.yaml"
acl_get "Providers/Ruleset/Steam.yaml"             "Steam.yaml"
acl_get "Providers/Ruleset/YouTube.yaml"           "YouTube.yaml"
acl_get "Providers/Ruleset/Netflix.yaml"           "Netflix.yaml"
acl_get "Providers/Ruleset/Bahamut.yaml"           "Bahamut.yaml"
acl_get "Providers/Ruleset/Bilibili.yaml"          "Bilibili.yaml"
acl_get "ChinaMedia.list"                          "ChinaMedia.yaml"
acl_get "Providers/ProxyMedia.yaml"                "ProxyMedia.yaml"
acl_get "Providers/Ruleset/BilibiliHMT.yaml"       "BilibiliHMT.yaml"
acl_get "Ruleset/IqiyiHMT.list"                    "IqiyiHMT.yaml"
acl_get "Providers/ProxyGFWlist.yaml"              "ProxyGFWlist.yaml"
acl_get "Providers/ChinaIp.yaml"                   "ACL4SSR-ChinaIp.yaml"
acl_get "Providers/ChinaDomain.yaml"               "ChinaDomain.yaml"
acl_get "Providers/ChinaCompanyIp.yaml"            "ChinaCompanyIp.yaml"
acl_get "Download.list"                            "Download.yaml"

# 将 .list 格式转换为 clash provider 的 payload 格式
acl_to_payload() {
  local f="${clash_ruleset}/$1"
  [ -s "${f}" ] || return 0
  sed -i "1 i\payload:" "${f}"
  sed -i "s/DOMAIN/  - &/" "${f}"
  sed -i "s/IP-CIDR/  - &/" "${f}"
  sed -i "s/SRC-IP-CIDR/  - &/" "${f}"
  sed -i "s/GEOIP/  - &/" "${f}"
  sed -i "s/DST-PORT/  - &/" "${f}"
  sed -i "s/SRC-PORT/  - &/" "${f}"
  sed -i "s/PROCESS-NAME/  - &/" "${f}"
  sed -i "s/RULE-SET/  - &/" "${f}"
  sed -i "s/USER-AGENT/  # &/" "${f}"
  sed -i "s/URL-REGEX/  # &/" "${f}"
  sed -i "s/MATCH/  - &/" "${f}"
}

acl_to_payload "BanEasyPrivacy.yaml"
acl_to_payload "ChinaMedia.yaml"
acl_to_payload "IqiyiHMT.yaml"
acl_to_payload "Download.yaml"

# 规则微调
sed -i "/dl.google.com/d"   ${clash_ruleset}/UnBan.yaml
sed -i "/gstatic.com/d"     ${clash_ruleset}/UnBan.yaml
sed -i "/googleapis.com/d"  ${clash_ruleset}/UnBan.yaml
sed -i "/pki.goog/d"        ${clash_ruleset}/UnBan.yaml
sed -i "/,cn$/d"            ${clash_ruleset}/ChinaDomain.yaml
sed -i "/1101/d"            ${clash_ruleset}/ACL4SSR-ChinaIp.yaml
sed -i "/tiktokv/d"         ${clash_ruleset}/BanEasyPrivacy.yaml

rm -rf *.tmp
