#!/bin/bash
apt-get update;
apt-get install mysql-client openvpn unzip build-essential curl dos2unix -y;
openssl dhparam -out /etc/openvpn/dh2048.pem 2048;
iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o eth0 -j MASQUERADE;
iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o venet0 -j SNAT --to-source `curl ipecho.net/plain`;
echo 1 > /proc/sys/net/ipv4/ip_forward;
wget https://raw.githubusercontent.com/reyluar18/PandaVPN/master/premlite.zip -O prem.zip;
unzip prem.zip;
rm prem.zip*;
cp -r config/* /etc/openvpn;
cd /root;
chmod -R 755 /etc/openvpn;
systemctl start openvpn@server;
service openvpn start;
wget http://www.squid-cache.org/Versions/v3/3.1/squid-3.1.23.tar.gz;
tar zxvf squid-3.1.23.tar.gz;
cd squid-3.1.23;
./configure --prefix=/usr --exec-prefix=/usr --bindir=/usr/sbin --sbindir=/usr/sbin --sysconfdir=/etc/squid --datadir=/usr/share/squid --includedir=/usr/include --libdir=/usr/lib --libexecdir=/usr/lib/squid --localstatedir=/var --sharedstatedir=/usr/com --mandir=/usr/share/man --infodir=/usr/share/info --x-includes=/usr/include --x-libraries=/usr/lib --enable-shared=yes --enable-static=no --enable-carp --enable-storeio=aufs,ufs --enable-removal-policies=heap,lru --disable-icmp --disable-delay-pools --disable-esi --enable-icap-client --enable-useragent-log --enable-referer-log --disable-wccp --enable-wccpv2 --disable-kill-parent-hack --enable-snmp --enable-cachemgr-hostname=localhost --enable-arp-acl --disable-htcp --disable-forw-via-db --enable-follow-x-forwarded-for --enable-cache-digests --disable-poll --enable-epoll --enable-linux-netfilter --disable-ident-lookups --enable-default-hostsfile=/etc/hosts --with-default-user=squid --with-large-files --enable-mit=/usr --with-logdir=/var/log/squid --enable-zph-qos --enable-http-violations --with-filedescriptors=65536 --enable-gnuregex --enable-async-io=64 --with-aufs-threads=64 --with-pthreads --with-aio --enable-default-err-languages=English --enable-err-languages=English --disable-hostname-checks --enable-underscores;
make;
make install;
useradd squid;
cd /etc/squid/;
chown -Rf squid:squid /var/log/squid/;
cd /etc/squid/;
echo "
acl SSL_ports port 443
acl SSL_ports port 22
acl Safe_ports port 443
acl Safe_ports port 22
acl CONNECT method CONNECT
acl service dstdomain `curl ipecho.net/plain`
http_access deny !Safe_ports
http_access deny !service
http_access deny CONNECT !SSL_ports
http_access allow all
http_port 8080 transparent
http_port 3128 transparent
http_port 8888 transparent
http_port 8000 transparent
http_port 8089 transparent
http_port 2002 transparent
http_port 8989 transparent
http_port 143 transparent
visible_hostname SuperVpn
access_log none
cache_log /dev/null
logfile_rotate 0
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern . 0 20% 4320
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
" > squid.conf;
echo "squid -f /etc/squid/squid.conf -X" >> /etc/rc.local;
squid -f /etc/squid/squid.conf -X;
echo 'Done setup you can now close the terminal window and exit the app!';
rm prem.sh;
