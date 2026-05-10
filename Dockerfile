FROM teddysun/xray:latest

# تثبيت الأدوات المساعدة
RUN apk add --no-cache \
    curl \
    bash \
    jq \
    qrencode

# إنشاء المجلدات
RUN mkdir -p /etc/xray /config

# نسخ ملفات الإعداد
COPY config.json /etc/xray/config.json
COPY setup.sh /setup.sh
COPY start.sh /start.sh

RUN chmod +x /setup.sh /start.sh

# منافذ الخدمة
EXPOSE 8080 8443

CMD ["/start.sh"]
