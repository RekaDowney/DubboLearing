## Dubbo 基础教程

### 安装`ZooKeeper`

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
