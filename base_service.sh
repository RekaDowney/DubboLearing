#!/usr/bin/env bash

# 调用方式： exist <jarAbsolutePath>，必须能够唯一定位一个进程
function exist() {
    local jarAbsolutePath="$1"
    local allps=$(ps auxw | grep ${jarAbsolutePath} | grep -v grep | wc -l)
    if [[ ${allps} -eq 1 ]]; then
        local pid=$(ps auxw | grep ${jarAbsolutePath} | grep -v grep | awk '{print $2}')
        if [[ ${pid} -gt 0 ]]; then
            return 0
        fi
    fi
    return 1
}

# 调用方式：__start <jarAbsolutePath> <newJarPath> <loggingPath> [configLocation]
# __start '/opt/app/xxx.jar' '/opt/code/project/target/xxx.jar' '/opt/app/xxx.log' '/opt/app/config.yml'
function __start() {
    local jarAbsolutePath="$1"
    local newJarPath="$2"
    local loggingPath="$3"
    local serviceName=$(basename "${jarAbsolutePath}")
    if exist "${jarAbsolutePath}"; then
        local pid=$(ps auxw | grep ${jarAbsolutePath} | grep -v grep | awk '{print $2}')
        echo -en "${red}${serviceName}服务正在运行（pid=${pid}）...无法执行启动操作${endColor}\n"
        return 1
    fi
    rm -rf ${jarAbsolutePath}
    cp ${newJarPath} ${jarAbsolutePath}
    if [ $# -eq 4 ]; then
        ## 通过 spring.config.location 指定配置文件加载路径
        local configLocation="$4"
        nohup java -jar ${jarAbsolutePath} --spring.config.additional-location=file:${configLocation} > ${loggingPath} 2>&1 &
    else
        nohup java -jar ${jarAbsolutePath} > ${loggingPath} 2>&1 &
    fi
    sleep 1s
    if exist "${jarAbsolutePath}"; then
        echo -en "${green}${serviceName}服务启动成功...${endColor}\n"
        return 0
    else
        echo -en "${red}${serviceName}服务启动失败...${endColor}\n"
        return 1
    fi
}

# 调用方式：__stop <jarAbsolutePath>
function __stop() {
    local jarAbsolutePath="$1"
    local serviceName=$(basename "${jarAbsolutePath}")
    if exist "${jarAbsolutePath}"; then
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

# 调用方式：__restart <jarAbsolutePath> <newJarPath> <loggingPath> [configLocation]
# __restart '/opt/app/xxx.jar' '/opt/code/project/target/xxx.jar' '/opt/app/xxx.log' '/opt/app/config.yml'
function __restart() {
    local jarAbsolutePath="$1"
    local newJarPath="$2"
    local loggingPath="$3"
    local serviceName=$(basename "${jarAbsolutePath}")
    if ! exist "${jarAbsolutePath}"; then
        echo -en "${red}${serviceName}服务尚未启动，无法重启${endColor}\n"
        return 10
    fi
    __stop "${jarAbsolutePath}" > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo -en "${red}${serviceName}重启时服务关闭失败...${endColor}\n"
        return 11
    fi
    __start $@ &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo -en "${red}${serviceName}重启时服务启动失败...${endColor}\n"
        return 12
    fi
    echo -en "${green}${serviceName}服务重启成功...${endColor}\n"
    return 0
}

# 调用方式：__run <jarAbsolutePath> <newJarPath> <loggingPath> [configLocation]
# __run '/opt/app/xxx.jar' '/opt/code/project/target/xxx.jar' '/opt/app/xxx.log' '/opt/app/config.yml'
function __run() {
    local jarAbsolutePath="$1"
    local newJarPath="$2"
    local loggingPath="$3"
    local serviceName=$(basename "${jarAbsolutePath}")
    if exist "${jarAbsolutePath}"; then
        echo -en "${yellow}${serviceName}服务正在运行...${endColor}\n"
        return 3
    else
        __start $@ &> /dev/null
        if [[ $? -ne 0 ]]; then
            echo -en "${red}${serviceName}服务启动失败...${endColor}\n"
            return 0
        else
            echo -en "${green}${serviceName}服务启动成功...${endColor}\n"
            return 1
        fi
    fi
}