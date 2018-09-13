## Dubbo 基础教程

### 安装并启动`ZooKeeper`

```bash

    wget https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.13/zookeeper-3.4.13.tar.gz

    tar -xzf zookeeper-3.4.13.tar.gz

    # 创建 zk 用户组和用户
    groupadd zk

    useradd -g zk -M -s /sbin/nologin zk

    mv zookeeper-3.4.13 zookeeper

    chown -R zk:zk zookeeper

    cd zookeeper/conf

    # 复制一份配置文件
    cp zoo_sample.cfg zoo.cfg
    
    chown -R zk:zk zookeeper

    # 修改 tickTime（心跳包时间，单位：毫秒）
    # 修改 dataDir（内存数据库镜像存储路径，不可以放在 /tmp 等临时目录）
    # 修改 clientPort（ZK连接端口，默认为2181）

    cd ../
    
    # 启动 ZK
    ./bin/zkServer.sh start

```

## 安装并启动 Dubbo-Admin 管理控制台

### 打包

　　方式一：克隆源码后打包

```bash

    git clone https://github.com/apache/incubator-dubbo-ops.git
    
    cd incubator-dubbo-ops

    # 切换到master分支
    git branch --track master origin/master
    git checkout master
    
    # 打包
    mvn clean -Dmaven.test.skip package
    
    # 将 dubbo-admin 移动到当前目录并重命名
    mv dubbo-admin/target/dubbo-admin-0.0.1-SNAPSHOT.jar dubbo-admin.jar
    
```

　　方式二：直接下载`master`分支代码后安装

```bash

    wget https://github.com/apache/incubator-dubbo-ops/archive/master.zip
    unzip master.zip
    cd incubator-dubbo-ops-master
    mvn clean -Dmaven.test.skip package
    # 将 dubbo-admin 移动到当前目录并重命名
    mv dubbo-admin/target/dubbo-admin-0.0.1-SNAPSHOT.jar dubbo-admin.jar

```

### 配置 dubbo-admin

　　默认`dubbo-admin`的`SpringBoot`配置如下：

```properties

    server.port=7001
    spring.velocity.cache=false
    spring.velocity.charset=UTF-8
    spring.velocity.layout-url=/templates/default.vm
    spring.messages.fallback-to-system-locale=false
    spring.messages.basename=i18n/message
    spring.root.password=root
    spring.guest.password=guest
    
    dubbo.registry.address=zookeeper://127.0.0.1:2181

```

　　我们可以在`dubbo-admin.jar`的同级目录下添加`application.yml`配置文件来覆盖其中的某些配置。

```yaml

    # dubbo-admin 的监听端口
    server:
      port: 7652

    # dubbo-admin root 账户密码
    spring:
      root:
        password: Root@123
        
```

　　要运行`dubbo-admin`，请先**确保`zookeeper`已经启动**。

　　接着在该目录下通过`nohup java -jar dubbo-admin.jar &>dubboadmin.log &`命令后台启动`dubbo-admin`。使用`tail -f dubboadmin.log`查看启动情况。

　　启动成功后可以看到如下日志：

```text

    INFO dubboadmin.SpringUtil -  [DUBBO] set applicationcontext, dubbo version: 2.6.2, current host: XX.XX.XX.XX

```

　　最后我们通过如下命令对外开放`7652`端口的访问并测试登陆：

```bash

    firewall-cmd --permanent --add-port=7652/tcp
    
    firewall-cmd --reload

```

　　以下的请求登陆`Dubbo`的页面以及登陆成功后的页面。

![01 请求登陆Dubbo.jpg](https://i.loli.net/2018/09/12/5b992d8f18de7.jpg)

![02 登陆Dubbo首页.jpg](https://i.loli.net/2018/09/12/5b992d8fbd58f.jpg)

