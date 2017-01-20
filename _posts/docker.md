---
title: Docker 介绍(一)
date: 2017-01-09 15:13:41
tags: docker
categories: docker
---
##### 关于Docker
首先Docker是一个开源的应用容器引擎,可以将应用程序和依赖打包到一个可移植的容器中,然后发布到Linux服务器,可用于实现虚拟化.
容器与其他容器共享内核,作为独立的进程在主机操作系统的用户空间中运行。

[github](https://github.com/docker/docker)&nbsp;&nbsp;
[官方介绍](https://www.docker.com/what-docker)

###### 概念
* 容器(container) 相当于一个轻量的主机,应用程序和其依赖都在其中
* 镜像(image) 容器的模板文件,相当于容器的安装文件
* 仓库(repository) 镜像的版本管理库,类似Git,[官方镜像库](https://hub.docker.com/)
* Dockerfile 用于构建镜像,主要描述镜像构建过程和容器启动时的命令

###### 安装docker(Ubuntu)
```sh
sudo apt install docker.io
```
###### 运行第一个镜像
```sh
docker run -it ubuntu echo "hello world"
>hello world
```
在第一次运行的过程中,Docker engine会根据镜像名称(这里我使用的Ubuntu)和tag(默认为latest,即最新版)在本地寻找镜像,如果没有则向远程仓库中寻找并pull到本地,然后启动此镜像
###### 根据自己程序自定义镜像
自定义镜像主要依赖于Dockerfile和docker-compose.yaml(可选)

一个简单的Dockerfile 文件如下
```Dockerfile
FROM nginx #父镜像
COPY ./ /usr/share/nginx/html/ #拷贝Dockerfile 所在的目录下的内容到容器中的目录
EXPOSE 80 #对主机暴露的端口
CMD ["nginx", "-g", "daemon off;"] #启动时执行的指令
```
根据Dockerfile 构建镜像
```sh
$ docker build -f /path/to/a/Dockerfile .
```
关于Dockerfile的详细介绍请见：[传送门](https://docs.docker.com/engine/reference/builder/)

推送镜像到Docker Hub或是其他远程镜像库
```sh
$ docker push yourname/newimage
```

###### 未完待续
