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

source base_service.sh

main $@
exit $?

