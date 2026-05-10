#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}=== إعداد V2Ray/Xray VPN ===${NC}"

# التحقق من UUID
if [ ! -f /config/uuid.txt ]; then
    echo -e "${YELLOW}إنشاء UUID جديد...${NC}"
    UUID=$(cat /proc/sys/kernel/random/uuid)
    echo "$UUID" > /config/uuid.txt
    echo -e "${GREEN}UUID: $UUID${NC}"
else
    UUID=$(cat /config/uuid.txt)
    echo -e "${YELLOW}UUID موجود مسبقاً: $UUID${NC}"
fi

# استبدال UUID في الإعدادات
sed -i "s/UUID_PLACEHOLDER/$UUID/g" /etc/xray/config.json

# الحصول على IP العام
SERVER_IP=$(curl -s ifconfig.me || echo "YOUR_SERVER_IP")
echo -e "${GREEN}IP السيرفر: $SERVER_IP${NC}"

# حفظ معلومات الاتصال
cat > /config/connection_info.txt <<EOF
==========================================
   معلومات الاتصال بـ V2Ray VPN
==========================================

UUID: $UUID
Server IP: $SERVER_IP

==========================================
   VMess (Port 8080)
==========================================
Protocol: vmess
Address: $SERVER_IP
Port: 8080
UUID: $UUID
AlterID: 0
Network: ws
Path: /vpn
TLS: none

==========================================
   VLESS (Port 8443)
==========================================
Protocol: vless
Address: $SERVER_IP
Port: 8443
UUID: $UUID
Encryption: none
Network: ws
Path: /vless
TLS: none

==========================================
EOF

cat /config/connection_info.txt

# إنشاء رابط VMess
VMESS_CONFIG=$(cat <<EOF
{
  "v": "2",
  "ps": "Fly.io-VMess",
  "add": "$SERVER_IP",
  "port": "8080",
  "id": "$UUID",
  "aid": "0",
  "net": "ws",
  "type": "none",
  "host": "",
  "path": "/vpn",
  "tls": ""
}
EOF
)

VMESS_LINK="vmess://$(echo -n "$VMESS_CONFIG" | base64 -w 0)"
echo "$VMESS_LINK" > /config/vmess_link.txt

echo -e "\n${BLUE}=== رابط VMess ===${NC}"
echo "$VMESS_LINK"

# إنشاء رابط VLESS
VLESS_LINK="vless://${UUID}@${SERVER_IP}:8443?encryption=none&security=none&type=ws&path=/vless#Fly.io-VLESS"
echo "$VLESS_LINK" > /config/vless_link.txt

echo -e "\n${BLUE}=== رابط VLESS ===${NC}"
echo "$VLESS_LINK"

# QR Codes
echo -e "\n${GREEN}=== QR Code لـ VMess ===${NC}"
qrencode -t ansiutf8 "$VMESS_LINK"

echo -e "\n${GREEN}=== QR Code لـ VLESS ===${NC}"
qrencode -t ansiutf8 "$VLESS_LINK"

echo -e "\n${GREEN}تم حفظ جميع المعلومات في /config/${NC}"
