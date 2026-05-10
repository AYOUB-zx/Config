#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== تشغيل V2Ray/Xray VPN ===${NC}"

# تشغيل الإعداد
/setup.sh

# تشغيل Xray
echo -e "\n${GREEN}بدء Xray...${NC}"
/usr/bin/xray -config /etc/xray/config.json &

XRAY_PID=$!

# التحقق من التشغيل
sleep 3

if ps -p $XRAY_PID > /dev/null; then
    echo -e "${GREEN}✓ Xray يعمل بنجاح! (PID: $XRAY_PID)${NC}"
    echo -e "${YELLOW}المنافذ:${NC}"
    echo -e "  - VMess: 8080 (WebSocket /vpn)"
    echo -e "  - VLESS: 8443 (WebSocket /vless)"
else
    echo -e "${RED}✗ فشل تشغيل Xray${NC}"
    exit 1
fi

# طباعة معلومات الاتصال
echo -e "\n${GREEN}==================================================${NC}"
echo -e "${YELLOW}للحصول على معلومات الاتصال:${NC}"
echo -e "${GREEN}  fly ssh console${NC}"
echo -e "${GREEN}  cat /config/connection_info.txt${NC}"
echo -e "${GREEN}==================================================${NC}\n"

# إبقاء الحاوية تعمل
wait $XRAY_PID
