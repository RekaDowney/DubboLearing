# Dubbo 基础教程

## 安装并启动`ZooKeeper`

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

### 启动 dubbo-admin

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


## API 模块

　　`API`模块主要用来管理服务模型、服务接口、服务异常等一些通用化的类和接口。如果有必要，甚至可以将某些配置文件也交由`API`模块进行管理。

　　这里以常见的账户体系服务为例来展示`API`模块：

_用户模型_

```java

    @Data
    @NoArgsConstructor
    @EqualsAndHashCode
    @AllArgsConstructor
    @Accessors(chain = true)
    public class User implements Serializable {
    
        private static final long serialVersionUID = 1L;
        private Long id;
        private String username;
        private String password;
        private LocalDate birthday;
        private boolean isMale;
    
    }

```

_用户服务_

```java

    public interface UserService {
    
        User save(User user);
    
        User delete(Long id);
    
        User update(User user);
    
        User findById(Long id);
    
        List<User> findAll();
    
    }


```

　　目前`API`模块就只需要这些内容。其中*用户服务*为接口，后续由服务提供方提供相关实现。


## 服务提供方

　　服务提供方主要是通过`RPC`提供服务，相比于`HTTP`服务，`RPC`服务的一个最主要优先是`RPC`服务采用`TCP`协议传输，而`HTTP`服务采用`HTTP`协议传输，后者需要每次建立连接需要经过三次握手等步骤后才能继续`TCP`传输，因此效率上会明显低于`RPC`服务。

### 依赖

　　服务提供方需要引入`API`模块，服务提供方需要的依赖如下：

```xml

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
        </dependency>

        <dependency>
            <groupId>com.alibaba.boot</groupId>
            <artifactId>dubbo-spring-boot-starter</artifactId>
            <version>0.2.0</version>
        </dependency>
    </dependencies>

```

　　其中真正需要的是`spring-boot-starter`和`dubbo-spring-boot-starter`这两个依赖，但是为了方便而直接引入了`spring-boot-starter-web`等其他依赖。

　　这里使用的`spring-boot`版本为`2.X.X`，因此对应的`dubbo-spring-boot-starter`版本必须为`0.2.0`。如果`spring-boot`版本为`1.X.X`，那么`dubbo-spring-boot-starter`版本就使用`0.1.0`。

### Dubbo配置

　　这里只介绍与`Spring`集成后的主要配置方式，其他的像保留`dubbo.xml`或者`dubbo.properties`配置文件的做法这里一概不介绍。配置采用`yaml`编写（主要是为了方便查看注释性文字）

```yaml

    ## Spring 配置
    spring:
      application:
        name: Dubbo-Provider
    
    ## Dubbo 配置
    dubbo:
      # 配置 ServiceConfig 的扫描路径，即 Dubbo 扫描 Service 和 Reference 组件的包路径
      # 可以通过 @EnableDubbo 注解的配置项完成
      scan:
        base-packages: me.junbin.dubbo.service
      ## 配置 ApplicationConfig，Dubbo 服务信息
      application:
        # 应用服务ID，通常唯一，用来区分相同应用中的不同服务
        # id: xxx
        ## 配置 Dubbo 应用名称，多个提供相同服务的微服务采用相同的应用名称
        name: Provider
        ## 配置 Dubbo 使用的日志框架，默认为 slf4j
        logger: slf4j
      ## 配置 RegistryConfig，注册中心地址
      registry:
    #    protocol: zookeeper
        address: zookeeper://tx.me:2181
        # 向注册中心注册自身（默认为true）
        register: true
        # 不向注册中心订阅（默认为true）
        subscribe: false
        # 注册中心不存在时，是否抛出异常
        check: true
        # 采用 curator ZK 客户端
        client: curator
      ## 配置 ProtocolConfig，通信协议
      protocol:
        # 通信协议采用 dubbo 协议
        name: dubbo
        # 通信端口为 7658
        port: 7658
    
    ## 版本配置，用来统一管理服务版本并增强灰度发布
    user:
      service:
        v1_0_0: 1.0.0

```

　　主要配置

- `dubbo.application.name`：指定当前应用名称，映射到`com.alibaba.dubbo.config.ApplicationConfig`
- `dubbo.registry.address`：指定服务注册中心地址，建议直接采用`${scheme}://${ip}:${host}`这种更加明确的配置，而不要额外追加一个`dubbo.registry.protocol`配置项表示注册中心类型。注册中心支持`mmulticast`、`zookeeper`、`redis`、`simple`四种。官方推荐使用`zookeeper`
- `dubbo.registry.register`：当前（应用）服务是否需要登记（注册）到注册中心，只有在注册中心注册后，其他（应用）服务才能通过注册中心发现服务（当然也可以直连服务）；同时我们才能够在`dubbo-admin`控制台上看到服务信息
- `dubbo.registry.subscribe`：当前服务是否需要订阅注册中心中的服务，只有订阅后才能够发现其他服务的地址和通信协议等信息
- `dubbo.protocol.name`：指定当其他服务请求当前服务时的通信协议，支持的通信协议有：`dubbo`、`rmi`、`http`和`hessian`
- `dubbo.protocol.port`：指定与当前服务进行通信时的端口。`dubbo`协议默认通信端口为`20880`；`rmi`协议默认通信端口为`1099`；`http`和`hessian`协议默认通信端口为`80`。`-1`表示自动使用一个尚未分配的端口

### 提供服务

　　通过实现`API`的服务接口`me.junbin.dubbo.service.UserService`并添加`com.alibaba.dubbo.config.annotation.Service`注解实现对外暴露服务。

```java

    // Dubbo 依赖 Spring，必须将服务交由 Spring 容器托管，这样 Dubbo 才能通过 Spring 容器来管理（增强）服务
    @Component
    @Service(version = "${user.service.v1_0_0}") // 该注解表明当前 Bean 是一个服务提供方
    public class UserServiceImpl implements UserService {
    
        private static final ConcurrentMap<Long, User> DB = new ConcurrentHashMap<>(32);
        private static final AtomicLong idGen = new AtomicLong(0);
        private static final Logger LOGGER = LoggerFactory.getLogger(UserServiceImpl.class);
    
        static {
            long id = idGen.incrementAndGet();
            DB.put(id, new User(id, "AAA", "aaa", LocalDate.of(1995, 8, 5), true));
            id = idGen.incrementAndGet();
            DB.put(id, new User(id, "BBB", "bbb", LocalDate.of(1996, 9, 3), false));
            id = idGen.incrementAndGet();
            DB.put(id, new User(id, "CCC", "ccc", LocalDate.of(1994, 10, 12), false));
            id = idGen.incrementAndGet();
            DB.put(id, new User(id, "DDD", "ddd", LocalDate.of(1996, 4, 1), true));
            id = idGen.incrementAndGet();
            DB.put(id, new User(id, "EEE", "eee", LocalDate.of(1997, 4, 6), false));
            id = idGen.incrementAndGet();
            DB.put(id, new User(id, "FFF", "fff", LocalDate.of(1996, 2, 15), false));
            id = idGen.incrementAndGet();
            DB.put(id, new User(id, "GGG", "ggg", LocalDate.of(1993, 8, 25), false));
            id = idGen.incrementAndGet();
            DB.put(id, new User(id, "HHH", "hhh", LocalDate.of(1995, 3, 3), true));
            id = idGen.incrementAndGet();
            DB.put(id, new User(id, "III", "iii", LocalDate.of(1994, 1, 6), false));
            id = idGen.incrementAndGet();
            DB.put(id, new User(id, "JJJ", "jjj", LocalDate.of(1997, 4, 5), true));
        }
    
        @Override
        public User save(User user) {
            long id = idGen.incrementAndGet();
            user.setId(id);
            LOGGER.info("新增客户：{}", user);
            DB.put(id, user);
            return user;
        }
    
        @Override
        public User delete(Long id) {
            LOGGER.warn("删除客户：{}", DB.get(id));
            return DB.remove(id);
        }
    
        @Override
        public User update(User user) {
            LOGGER.info("更新客户：{} ==> {}", DB.get(user.getId()), user);
            DB.put(user.getId(), user);
            return user;
        }
    
        @Override
        public User findById(Long id) {
            LOGGER.info("查找客户：{}", id);
            return DB.get(id);
        }
    
        @Override
        public List<User> findAll() {
            LOGGER.info("查询所有客户");
            return new ArrayList<>(DB.values());
        }
    
    }


```

　　实现上与普通的`Spring Service Bean`没有任何区别，只不过多了一个`@com.alibaba.dubbo.config.annotation.Service`注解表明是一个`Dubbo`服务。这里采用`@Component`注解将`Bean`交由`Spring`管理，当然也可以使用`@org.springframework.stereotype.Service`注解。

### 启动类

```java

    @EnableDubbo // 启动 Dubbo 的注解支持
    @SpringBootApplication
    public class ProviderApplication {
    
        public static void main(String[] args) throws Exception {
            new SpringApplicationBuilder(ProviderApplication.class)
                    // 表明当前不是 Web 环境，不需要启动 Spring 的 Web 功能，但不能停止进程以便提供服务
                    .web(WebApplicationType.NONE).run(args);
        }
    
    }

```

　　启动（引导）类主要使用了`@EnableDubbo`注解表示启动`Dubbo`的注解支持，同时通过`SpringApplicationBuilder#web(WebApplicationType.NONE)`表明当前应用不需要使用`Spring`的`Web`功能。

　　到这里，一个`Dubbo`提供方（应用）服务已经完成了，我们可以通过`mvn clean -Dmaven.test.skip spring-boot:run`命令启动服务。并在`dubbo admin`管理页面上看到服务提供方的配置。

![03 服务提供方.jpg](https://i.loli.net/2018/09/15/5b9cb69be0954.jpg)

### IP 混乱

　　`Dubbo`服务提供方在向注册中心注册自身时，如果遇到服务器存在多网卡的情况下，容易发生注册`IP`混乱或者说错误的问题，具体逻辑参考`com.alibaba.dubbo.config.ServiceConfig#doExportUrls`。主要是过滤了`127`等回环地址后，会将其他内网`IP`（诸如`10.XX.XX.XX`）作为对外通信的`IP`注册到注册中心中，这会导致其他非内网应用消费时抛出连接超时异常。

_解决方案_

　　在服务器上执行`echo "外网IP $(hostname)" >> /etc/hosts`命令将主机与`IP`绑定起来，这样`com.alibaba.dubbo.config.ServiceConfig`会获取到该`IP`并使用该`IP`注册到注册中心中。需要特别注意后续在修改主机的`hostname`时也需要同步修改`/etc/hosts`文件。


## 服务消费方

　　服务消费方主要通过订阅注册中心中已经注册的服务，通过获取服务提供方的通信地址、通信协议等必要信息后与服务提供方进行交互。

### 依赖

　　消费方的依赖在这里可以与提供方的依赖保持一致。都必须有`API`模块依赖和`dubbo-spring-boot-starter`依赖。

### Dubbo配置

```yaml

    server:
      port: 7653
    
    spring:
      application:
        name: Consumer
        
    dubbo:
      application:
        name: Consumer
      registry:
        address: zookeeper://tx.me:2181
        client: curator
      protocol:
        # 通信协议采用 dubbo 协议
        name: dubbo
        # 通信端口为 7658
        port: 7658
    
    
    ## 版本配置
    user:
      service:
        v1_0_0: 1.0.0

```

　　消费方由于不需要向对外提供其他服务，所以不需要配置通信规则。也可以配置`dubbo.registry.register=false`表示不向注册中心注册自身，但这时候就无法通过`dubbo admin`来管理该消费方了。因此建议默认还是想注册中心注册自身。

### 消费服务

```java

    @RestController
    @RequestMapping("/user")
    public class UserController {
    
        @Reference(version = "${user.service.v1_0_0}")
        private UserService userService;
    
        @GetMapping("/{id:\\d+}")
        public Object query(@PathVariable long id) {
            return userService.findById(id);
        }
    
        @GetMapping("/list")
        public Object list() {
            return userService.findAll();
        }
        
    }

```

　　消费方通过使用`@com.alibaba.dubbo.config.annotation.Reference`注解注入`RPC`服务。后续就可以直接通过该注入对象进行`RPC`消费。

### 启动类

```java

    @EnableDubbo
    @SpringBootApplication
    public class ConsumerApplication {
    
        public static void main(String[] args) throws Exception {
            SpringApplication.run(ConsumerApplication.class, args);
        }
    
    }

```

　　启动类同样需要添加`@EnableDubbo`注解启动`Dubbo`的注解支持功能，这里虽然没有配置`Dubbo`的扫描路径，但该注解默认会扫描该注解所在包及其子包下的所有类。

　　到此，一个`Dubbo`消费方服务也基本完成了。在启动服务提供方的前提下，可以通过`mvn clean -Dmaven.test.skip spring-boot:run`命令启动服务，并通过`http://localhost:7653/user/list`访问消费方，看是否与服务提供方正确建立通信。也可以直接在`dubbo admin`的管理页面上看到服务消费方的信息。

![04 服务消费方.jpg](https://i.loli.net/2018/09/15/5b9cb69e53ec9.jpg)


## 一键部署脚本

### alias 项目克隆打包

　　在服务器上添加如下`alias`，该`alias`默认会从`GitHub`克隆`master`分支项目并执行打包操作。可以通过`pkgDubbo ${分支名称}`打包指定名称的分支。

```bash

    alias pkgDubbo='function __package() { local d="$(pwd)"; local branch="master"; if [ $# -eq 1 ]; then branch="$1"; fi; echo -en "${green}打包dubbo项目的${branch}分支${endColor}\n"; cd /opt/code; rm -rf DubboLearning; git clone -b ${branch} https://github.com/RekaDowney/DubboLearning.git; cd DubboLearning; mvn clean -Dmaven.test.skip package; cd "${d}"; unset -f __package; }; __package'

    ## 去掉必须要的分号后，实际上该 alias 等同于下面的函数
    function __package() {
        local d="$(pwd)"
        local branch="master"
        if [ $# -eq 1 ]; then
            branch="$1"
        fi
        echo -en "${green}打包dubbo项目的${branch}分支${endColor}\n"
        cd /opt/code
        rm -rf DubboLearning
        git clone -b ${branch} https://github.com/RekaDowney/DubboLearning.git
        cd DubboLearning
        mvn clean -Dmaven.test.skip package
        cd "${d}"
        unset -f __package
    }
    __package
    
```

### 部署脚本

　　[基础脚本](https://github.com/RekaDowney/DubboLearning/blob/master/deployScripts/v2/base_service.sh)提供上层抽象，某个服务的部署脚本可以通过配置一些特定参数后`source`该脚本来获取部署命令。

　　该脚本的基础结构如下：

```bash
    
    #!/usr/bin/env bash
    
    ## 本脚本用法
    ## 在一个新的脚本中添加如下五个只读变量
    
    ### readonly jarAbsolutePath="" # 指定 springboot.jar 的绝对路径，必须能够唯一定位一个进程
    ### readonly newJarPath=“”      # 指定要启动、重启、运行服务的 springboot.jar 的绝对路径
    ### readonly loggingPath=“”     # 指定服务的日志记录文件
    ### readonly configLocation=“”  # 指定服务的额外配置文件，可以用来覆盖某些配置
    ### readonly scriptName=“”      # 指定当前脚本名称，通常直接使用"$(pwd)/$(basename $0)"表示
    
    ## 然后执行 source /path/to/base_service.sh 执行当前脚本
    
    ## 最后执行 main $@ 方法
    
    function exist() {
    }
    
    function __start() {
    }
    
    function __stop() {
    }
    
    function __restart() {
    }
    
    function __run() {
    }
    
    function main() {
    }

```

　　[服务提供方脚本](https://github.com/RekaDowney/DubboLearning/blob/master/deployScripts/v2/dubboProvider.sh)内容如下：

```bash

    #!/usr/bin/env bash
    
    ### readonly jarAbsolutePath="" # 指定 springboot.jar 的绝对路径，必须能够唯一定位一个进程
    ### readonly newJarPath=“”      # 指定要启动、重启、运行服务的 springboot.jar 的绝对路径
    ### readonly loggingPath=“”     # 指定服务的日志记录文件
    ### readonly configLocation=“”  # 指定服务的额外配置文件，可以用来覆盖某些配置
    ### readonly scriptName=“”   # 指定当前脚本名称，通常直接使用"$(pwd)/$(basename $0)"表示
    
    readonly jarAbsolutePath='/opt/app/dubbo/provider.jar'
    readonly newJarPath='/opt/code/DubboLearning/provider/target/provider-1.0.jar'
    readonly loggingPath="/opt/app/dubbo/provider.log"
    readonly configLocation='/opt/app/dubbo/provider.yml'
    readonly scriptName="$(pwd)/$(basename $0)"
    
    source ./base_service.sh
    
    main $@
    exit $?
    
```

　　授予脚本可执行权限后，添加内容为`alias dubboProvider='/opt/app/scripts/dubboProvider.sh'`的`alias`，后面可以通过`dubboProvider <start|stop|run|restart>`命令启动、停止、确保运行、重启服务提供方。

　　其中`configLocation`指定的配置文件中的配置将会覆盖`application.yml`中的配置。具体加载顺序可以参考[SpringBoot配置文件加载顺序与优先级](https://github.com/RekaDowney/SpringBootLearning#%E5%85%A8%E5%B1%80%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E5%8A%A0%E8%BD%BD%E9%A1%BA%E5%BA%8F%E4%B8%8E%E4%BC%98%E5%85%88%E7%BA%A7)

　　[服务消费方脚本](https://github.com/RekaDowney/DubboLearning/blob/master/deployScripts/v2/dubboConsumer.sh)

```bash

    #!/usr/bin/env bash
    
    ### readonly jarAbsolutePath="" # 指定 springboot.jar 的绝对路径，必须能够唯一定位一个进程
    ### readonly newJarPath=“”      # 指定要启动、重启、运行服务的 springboot.jar 的绝对路径
    ### readonly loggingPath=“”     # 指定服务的日志记录文件
    ### readonly configLocation=“”  # 指定服务的额外配置文件，可以用来覆盖某些配置
    ### readonly scriptName=“”   # 指定当前脚本名称，通常直接使用"$(pwd)/$(basename $0)"表示
    
    readonly jarAbsolutePath='/opt/app/dubbo/consumer.jar'
    readonly newJarPath='/opt/code/DubboLearning/consumer/target/consumer-1.0.jar'
    readonly loggingPath="/opt/app/dubbo/consumer.log"
    readonly configLocation='/opt/app/dubbo/consumer.yml'
    readonly scriptName="$(pwd)/$(basename $0)"
    
    source ./base_service.sh
    
    main $@
    exit $?

```

　　授予脚本可执行权限后，添加内容为`alias dubboConsumer='/path/to/dubboConsumer.sh'`的`alias`，后面可以通过`dubboConsumer <start|stop|run|restart>`命令启动、停止、确保运行、重启服务消费方。

　　其中`configLocation`指定的配置文件中的配置将会覆盖`application.yml`中的配置。具体加载顺序可以参考[SpringBoot配置文件加载顺序与优先级](https://github.com/RekaDowney/SpringBootLearning#%E5%85%A8%E5%B1%80%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E5%8A%A0%E8%BD%BD%E9%A1%BA%E5%BA%8F%E4%B8%8E%E4%BC%98%E5%85%88%E7%BA%A7)



~~## 安装并启动 Dubbo 监控中心~~

~~放弃使用 Dubbo Monitor，各种奇奇怪怪的问题，不能该dubbo.protocol.port，图片死活加载不出来，命名图片存在~~

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
    
    mkdir -p /opt/env/dubbo/monitor
    
    mv dubbo-monitor-simple/target/dubbo-monitor-simple-2.0.0-assembly.tar.gz /opt/env/dubbo/monitor/dubbo-monitor-assembly.tar.gz
    
    cd /opt/env/dubbo/monitor/
    
    tar -xzf dubbo-monitor-assembly.tar.gz
    
    mv dubbo-monitor-simple-2.0.0/* .
    
    rm -rf dubbo-monitor-simple-2.0.0/*
    
```

### 启动

　　启动`Dubbo Monitor`之前需要修改一下配置文件，通过`vim conf/dubbo.properties`修改：

```properties

    # 配置Dubbo注册中心地址，Dubbo Monitor 需要将自身作为提供方注册到注册中心中
    dubbo.registry.address=zookeeper://tx.me:2181
    # 配置 Dubbo Monitor 作为提供方时的服务交互地址
    dubbo.protocol.port=7070
    # 配置DubboMonitor Web 服务监听地址
    dubbo.jetty.port=7656

```

　　修改完毕后执行`./assembly.bin/start.sh`脚本启动`Dubbo Monitor`，访问`${host}:${dubbo.jetty.port}`进入监控页面。

![05 DubboMonitor监控页面.jpg](https://i.loli.net/2018/09/16/5b9e4266e5e39.jpg)

　　`DubboMonitor`提供的服务管理脚本：

- `conf/start.sh`启动`DubboMonitor`
- `conf/stop.sh`停止`DubboMonitor`
- `conf/restart.sh`重启`DubboMonitor`

### 应用服务开启监控

　　单单启动`Dubbo Monitor`并没有任何作用，必须在应用服务中开启（配置）监控服务后，才能在`Dubbo Monitor`中看到监控内容。

　　在提供方或者消费方中通过修改`Dubbo`来开启监控。配置如下：

```yaml

    dubbo:
      monitor:
        # 从注册中心发现监控中心地址
        protocol: registry
        # 直连监控中心服务器地址
        # address: tx.me:${dubboMonitorProtocolPort}

```

