---
title: Redis的安装
date: 2016-5-11
categories:
  - Redis
  - Linux
  - Ubuntu
tags:
  - 安装
  - 配置
---
Redis是一个开源的、支持网络、可基于内存亦可持久化的日志型、Key-Value数据库,在高并发的应用系统中有很多应用场景.简单介绍一下在linux 下如何安装redis.
#### 下载源码编译和安装
[3.2版本下载地址](http://download.redis.io/releases/redis-3.2.0.tar.gz "3.2版本") 
[Redis官网](http://redis.io/ "Redis官网")
```
 root@iZ25j7qhlyuZ:/usr/lib# wget -c http://download.redis.io/releases/redis-3.2.0.tar.gz
```
下载完成之后在当前目录下会得到一个压缩包redis-3.2.0.tar.gz,解压
```
root@iZ25j7qhlyuZ:/usr/lib# tar -xzvf redis-3.2.0.tar.gz redis-3.2.0/
```
#### 编译和安装
```
root@iZ25j7qhlyuZ:/usr/lib# cd redis-3.2.0/
root@iZ25j7qhlyuZ:/usr/lib/redis-3.2.0# make && make install
```
接下来输出了一大堆日志,好难懂,应该没有ERROR就行
#### 修改配置文件
首先修改内存分配策略
```
root@iZ25j7qhlyuZ:/usr/lib/redis-3.2.0# vi /etc/sysctl.conf
```
在尾部添加
```
vm.overcommit_memory=1
```
0, 表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存，内存申请允许；否则，内存申请失败，并把错误返回给应用进程。
1, 表示内核允许分配所有的物理内存，而不管当前的内存状态如何。
2, 表示内核允许分配超过所有物理内存和交换空间总和的内存。
保存
```
:wq
```
使其生效
```
root@iZ25j7qhlyuZ:/usr/lib/redis-3.2.0# sysctl vm.overcommit_memory=1
```
拷贝redis.conf到etc目录下
```
root@iZ25j7qhlyuZ:/usr/lib/redis-3.2.0# cp -rvf redis.conf /etc/
```
然后编辑etc目录下的redis.conf
```
root@iZ25j7qhlyuZ:/usr/lib/redis-3.2.0# vi /etc/redis.conf
```
daemonize yes #转为守护进程，否则启动时会每隔5秒输出一行监控信息
save 60 1000 #保存快照的频率，这里表示每分钟1000次改变的话保存到磁盘
maxmemory 256000000 #分配内存
rdbcompression：是否使用压缩
dbfilename：数据快照文件名（只是文件名，不包括目录）
dir：数据快照的保存目录（这个是目录）
requirepass yangkui 客户端访问时的密码(当前密码是yangkui)
...其他配置请参照官方文档 [官方文档配置部分](http://redis.io/topics/config "官方文档配置部分")
保存
```
:wq
```
启动Redis和测试连接
启动Redis服务
```
root@iZ25j7qhlyuZ:/usr/lib/redis-3.2.0# redis-server /etc/redis.conf
```
查看Redis服务进程看是否正常启动
```
root@iZ25j7qhlyuZ:/usr/lib/redis-3.2.0# ps -ef|grep redis
root     17896     1  0 17:22 ?        00:00:00 redis-server 127.0.0.1:6379
root     17903 14451  0 17:24 pts/0    00:00:00 grep --color=auto redis
```
启动正常,使用客户端工具连接
```
root@iZ25j7qhlyuZ:/usr/lib/redis-3.2.0# redis-cli -h 127.0.0.1
127.0.0.1:6379>
```
连接正常,输入密码
```
127.0.0.1:6379> AUTH yangkui
OK
127.0.0.1:6379>
```
然后Redis 就可以用起来了
```
127.0.0.1:6379> set myblog yangkui.net
OK
127.0.0.1:6379> get myblog
"yangkui.net"
127.0.0.1:6379>
```
至此,一个Redis单机安装完成.
补充,设置Redis开机启动
1. 编写开机自启动脚本
```
root@iZ25j7qhlyuZ:/usr/lib/redis-3.2.0# cp ./utils/redis_init_script /etc/init.d/redis
root@iZ25j7qhlyuZ:/usr/lib/redis-3.2.0# vi /etc/init.d/redis
```
2. 修改配置文件中注释位置的路径
```
#!/bin/sh
#
# Simple Redis init.d script conceived to work on Linux systems
# as it does use of the /proc filesystem.
REDISPORT=6379
EXEC=/usr/local/bin/redis-server
CLIEXEC=/usr/local/bin/redis-cli
PIDFILE=/var/run/redis.pid
CONF="/etc/redis.conf"
case "$1" in
    start)
        if [ -f $PIDFILE ]
        then
                echo "$PIDFILE exists, process is already running or crashed"
        else
                echo "Starting Redis server..."
                $EXEC $CONF
        fi
        ;;
    stop)
        if [ ! -f $PIDFILE ]
        then
                echo "$PIDFILE does not exist, process is not running"
        else
                PID=$(cat $PIDFILE)
                echo "Stopping ..."
                $CLIEXEC -p $REDISPORT -a yangkui shutdown
                while [ -x /proc/${PID} ]
                do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis stopped"
        fi
        ;;
    *)
        echo "Please use start or stop as first argument"
        ;;
esac
```
3. 通过VI保存好之后,赋给它可执行的权限和设置开机启动
```
root@iZ25j7qhlyuZ:/usr/lib/redis-3.2.0# chmod 777 /etc/init.d/redis
root@iZ25j7qhlyuZ:/usr/lib/redis-3.2.0# vi /etc/rc.local #非Ubuntu系统的话通过 chkconfig redis on来设置开机启动
```
4. 在exit 0 前面添加service redis start保存
```
service redis start
exit 0
~       
```
5. 测试下脚本是不是好使
 先杀掉redis进程,然后
```
root@iZ25j7qhlyuZ:/usr/lib/redis-3.2.0# service redis start
Starting Redis server...
root@iZ25j7qhlyuZ:/usr/lib/redis-3.2.0#
```
大功告成了
