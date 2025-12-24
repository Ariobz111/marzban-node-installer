#!/bin/bash

# رنگ‌ها برای خوانایی بهتر خروجی
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# تابع برای نمایش پیام‌های رنگی
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# بررسی دسترسی روت
if [ "$(id -u)" != "0" ]; then
   print_error "این اسکریپت باید با دسترسی روت اجرا شود"
   exit 1
fi

print_status "شروع راه‌اندازی سرور نود Marzban..."

# مرحله 1: به‌روزرسانی سیستم
print_status "به‌روزرسانی سیستم..."
apt update && apt full-upgrade -y
if [ $? -ne 0 ]; then
    print_error "خطا در به‌روزرسانی سیستم"
    exit 1
fi

# مرحله 2: نصب پکیج‌های مورد نیاز و Fail2Ban برای جلوگیری از Abuse
print_status "نصب پکیج‌های مورد نیاز و ابزارهای امنیتی..."
apt-get install curl socat git fail2ban -y
systemctl enable --now fail2ban
if [ $? -ne 0 ]; then
    print_error "خطا در نصب پکیج‌های مورد نیاز"
    exit 1
fi

# مرحله 3: نصب داکر
print_status "نصب داکر..."
curl -fsSL https://get.docker.com | sh
if [ $? -ne 0 ]; then
    print_error "خطا در نصب داکر"
    exit 1
fi

# مرحله 4: کلون کردن ریپازیتوری (با بررسی پوشه تکراری)
print_status "کلون کردن ریپازیتوری Marzban-node..."
if [ -d "Marzban-node" ]; then
    print_warning "پوشه Marzban-node قبلاً وجود دارد، در حال پاکسازی..."
    rm -rf Marzban-node
fi
git clone https://github.com/Gozargah/Marzban-node
if [ $? -ne 0 ]; then
    print_error "خطا در کلون کردن ریپازیتوری"
    exit 1
fi

# مرحله 5: ساخت دایرکتوری
print_status "ساخت دایرکتوری مورد نیاز..."
mkdir -p /var/lib/marzban-node
if [ $? -ne 0 ]; then
    print_error "خطا در ساخت دایرکتوری"
    exit 1
fi

# مرحله 6: ساخت فایل‌های گواهی
print_status "ساخت فایل گواهی نورنبرگ..."
cat > /var/lib/marzban-node/nuremberg.pem << 'EOF'
-----BEGIN CERTIFICATE-----
MIIEnDCCAoQCAQAwDQYJKoZIhvcNAQENBQAwEzERMA8GA1UEAwwIR296YXJnYWgw
IBcNMjUwMjEwMTkzNDU3WhgPMjEyNTAxMTcxOTM0NTdaMBMxETAPBgNVBAMMCEdv
emFyZ2FoMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAsp+mutCD2Qgm
VoEEX+xOusolJQl6h/s7Uh7IaBSy00WDqPTKQB1UeJyKTzAzqoqdV0oJ4jTEetMU
GvM6158npwIbgXoNOjkuUjNSUHm730/pnv2N7MZnZEonMlyykhtCfW0Zg+vVqFV8
Y3P4KwsFtbNq7eIi1wMaGTGVZH3ezOmjIuD2PeXEwfDGA2SW8iuMD3YHqfjQ3mar
SOtmlSoJ2dsgc/cZ/KttAV3dnUy/bpnTJRSwb96wW8Uspunk0bebTjXYMm9TjiAH
gsIClmKfLZ3ZMzeORRmRraTBkImd27HH+OHgZaxEdJjHMy2ZlGk3wx8ExriE042u
fnaKUISE6ULjnEEe1iBZJ2tIxVWC1W364AVQjlmCyFE58tY4JFrbYYxRjr+0k3H+
9LDWvb732bvcyBRGxwver8DDRQ3RmWzdUAqKpjhCXtc9Vq7pR2roks9lnvj4Pm2Y
wRaLd8+g0YAs8IJiEOfdhvU5kx8bSqEiD1TkBPauOCDwIWxQE3dnITLD3FuMavsZ
xq9ODOycqtkvsVF9tpHItBhIGmbwCGcB5OA/+Znj2RKkRrAaUqMnqc0A4N0kYbAD
LCWpKReT+MU2xSRP1C37Pqj9WrCrhrPpb8QZx3RaiOJPAofEO+oPWPqgu+kmCoYz
Iumv5pU7MdhTQfBjc/JHOMdlzuwDbVUCAwEAATANBgkqhkiG9w0BAQ0FAAOCAgEA
WhhhFi8EVtFjKb+KAuEFowW6nG1Nfrgd9s/DuURivmoL/jl209Omjj8Yw8GgfoXb
rIn2PEeBP84O+IFHGY3eyP9maeZCtfN3qsPyuzru4ipoiSsWMGeBT2z+IQr3trVD
USbGcs0Q1ISG90LZ9s+gIO1K6C5/q59VntRwExaXEx0IU1EL259dnrxlLpCQ9FL/
rqE7ElFiZQLjDhffT8yBBpcfk6cCjh4tQggX8gBf8vwGOdjq7a9ko4XiuryvQY15
Io9VrkNMP04+O0AtbItfVk5pQdHktkbmDjOOyJn01SMGGoFuqTYpvc1LJfmxa3Tk
Zw4sNkSlitlrtiimCvB4+84kgPP+XRK7kiNFNUMqr8alCpd6VcoJVZQVbOGkCHXp
vZUA4yzC0qalJJFemDSwZsiVe5mLjvjTtE3+rUVVndY7Qn/AXl8+UKMvv2Z+F/p2
HOF6Yzk4TPF+jht6IUx2mFrUZLNN8oZ/Akq5c/v+LbxGn4cdkZC8/LZHw7Kb7AuY
DzG/8soNWoVeNtA8UEsMektbgpv+tEClrW5rEYyAqjO9eXCSm8tkcGEJVwod+H7E
edejdv5ZoLlA1YpVzny+rigJvmKvQnsE6qbxIWF7Ta4XDgxq4EGCIJMyN+UtYmZn
IIi7zxzcyepazrh2PWYVXxYig0FJUrVrdBAH+95NDp8=
-----END CERTIFICATE-----
EOF

print_status "ساخت فایل گواهی آلمان..."
cat > /var/lib/marzban-node/germany.pem << 'EOF'
-----BEGIN CERTIFICATE-----
MIIEnDCCAoQCAQAwDQYJKoZIhvcNAQENBQAwEzERMA8GA1UEAwwIR296YXJnYWgw
IBcNMjUwNjMwMjAyNDE3WhgPMjEyNTA2MDYyMDI0MTdaMBMxETAPBgNVBAMMCEdv
emFyZ2FoMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAlFAgqr+F0Ywh
aPLpivPiWribQY25NtwuxLcfTEeVgNvjPeykkfYFZ9D/cPCZHxQu0cLdBzizPkid
xbWghYwbhffLRwu9t7oQrNuPyh1i2bGtb55/q3Q5VCd8fbqqTxR4WVOiO0iYZkJ2
rEPnPcinduYTXhPkAJ52EW7cv0SQSTuXHrsDqaBb0SeH2grYai1gR9rQsDt2OLUH
oZRweBGlDUA5Eg6fRWNS9X4WImSoEip4giC6BlPKraPrzs14RLZZtqpJ5BE/wBvF
S32LbK1KwxTBomZh4G97wikeLn0lU8DecIV17XZWVjU9vBEXBHt5XLkWfGJmM8bV
JeRQrzOzV85yT7FxLq97nXDdWLAIcelrE8n6Ah9Py99zsofBAfGh+RgDTTsP2+Rv
cUGR9+S3/5UUZlSDJsjrE1BuQvLex/suwrT8yUen0Fs64avGpoc0YIkDo6h05jIk
nqquBLk3oiUoBz2b7HmJMmIhOmBwQXstrQ64/6uM3G6bFdMUTjwA3ouTWzMQhyj7
6WlSsVEOrJEJeMzJCPqGiPkc8VzvUWfCRYd6NIdeeW19T4WbCBgBGdBaoYVvV8ao
Jh/8PqI3EMkCE6+nkYICYve2qPnzP9D8LB2NzUGeU8NyU/niMvdURP/Lgbbgc9z1
oC7FvRF5o15XBvUeNraqbxZh168pVYUCAwEAATANBgkqhkiG9w0BAQ0FAAOCAgEA
I48RqzKIOqvu04WIRSDaJSitG4KgOXQOBknTSNP4fOSsunYXeBdSzZ+pgztqOt1D
1N+0lMSY3im35wI90C5JbCa1/Ar6ghMHg4n/RjngjuyNTRIZw2VQSbWLWRXmHbvN
gpjuZqJGhGfFbGS13BKJEZGf7IsFcuB2t63+oI259rXDIGbTbjfENiooABGFSVBb
4AQnbb/I3cNCDCAAIhjZMnR0WRS3Go4OQ0Wdrf/AhgN3q5AQoShYCr/cjmkReWq5
hnvBNBOzUflu7uWC9uec69sxyCn2/KgY3vqVUhilZbRpXCrmAVGtUEWj/S+lEEAh
MiDIVnJ5LJ/Mbte9huY7GeX2tNxnfBZgpvQy88wdquQ6y1EuSU3i/0xoCcl1H826
CX6JOx+DqnJPisMSkrN3gYkCwmfBqwiO+p0j1rBUToi/YVG89RdNA7rvK6aKqFfI
P8zUZfZQM/fErolIqS7Vvb7tv6tndPgXx0XAIxDi3VvkH7CbuRXTJQrg+GMCX1Pm
yJRXBVzLKQfhqAzl48Ul00u0E3i80u70owcaXMEvEy1QNbu9GpuMlbKqXxlOca36
wYy3VB2iLqezsr5SXNT0EdPG4vCa6eN8ZNulcStKe8SEuJSOxLKcLVZmr+XWjDaA
ITMvTp10HSwp26DfAWCcLEAVSM9gjz/JXc9lWPubEuc=
-----END CERTIFICATE-----
EOF

# مرحله 7: ساخت فایل docker-compose.yml با پورت‌های جدید
print_status "ساخت فایل docker-compose.yml..."
cd ~/Marzban-node
> docker-compose.yml
cat > docker-compose.yml << 'EOF'
services:
  node-nuremberg:
    image: gozargah/marzban-node:latest
    restart: always
    ports:
      - 2100:2100
      - 2101:2101
      - 4655:4655
      - 4655:4655/udp
    environment:
      SSL_CLIENT_CERT_FILE: "/var/lib/marzban-node/nuremberg.pem"
      SERVICE_PROTOCOL: "rest"
      SERVICE_PORT: 2100
      XRAY_API_PORT: 2101
    volumes:
      - /var/lib/marzban-node:/var/lib/marzban-node
  node-germany:
    image: gozargah/marzban-node:latest
    restart: always
    ports:
      - 2200:2200
      - 2201:2201
      - 110:110
      - 110:110/udp
    environment:
      SSL_CLIENT_CERT_FILE: "/var/lib/marzban-node/germany.pem"
      SERVICE_PROTOCOL: "rest"
      SERVICE_PORT: 2200
      XRAY_API_PORT: 2201
    volumes:
      - /var/lib/marzban-node:/var/lib/marzban-node
EOF

# مرحله 8: اجرای داکر کامپوز
print_status "اجرای داکر کامپوز..."
docker compose up -d
if [ $? -ne 0 ]; then
    print_error "خطا در اجرای داکر کامپوز"
    exit 1
fi

print_status "متوقف کردن و حذف کانتینرهای بی‌ربط..."
docker compose down --remove-orphans

print_status "اجرای مجدد داکر کامپوز..."
docker compose up -d
if [ $? -ne 0 ]; then
    print_error "خطا در اجرای مجدد داکر کامپوز"
    exit 1
fi

# مرحله 9: اجرای اسکریپت بهینه‌سازی (نسخه اصلاح شده برای Jitter و Abuse)
print_status "اجرای اسکریپت بهینه‌سازی سرور..."
cat > /tmp/optimizer.sh << 'EOF'
#!/bin/bash
if [ "$(id -u)" != "0" ]; then
   echo "❌ این اسکریپت باید با دسترسی روت اجرا شود" 1>&2
   exit 1
fi
echo "🚀 شروع بهینه‌سازی پیشرفته و امنیت..."
if modprobe tcp_bbr 2>/dev/null; then
    CONGESTION_CONTROL="bbr"
    echo "tcp_bbr" >> /etc/modules-load.d/bbr.conf
elif modprobe tcp_cake 2>/dev/null; then
    CONGESTION_CONTROL="cake"
    echo "tcp_cake" >> /etc/modules-load.d/cake.conf
else
    CONGESTION_CONTROL="cubic"
fi

cat > /etc/sysctl.d/99-optimized.conf <<EOT
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = $CONGESTION_CONTROL
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.netfilter.nf_conntrack_max = 2000000
net.netfilter.nf_conntrack_tcp_timeout_established = 3600
EOT
sysctl -p /etc/sysctl.d/99-optimized.conf
sysctl --system

# تنظیم خودکار MTU برای کاهش جیتر در شبکه ایران
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
if [ -n "$INTERFACE" ]; then
    ip link set dev $INTERFACE mtu 1400
    echo "✅ MTU اینترفیس $INTERFACE روی 1400 تنظیم شد"
else
    echo "⚠️ نتوانستم اینترفیس پیش‌فرض را پیدا کنم"
fi

# تنظیم فایروال ضد ابیوز هترزن
apt install -y ufw
ufw reset
ufw default deny incoming
ufw default allow outgoing
# مسدود کردن خروجی SSH برای جلوگیری از Abuse
ufw reject out to any port 22 
# اجازه دادن به پورت‌های مورد نیاز
ufw allow 22/tcp
ufw allow 4655/tcp
ufw allow 4655/udp
ufw allow 110/tcp
ufw allow 110/udp
ufw --force enable

systemctl disable ondemand 2>/dev/null || true
systemctl stop ondemand 2>/dev/null || true
echo "✅ بهینه‌سازی و امنیت با موفقیت انجام شد"
EOF

chmod +x /tmp/optimizer.sh
/tmp/optimizer.sh
if [ $? -ne 0 ]; then
    print_error "خطا در اجرای اسکریپت بهینه‌سازی"
    exit 1
fi

# مرحله 10: بررسی نیاز به ریبوت
print_status "بررسی نیاز به ریبوت..."
if [ -f /var/run/reboot-required ]; then
    if [ -t 0 ]; then
        print_warning "سیستم نیاز به ریبوت دارد"
        read -p "آیا مایلید سیستم را ریبوت کنید؟ (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "ریبوت کردن سیستم..."
            reboot
        else
            print_status "لطفاً سیستم را در اسرع وقت ریبوت کنید"
        fi
    else
        print_warning "سیستم نیاز به ریبوت دارد. لطفاً به صورت دستی ریبوت کنید."
    fi
else
    print_status "سیستم به ریبوت نیاز ندارد"
fi

print_status "✅ راه‌اندازی سرور با موفقیت انجام شد!"
print_status "پورت‌های باز: 4655 (نورنبرگ), 110 (آلمان)"
print_status "MTU روی 1400 تنظیم شد."
