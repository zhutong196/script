#!/bin/bash
# Author: zhutongcloud 
# Email:  zhutongcloud@163.com
# BLOG:  https://blog.csdn.net/zhutongcloud
# system: centos
# 系统基础优化脚本
######################


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
yum -y update

# 更改Linux系统时区
#rm -rf /etc/localtime
#ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#timedatectl set-timezone 'Asia/Shanghai'
# 设置ntp
yum -y install ntp
ntpdate -u cn.pool.ntp.org
hwclock --systohc
timedatectl set-timezone Asia/Shanghai

# 设置 ulimit
echo "ulimit -SHn 102400" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
*       soft    nofile  65535
*       hard    nofile  65535
EOF

# 系统最小化安装，安装所需要的软件
yum -y install vim  wget lrzsz  bash-completion net-tools  lsof  psmisc  tree unzip  #zabbix-agent
# 关闭selinux 和 firewalld
echo "=========close selinux==========="
setenforce 0
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
echo "selinux is disabled"

systemctl disable firewalld
systemctl stop firewalld
echo "firewalld is disabled"


# 调整文件描述符数量
/bin/cp /etc/security/limits.conf /etc/security/limits.conf.bak
echo '* -   nofile  65535'>>/etc/security/limits.conf

# 更改字符集
/bin/cp /etc/sysconfig/i18n /etc/sysconfig/i18n.bak
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
net.ipv4.ip_forward = 1
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
net.core.somaxconn = 262144
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
service sshd restart

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

