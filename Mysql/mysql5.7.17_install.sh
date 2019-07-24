#! /bin/bash
#time 20190719
#auth: jiangnan
#system: centos
#mysql5.7 二进制安装单实例
yum install -y wget
if [ ! -f mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz ];then
	wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz
else
	tar xvf mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz -C /usr/local
fi
sleep 3
mv /usr/local/mysql-5.7.17-linux-glibc2.5-x86_64 /usr/local/mysql
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

innodb_buffer_pool_size = 8G
innodb_buffer_pool_dump_pct = 40
innodb_page_cleaners = 4
innodb_undo_log_truncate = 1
innodb_purge_rseg_truncate_frequency = 128
log_timestamps=system
show_compatibility_56=on

symbolic-links=0
character_set_server=utf8
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES  ## 第一个参数 指定引擎操作SQL语句，若该MySQL不支持此引擎则直接报错，不会替换成默认引擎执行；第二个严格检查SQL的正确性，若规定四个字符长度，插入6个会报错，不会自动截断。
max_connections=5000
tmp_table_size=200M
query_cache_size=64M
query_cache_type=1
max_error_count=5000

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
