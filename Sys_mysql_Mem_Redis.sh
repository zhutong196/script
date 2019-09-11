#!/bin/bash
# auther: zxj
# time:2019-05-08
# system: centos
# 系统基础服务脚本
######################

system_init(){
# 配置yum源
mkdir /etc/yum.repos.d/bak
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak

curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum -y install wget     ##centos 7
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

# 更新补丁
yum -y clean all
yum -y update glibc\*
yum -y update yum\* rpm\* python\*
yum clean all

# 更改Linux系统时区
#rm -rf /etc/localtime
#ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#timedatectl set-timezone 'Asia/Shanghai'
# 设置ntp
yum -y install ntp
ntpdate -u cn.pool.ntp.org
echo 'ntpdate -u cn.pool.ntp.org' >> /etc/rc.d/rc.local
hwclock --systohc
timedatectl set-timezone Asia/Shanghai


# 系统最小化安装，安装所需要的软件
yum -y install vim  wget lrzsz  bash-completion net-tools  lsof  psmisc  tree unzip rsync #zabbix-agent
echo "set ts=4" >> /etc/vimrc  ##设置vim的tab键为4个空格

#设置主机名
hostnamectl set-hostname centos

# 关闭selinux 和 firewalld
echo "=========close selinux==========="
setenforce 0
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
echo "selinux is disabled"

systemctl disable firewalld
systemctl stop firewalld
echo "firewalld is disabled"


# 调整文件描述符数量
cp /etc/security/limits.conf /etc/security/limits.conf.bak
cat >> /etc/security/limits.conf << EOF
*           soft   nofile       102400
*           hard   nofile       102400
*           soft   nproc        102400
*           hard   nproc        102400
EOF


# 更改字符集
cp /etc/sysconfig/i18n /etc/sysconfig/i18n.bak
echo 'LANG="en_US.UTF-8"' >/etc/sysconfig/i18n

# 精简开机自启动服务（只启动crond,sshd,network,syslog）  ###########设置所有运行
echo '级别3自启动服务关闭############'
for i in `chkconfig --list |grep 3:on |awk '{print $1}'`
do
        chkconfig --level 3 $i off
done
##########仅设置crond,sshd,network,syslog自启动#########
for i in {crond,sshd,network,rsyslog}
do
        chkconfig --level 3 $i on
done

# 内核参数优化
true > /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 65535
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 1024 65535
EOF
/sbin/sysctl -p
echo "sysctl set OK!"

# 更改默认的ssh服务端口，禁止root用户远程连接，禁止空密码连接，设置5分钟自动下线
/bin/cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
#sed -i 's/\#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/\#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
systemctl restart sshd

# 锁定关键系统文件
#chmod 600 /etc/passwd
#chmod 600 /etc/shadow
#chmod 600 /etc/group
#chmod 600 /etc/gshadow

# 安装zabbix-agent  centos7
#wget https://mirrors.aliyun.com/zabbix/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
#yum -y install zabbix_agent
#service zabbix_agentd start
#chkconfig zabbix_agentd on

# 安装zabbix-agent   centos6
# rpm -ihv http://mirrors.aliyun.com/zabbix/zabbix/3.0/rhel/6/x86_64/zabbix-release-3.0-1.el6.noarch.rpm
# yum install zabbix-agent -yes/PermitRootLogin
# service zabbix-agent restart
# chkconfig zabbix-agent on


reboot
# 清空/etc/issue, 去除系统及内核版本登录前的屏幕显示
}



mysql_install(){

id=`id -u`
if [ $id == '0' ];then
    echo "Current user is ROOT,this script will be running"
    else
        echo 'ERROR: To running this script,you must be sudo ROOT'
        exit 1
fi
yum install -y wget  ncurses-devel libaio-devel 
cd /usr/local/
if [  -d mysql ];then
   	mv mysql mysql_`date +%Y-%m-%d`.bak
fi
if [ ! -f mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz ];then
	wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz
else
	tar xvf mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz -C /usr/local
fi
sleep 3
mv /usr/local/mysql-5.7.17-linux-glibc2.5-x86_64 /usr/local/mysql
mv  mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz   /tmp/
cd /usr/local/mysql
userdel -r -f mysql
groupadd mysql
useradd -r -s /sbin/nologin -g mysql mysql
chown -R mysql.mysql ./
chown -R mysql /var/run/mysqld
chgrp -R mysql /var/run/mysqld
./bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
/bin/cp -f support-files/mysql.server /etc/init.d/mysqld
/bin/cp -f support-files/my-default.cnf /etc/my.cnf

cat << EOF > /etc/my.cnf  
# For advice on how to change settings please see;
# The mysql is be install by jiangnan's script and this config-file must be adjust according to your linux-server config
# If you doesn't config master-slave of mysql,you have to comment out MTS setting
# https://raw.githubusercontent.com/zhutongcloud

[mysqld]
log_bin
server-id=1
#gtid_mode=ON
#enforce_gtid_consistency=1
#auto_increment_offset = 1 
#auto_increment_increment = 2 
#skip-grant-tables

slow_query_log=ON
slow_query_log_file=/usr/local/mysql/data/slow.log
long_query_time=2

basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
socket=/tmp/mysql.sock
#log-error = /var/log/mysql/error.log

innodb_buffer_pool_size = 1G
innodb_buffer_pool_dump_pct = 40
innodb_page_cleaners = 4
innodb_undo_log_truncate = 1
innodb_purge_rseg_truncate_frequency = 128
log_timestamps=system
show_compatibility_56=on

symbolic-links=0
character_set_server=utf8
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES  ## 第一个参数 指定引擎操作SQL语句，若该MySQL不支持此引擎则直接报错，不会替换成默认引擎执行；第二个严格检查SQL的正确性，若规定四个字符长度，插入6个会报错，不会自动截断。
max_connections=1000
tmp_table_size=200M
query_cache_size=64M
query_cache_type=1
max_error_count=1000

# slave 并行复制（mysql>5.7）
#slave-parallel-type=LOGICAL_CLOCK  #基于组提交的并行复制方式
#slave-parallel-workers=16
#master_info_repository=TABLE 
#relay_log_info_repository=TABLE
#relay_log_recovery=ON

[client]
socket=/tmp/mysql.sock
EOF
sleep 3
systemctl daemon-reload
systemctl restart mysqld
sleep 2
if [ $? -eq 0 ];then
    echo "启动成功"
fi

echo 'export PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile
source /etc/profile

mysql  -e "update mysql.user set authentication_string=password('quizii2016') where user='root'"
mysql  -e "flush privileges"
mysql -uroot -pquizii2016 -e "show databases"

if [ $? -eq 0 ];then
echo "
+-------------------------------+
|     mysql 5.7.17 安装成功      |
+-------------------------------+
| basedir=/usr/local/mysql      | 
| datadir=/usr/local/mysql/data |
| user:root                     | 
| passsword: quizii2016         |         
+-------------------------------+
"
else
echo "
+-------------------------------+
|     mysql 5.7.17 安装失败      |
+-------------------------------+
" 
fi
}

memcached_install(){
yum install -y wget   gcc-c++ gcc make cmake autoconf libtool losf 

cd /usr/local/src
wget https://github.com/libevent/libevent/releases/download/release-2.1.11-stable/libevent-2.1.11-stable.tar.gz

wget http://memcached.org/files/memcached-1.5.17.tar.gz

tar xzvf  libevent-2.1.11-stable.tar.gz
cd libevent-2.1.11-stable
./configure --prefix=/usr/local/libevent
make && make install
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo $?
sleep 2

cd ..
tar xzvf memcached-1.5.17.tar.gz
cd memcached-1.5.17

./configure --prefix=/usr/local/memcached --with-libevent=/usr/local/libevent
make && make install
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo $?
sleep 2

ln -s /usr/local/memcached/bin/memcached /usr/sbin/memcached
memcached -d -m 1024 -u root -U 0 -l 127.0.0.1 -p 11211 -c 1000 -P /tmp/memcached.pid
#          后台 内存    用户   udp关闭 指定访问ip  监听tcp端口 最大连接数  写入file 使得后边进行快速进程终止 kill -9 `cat /tmp/memcached.pid`
ps -ef|grep memcached
lsof -i:11211
}



redis_install(){

yum -y install gcc-c++ wget  gcc make cmake lsof 
cd /usr/local/
wget http://download.redis.io/releases/redis-4.0.11.tar.gz
tar xzvf redis-4.0.11.tar.gz

mv redis-4.0.11.tar.gz  ./src/  &&  mv redis-4.0.11 redis
cd  redis  
make  
mkdir /usr/local/redis/bin
cd /usr/local/redis/src
cp redis-cli redis-server redis-sentinel redis-check-aof redis-benchmark /usr/local/redis/bin/                 
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo $?
/usr/local/redis/bin/redis-server /usr/local/redis/redis.conf &
sleep 1
lsof -i:6379
sleep 2

cat << END
===================================================================================
ReadMe:
设置密码：     vim /usr/local/redis/redis.conf  [requirepass quizii2019(500行左右)]\n
使用密码登录： /usr/local/redis/bin/redis-cli  -a quizii2019
END
}

menu(){
#clear
cat << END
                  ___________________________________   
                 |https://blog.csdn.net/zhutongcloud|
                    |\_________JingNan _________/|
                    | ** (1).[System init   ] ** |
                    | ** (2).[install Mysql ] ** |
                    | ** (3).[install Memcached]*|
                    | ** (4).[install Redis ] ** |
                    | ** (5).[-----Exit-----] ** |
-------------------------------------------------------------------------
|            This script is suitable for centos7                        |
-------------------------------------------------------------------------
|******************Please Enter Your Choice:[ 1-5]**********************|
-------------------------------------------------------------------------
END
}
####################################################################################
while true
do
menu
read -t 60 -p "Please enter the installation number :" a
 echo "you selected $a server"
 case $a in
  1)
  echo "
  |=====================**系统初始化含参数优化**==========================|"
  system_init
  ;;
  2)
 echo "
 |===================**Make Install Mysql-5.7.17**=======================|"
  mysql_install
 ;;
 3)
 echo "
 |===================**Make Install Memcached**==========================|"
 memcached_install
 ;;

 4)
 echo "
 |===================**Make Install Redis**==============================|"
 redis_install
 ;;
  *|5)
 echo "exit,please reexecute."
 exit
 ;;
 esac
done


