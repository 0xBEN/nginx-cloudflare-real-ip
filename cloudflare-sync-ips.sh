#!/bin/bash

CLOUDFLARE_FILE_PATH=/etc/nginx/conf.d/cloudflare-real-ip.conf

function UpdateConfigFile {
    echo "# Configuration file to enable the logging of real client IP" > $CLOUDFLARE_FILE_PATH;
    echo "# Cloudflare proxies send a CF-Connecting-IP header that can be logged." >> $CLOUDFLARE_FILE_PATH;
    echo "# Cloudflare Official Proxy IP Addressses" >> $CLOUDFLARE_FILE_PATH;
    echo "" >> $CLOUDFLARE_FILE_PATH;

    echo "# - IPv4" >> $CLOUDFLARE_FILE_PATH;
    for i in `curl -s -L https://www.cloudflare.com/ips-v4`; do
        echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH;
    done

    echo "" >> $CLOUDFLARE_FILE_PATH;
    echo "# - IPv6" >> $CLOUDFLARE_FILE_PATH;
    for i in `curl -s -L https://www.cloudflare.com/ips-v6`; do
        echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH;
    done

    echo "" >> $CLOUDFLARE_FILE_PATH;
    echo "real_ip_header CF-Connecting-IP;" >> $CLOUDFLARE_FILE_PATH;
}

UpdateConfigFile

# Ensure the operation succeeded by checking for
    # IPv4 address definitions
    # IPv6 definitions
    # This will ensure set_real_ip directives for both address types
while ! grep -Pq '\d{1,3}\.' $CLOUDFLARE_FILE_PATH && grep -Pq '\w{1,4}\:' $CLOUDFLARE_FILE_PATH > /dev/null;
do
    sleep 3
    UpdateConfigFile
done

#test configuration and reload nginx
nginx -t && systemctl reload nginx
