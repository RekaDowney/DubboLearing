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
    local allps=$(ps auxw | grep ${jarAbsolutePath} | grep -v grep | wc -l)
    if [[ ${allps} -eq 1 ]]; then
        local pid=$(ps auxw | grep ${jarAbsolutePath} | grep -v grep | awk '{print $2}')
        if [[ ${pid} -gt 0 ]]; then
            return 0
        fi
    fi
    return 1
}

function __start() {
    if exist; then
        local pid=$(ps auxw | grep ${jarAbsolutePath} | grep -v grep | awk '{print $2}')
        echo -en "${red}${serviceName}服务正在运行（pid=${pid}）...无法执行启动操作${endColor}\n"
        return 1
    fi
    rm -rf ${jarAbsolutePath}
    cp ${newJarPath} ${jarAbsolutePath}
    if [ -n "${configLocation}" ]; then
        ## 通过 spring.config.location 指定配置文件加载路径
        nohup java -jar ${jarAbsolutePath} --spring.config.additional-location=file:${configLocation} > ${loggingPath} 2>&1 &
    else
        nohup java -jar ${jarAbsolutePath} > ${loggingPath} 2>&1 &
    fi
    sleep 1s
    if exist; then
        echo -en "${green}${serviceName}服务启动成功...${endColor}\n"
        return 0
    else
        echo -en "${red}${serviceName}服务启动失败...${endColor}\n"
        return 1
    fi
}

function __stop() {
    if exist; then
        local pid=$(ps auxw | grep ${jarAbsolutePath} | grep -v grep | awk '{print $2}')
        kill -SIGKILL ${pid}
        #        kill -SIGTERM ${pid}
        if [[ $? -eq 0 ]]; then
            # 中止信号发送成功后，休眠一段时间等待进程关闭
            sleep 3s
            echo -en "${green}${serviceName}服务关闭成功${endColor}\n"
            return 0
        else
            echo -en "${red}${serviceName}服务关闭失败${endColor}\n"
            return 1
        fi
    else
        echo -en "${yellow}${serviceName}服务尚未启动，无需关闭${endColor}\n"
        return 2
    fi
}

function __restart() {
    if ! exist; then
        echo -en "${red}${serviceName}服务尚未启动，无法重启${endColor}\n"
        return 10
    fi
    __stop > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo -en "${red}${serviceName}重启时服务关闭失败...${endColor}\n"
        return 11
    fi
    __start &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo -en "${red}${serviceName}重启时服务启动失败...${endColor}\n"
        return 12
    fi
    echo -en "${green}${serviceName}服务重启成功...${endColor}\n"
    return 0
}

function __run() {
    if exist; then
        echo -en "${yellow}${serviceName}服务正在运行...${endColor}\n"
        return 3
    else
        __start &> /dev/null
        if [[ $? -ne 0 ]]; then
            echo -en "${red}${serviceName}服务启动失败...${endColor}\n"
            return 0
        else
            echo -en "${green}${serviceName}服务启动成功...${endColor}\n"
            return 1
        fi
    fi
}

function main() {
    if [[ $# -ne 1 ]]; then
        echo -en "${red}用法：${scriptName} <[start|stop|restart|run]>${endColor}\n"
        return 1
    fi
    local d=$(pwd)
    local result=0
    case "$1" in
        "start")
            __start
            result=$?
        ;;
        "stop")
            __stop
            result=$?
        ;;
        "restart")
            __restart
            result=$?
        ;;
        "run")
            __run
            result=$?
        ;;
        *)
            echo -en "${red}用法：${scriptName} <[start|stop|restart|run]>${endColor}\n"
            result=1
        ;;
    esac
    cd "${d}"
    return ${result}
}
