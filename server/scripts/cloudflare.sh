#! /bin/bash 
# # CREATE ROOT CRON TO RUN SCRIPT, RELOAD NGINX HOUR LATER 
# 
CloudFlareConf="/home/naxchivan/nginx/inc/loudflare.conf" 
IPV4=$(curl -s "https://www.cloudflare.com/ips-v4") 
IPV6=$(curl -s "https://www.cloudflare.com/ips-v6") 
DATE="$(date)" 
echo "# Last updated ${DATE}" > ${CloudFlareConf} 
for IPV4ip in ${IPV4} 
do    
  echo "set_real_ip_from ${IPV4ip};" >> ${CloudFlareConf} 
done 
for IPV6ip in ${IPV6} 
do   
  echo "set_real_ip_from ${IPV6ip};" >> ${CloudFlareConf} 
done 
echo "real_ip_header CF-Connecting-IP;" >> ${CloudFlareConf} 
