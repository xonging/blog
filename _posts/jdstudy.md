---
title: 在京东的学习之JIMDB(一)
date: 2016-11-14
categories:
  - JIMDB
  - JD.COM
tags:
  - Redis
  - 分布式缓存
---
### 项目简介
#### 1 项目背景
##### 1.1 当前缓存的使用现状及问题
缓存云（统一Redis平台）来源于对缓存资源进行统一管理的需求，该需求最初从自动部署解决方案的讨论中衍生出来，解决运维的问题。目前，公司内部对缓存的使用存在如下问题和特点：

* 各个项目组单独部署缓存系统，有些项目组资源利用率不高；
* 各个项目组需要专人维护缓存系统的正常运行，这些人需要对缓存有很深的了解才能维护好这些系统；
* 各个项目组对缓存的使用方式不尽相同，往往需要自己开发某些程序来达到应用目的。

而JimDB则是缓存云的进一步技术创新 - 完全管理的分布式缓存与高速key/value存储服务。
##### 1.2 如何解决这些问题
搭建缓存资源池，实施平台化的统一管理。解决缓存各自申请，缺少统一管理、统一监控、failover的功能等问题，通过统一化提高主机资源的利用率，便于运维管理。

JimDB后期规划对外提供公有云服务，支持ISV或普通开发者的应用。

#### 2 JimDB的功能特性
##### 2.1 支持大容量缓存
采用“pre-sharding”技术，将缓存数据分摊到多个分片（每个分片上具有相同的构成，比如：都是一主一从两个节点）上，从而可以创建出大容量的缓存。将来会利用集群技术创建大容量的缓存。

###### 支持2种存储类型
* Jimdb M（纯内存）
* Jimdb S（内存+SSD两级存储）

选择Jimdb S版，可以存储10倍于内存容量的数据，并且提供更加可靠的持久性。

##### 2.2  缓存数据的高可用性
和mysql相同，采用的也是异步复制，目前可以达到等同于mysql级别的数据可用性。

Jimdb S版支持命令级的同步复制，超过mysql级别的数据可用性。

可设置为自动的failover

##### 2.3 支持多种I/O策略
支持读写分离、双写等I/O策略；针对读操作可分为“主优先”、“从优先”、“随机挑选”等方式；针对写操作可分为“同步写”和“异步写”。不同的I/O策略，对数据一致性的影响也不同，应用可以根据自身对数据一致性的需求，选择不同的I/O策略。

##### 2.4 支持动态扩容
动态扩容有两种支持两种形式的动态扩容。第一种形式，通过在单个节点上预留内存，然后需要扩容时直接使用预留内存的方法达到扩容的目的；第二种形式，通过增加分片数并结 合数据迁移来达到扩容的目的。第一种形式和第二种形式可以结合使用。第一种方式对应用的影响最小，但扩容效果有限；第二种方式扩容效果好，但由于会引发数 据迁移，从而挤占网络带宽，会对应用有一定的影响。

##### 2.5 支持特殊的命令及应用（spring-cache等）
目前已经支持了spring-cache与缓存的结合使用。将来会增加若干其他的特殊命令和应用。

#### 3 如何使用
使用之前应申请JIMDB集群,拿到jimURL或者(configId,和token)

##### 3.1 JAVA如何使用JIMDB
###### 3.1.1 通过MAVEN引如JIMDB java客户端
```xml
<dependency>
    <groupId>com.jd.jim.cli</groupId>
    <artifactId>jim-cli-jedis</artifactId>
    <version>1.4.5-SNAPSHOT</version>
</dependency>
<dependency>
    <groupId>com.jd.jim.cli</groupId>
    <artifactId>jim-cli-api</artifactId>
    <version>1.4.5-SNAPSHOT</version>
</dependency>
```
###### 3.1.2 Spring环境下配置使用JIMDB CLIENT
注意：在系统退出时，要确保销毁spring容器上下文
spring 配置文件
```xml
<bean id="jimClient" class="com.jd.jim.cli.ReloadableJimClientFactoryBean">
    <property name="jimUrl" value="jim://1803528671997086613/2" />
</bean>
```
java代码：
```java
@Resource(name = "jimClient")
private Cluster jimClient;

public String getByKey(String key){
  return jimClient.get(key);
}
```
###### 3.1.3 非Spring环境下使用JIMDB CLIENT
```java
package com.jd.jim.cli.demo;

import com.jd.jim.cli.Cluster;
import com.jd.jim.cli.ReloadableJimClientFactory;


public class JimClientDemo {
    public void close() {
        JimClientFactory.close();
    }

    public String getByKey(String key) {
        return JimClientFactory.getJimClient().get(key);
    }

    private static class JimClientFactory {
        private static final ReloadableJimClientFactory clientFactory;                                                                  
        private static final Cluster CLIENT_INSTANCE;

        static {
            clientFactory = new ReloadableJimClientFactory();
            clientFactory.setJimUrl("jim://1803528671997086613/2");

            CLIENT_INSTANCE = clientFactory.getClient();
        }

        public static Cluster getJimClient() {
            return CLIENT_INSTANCE;
        }

        public static void close() {
            if (clientFactory != null) {
                clientFactory.clear();
            }
        }
    }
}
```
###### 3.1.4 Spring-cache 注解方式
spring.xml
```xml
<bean id="configClient" class="com.jd.jim.cli.config.client.ConfigLongPollingClientFactoryBean">
    <property name="serviceEndpoint" value="http://cfs.jim.jd.local"></property>
</bean>

<bean id="jimClient" class="com.jd.jim.cli.ReloadableJimClientFactoryBean">
    <property name="configClient" ref="configClient"></property><!-- configured to your needs -->
    <property name="jimUrl" value="jim://1803528818953446384/1" />
</bean>

<bean id="cacheManager" class="com.jd.jim.cli.springcache.JimCacheManager">
    <property name="caches">
        <list>
            <bean class="com.jd.jim.cli.springcache.JimStringCache">
                <!-- key前缀 -->
                <property name="keyPrefix" value="cachetest_" />
                <!-- 客户端对象 -->
                <property name="jimClient" ref="jimClient" />
                <!-- TTL时间(以'秒'为单位) -->
                <property name="entryTimeout" value="60" />
                <!-- 值的序列化器 -->
                <property name="valueSerializer">
                    <bean class="com.jd.jim.cli.serializer.DefaultStringSerializer" />
                </property>
            </bean>
        </list>
    </property>
</bean>

<cache:annotation-driven cache-manager="cacheManager" />
```
java 代码：
```java
@Cacheable(value = "cachetest_", key = "#key")
public String getMessage(String key) {
    System.out.println("miss, get from db...");
    return "msg";
}

@CachePut(value = "cachetest_", key = "#key")
public String setMessage(String key, String message) {
    return message;
}

@Caching(evict = { @CacheEvict(value = "cachetest_", key = "#key") })
public boolean delete(String key) {
    return true;
}
```
