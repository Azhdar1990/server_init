#!/usr/bin/bash

USER="www-data"

cd ~

echo "####################################"
echo "SYNC TIME"
echo "####################################"
apt update && \
apt install -y systemd-timesyncd && \
timedatectl set-timezone Asia/Baku && \
timedatectl set-ntp true && \
timedatectl status && \

apt install -y ntpdate && \
ntpdate pool.ntp.org && \

echo "####################################"
echo "HOSTNAME"
echo "####################################"
HOSTNAME=`hostname`
USERHOST=""
read -p "Enter hostname (${HOSTNAME}): " USERHOST
if [ ! -z $USERHOST ]
then
  HOSTNAME=$USERHOST
  hostname $HOSTNAME
  echo $HOSTNAME > /etc/hostname
fi
export GRAYLOG_HOSTNAME=$HOSTNAME
echo $GRAYLOG_HOSTNAME

echo "####################################"
echo "ADD PUBKEY TO PROJECT-TEMPLATE REPO:"
echo "####################################"
ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N "" && \
cat /root/.ssh/id_rsa.pub
read -n 1 -p "press any key to continue..."

echo "####################################"
echo "INSTALL TOOLS"
echo "####################################"
apt install -y htop iftop nload iotop psmisc net-tools bind9-utils sendmail ncdu wget mc ipset unzip git pwgen supervisor && \

echo "####################################"
echo "FINE-TUNE SYSTEM & DISABLE IPv6"
echo "####################################"
echo never > /sys/kernel/mm/transparent_hugepage/enabled && \
echo 'vm.overcommit_memory=1' >> /etc/sysctl.conf && \
echo 'kernel.sched_rt_runtime_us = -1' >> /etc/sysctl.conf && \
# DISCOURAGE LINUX FROM SWAPPING IDLE SERVER PROCESSES TO DISK (DEFAULT = 60)
echo 'vm.swappiness = 1' >> /etc/sysctl.conf && \
# BE LESS AGGRESSIVE ABOUT RECLAIMING CACHED DIRECTORY AND INODE OBJECTS IN ORDER TO IMPROVE FILESYSTEM PERFORMANCE.
echo 'vm.vfs_cache_pressure = 50' >> /etc/sysctl.conf && \
# OPTIMIZE CONNECTION SETUP (some firewalls do not like TFO! (kernel > 3.7))
echo 'net.ipv4.tcp_fastopen = 3' >> /etc/sysctl.conf && \
# THE MAXIMUM NUMBER OF OPEN SOCKETS WAITING FOR A CONNECTION
echo 'net.core.somaxconn = 65535' >> /etc/sysctl.conf && \
# MAXIMUM NUMBER OF TCP SOCKETS ALLOWED IN THE SYSTEM THAT ARE NOT ASSOCIATED WITH ANY USER FILE ID
echo 'net.ipv4.tcp_max_orphans = 65535' >> /etc/sysctl.conf && \
# NUMBER OF UNSUCCESSFUL ATTEMPTS, AFTER WHICH THE TCP CONNECTION THAT WAS CLOSED FROM THE SERVER-SIDE AND IS DESTROYED
echo 'net.ipv4.tcp_orphan_retries = 0' >> /etc/sysctl.conf && \
# ACCORDING TO THE KERNEL DEVELOPERS’ RECOMMENDATIONS, THIS MODE IS BETTER TO DISABLE, SO WE PUT 0 HERE
echo 'net.ipv4.tcp_syncookies = 0' >> /etc/sysctl.conf && \
# HOW LONG SOCKETS ARE KEPT IN FIN-WAIT-2 STATE AFTER OUR (SERVER) SIDE HAS CLOSED IT
echo 'net.ipv4.tcp_fin_timeout = 10' >> /etc/sysctl.conf && \
# ENABLES TCP TIMESTAMPS (RFC 1323)
echo 'net.ipv4.tcp_timestamps = 1' >> /etc/sysctl.conf && \
# ALLOW TCP SELECTIVE ACKNOWLEDGMENTS. REQUIREMENT FOR THE EFFICIENT USAGE OF ALL THE AVAILABLE BANDWIDTH OF SOME NETWORKS
echo 'net.ipv4.tcp_sack = 1' >> /etc/sysctl.conf && \
# THE PROTOCOL USED TO MANAGE TRAFFIC ON TCP NETWORKS. DEFAULT bic AND cubic CONTAIN BUGS IN MOST VERSIONS
echo 'net.ipv4.tcp_congestion_control = htcp' >> /etc/sysctl.conf && \
# DO NOT STORE TCP CONNECTION MEASUREMENTS IN THE CACHE WHEN CLOSED
echo 'net.ipv4.tcp_no_metrics_save = 1' >> /etc/sysctl.conf && \
# HOW OFTEN TO CHECK IF THE CONNECTION IS NO USE FOR A LONG PERIOD
echo 'net.ipv4.tcp_keepalive_time = 1800' >> /etc/sysctl.conf && \
echo 'net.ipv4.tcp_keepalive_intvl = 15' >> /etc/sysctl.conf && \
echo 'net.ipv4.tcp_keepalive_probes = 5' >> /etc/sysctl.conf && \
# HANDLE SYN FLOODS AND LARGE NUMBERS OF VALID HTTPS CONNECTIONS
echo 'net.ipv4.tcp_max_syn_backlog = 4096' >> /etc/sysctl.conf && \
# ANTI IP SPOOFING
echo 'net.ipv4.conf.all.rp_filter = 1' >> /etc/sysctl.conf && \
echo 'net.ipv4.conf.lo.rp_filter = 1' >> /etc/sysctl.conf && \
echo 'net.ipv4.conf.default.rp_filter = 1' >> /etc/sysctl.conf && \
# ANTI SOURCE ROUTING
echo 'net.ipv4.conf.all.accept_source_route = 0' >> /etc/sysctl.conf && \
echo 'net.ipv4.conf.lo.accept_source_route = 0' >> /etc/sysctl.conf && \
echo 'net.ipv4.conf.default.accept_source_route = 0' >> /etc/sysctl.conf && \
# INCREASING THE RANGE OF LOCAL PORTS AVAILABLE FOR ESTABLISHING OUTGOING CONNECTIONS
echo 'net.ipv4.ip_local_port_range = 1024 65535' >> /etc/sysctl.conf && \
# MAXIMUM NUMBER OF PACKETS PUT IN THE QUEUE FOR PROCESSING IF THE NETWORK INTERFACE RECEIVES PACKETS FASTER THAN THE KERNEL CAN PROCESS THEM
echo 'net.core.netdev_max_backlog = 1000' >> /etc/sysctl.conf && \
# ALLOW REUSE OF TIME-WAIT SOCKETS IF THE PROTOCOL CONSIDERS IT AS SAFE
echo 'net.ipv4.tcp_tw_reuse = 1' >> /etc/sysctl.conf && \
# ALLOWING DYNAMIC RESIZING OF THE TCP STACK WINDOW
echo 'net.ipv4.tcp_window_scaling = 1' >> /etc/sysctl.conf && \
# ENABLING THE PROTECTION FROM TIME_WAIT ATTACKS (RFC 1337)
echo 'net.ipv4.tcp_rfc1337 = 1' >> /etc/sysctl.conf && \
# SAY TO NOT RESPOND TO ICMP ECHO REQUESTS, SENT WITH BROADCASTING PACKETS
echo 'net.ipv4.icmp_echo_ignore_broadcasts = 1' >> /etc/sysctl.conf && \
# DO NOT RESPOND TO BOGUS ERROR RESPONSES
echo 'net.ipv4.icmp_ignore_bogus_error_responses = 1' >> /etc/sysctl.conf && \
# DISABLE IPv6
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf && \
echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf && \
echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.conf && \
sysctl -p

echo "####################################"
echo "INSTALL DOCKER ENGINE"
echo "####################################"
apt install -y ca-certificates curl gnupg lsb-release && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update && \
apt install -y docker-ce docker-ce-cli containerd.io && \
systemctl enable docker --now

echo "####################################"
echo "INSTALL DOCKER-COMPOSE..."
echo "####################################"
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose && \
chmod +x /usr/bin/docker-compose

# echo "####################################"
# echo "CREATE LINKS..."
# echo "####################################"
# ln -s /home && \
# ln -s /var/log && \
# ln -s /var/spool/cron

echo "####################################"
echo "CLONE PROJECT TEMPLATE..."
echo "####################################"
# ssh-keyscan -p 54322 github.com >> ~/.ssh/known_hosts
ssh-keyscan github.com >> ~/.ssh/known_hosts
git config --global user.name "Azhdar Maniyev"
git config --global user.email "amaniyev@gmail.com"
git clone git@github.com:Azhdar1990/server_init.git && \
rm -rf server_init/init_project.sh && \
cp -rf server_init/* /home/ && \
rm -rf server_init

echo "####################################"
echo "ENABLE SUPERVISOR..."
echo "####################################"
test -d /etc/supervisor && mv /etc/supervisor /etc/supervisor.OLD && \
ln -s /home/server/supervisor /etc/supervisor && \
systemctl enable supervisor --now && \

echo "####################################"
echo "FOLDERS PERMISSIONS..."
echo "####################################"
chown -R $USER. /home/app

echo "####################################"
echo "DATABASE SPECIFIC..."
echo "####################################"
export RANDOM_DB_PASSWORD1=`pwgen -Bs1 16`
export RANDOM_DB_PASSWORD2=`pwgen -Bs1 16`
ln -s /etc/mysql/mariadb.cnf /home/server/mysql/my.cnf

# echo "####################################"
# echo "ELASTICSEARCH SPECIFIC..."
# echo "####################################"
# mkdir -p /home/server/elasticsearch/data && \
# chmod g+rwx /home/server/elasticsearch/data && \
# chown -R 1000:1000 /home/server/elasticsearch/data

# echo "####################################"
# echo "LOGIN TO DOCKER HUB..."
# echo "####################################"
# cd /home && \
# echo "4f73c02b-426e-4880-8592-6896272863f1" | docker login --username renatkalimulin --password-stdin

echo "####################################"
echo "INSTALL CSF..."
echo "####################################"
cd ~ && \
apt install -y libwww-perl liblwp-protocol-https-perl libgd-graph-perl && \
wget -q https://download.configserver.com/csf.tgz && \
tar -xzf csf.tgz && \
cd csf && \
sh ./install.sh && \
cd .. && \
cp -rf /home/server/csf/* /etc/csf/ && \
rm -rf ./csf ./csf.tgz /home/server/csf && \
ln -s /etc/csf && \
# csf -r && \ # WILL BE AUTO RESTARTED AFTER IP CRON
csf --lfd start && \

echo "####################################"
echo "RE-CREATE DOCKER RULES"
echo "####################################"
systemctl restart docker && \

mkdir /home/logs
chmod -R 777 /home/logs/

echo "####################################"
echo "CREATE CONTAINERS..."
echo "####################################"
cd /home && \
docker-compose up -d
docker-compose pull && \
docker-compose up -d --no-recreate && \
docker logout && \

# echo "####################################"
# echo "INSTALL IP CRON..."
# echo "####################################"
# apt -y install python2 && \
# ln -s /usr/bin/python2 /usr/bin/python && \
# curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && \
# python get-pip.py && \
# rm -rf get-pip.py && \
# pip2 install requests && \
# python /etc/csf/ip.py
# cat /etc/csf/cron > /var/spool/cron/crontabs/root

echo "####################################"
echo "ADDING SCRIPTS to CRONTAB..."
echo "####################################"
crontab -l > crontab_new
echo "* * * * * /usr/bin/python3 /home/server/scripts/ip.py" >> crontab_new
echo "@reboot sleep 2 && /usr/sbin/csf -r" >> crontab_new
echo "0 0 * * 6 /home/server/scripts/cloudflare.sh && sleep 2 && /bin/docker exec -t openresty /usr/sbin/nginx -s reload &" >> crontab_new
crontab crontab_new
rm crontab_new


echo "READY !"