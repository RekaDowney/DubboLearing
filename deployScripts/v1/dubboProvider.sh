#!/usr/bin/env bash

source base_service.sh

readonly version='1.0'
readonly providerJarAbsolutePath='/opt/app/dubbo/provider.jar'
readonly newProviderJarPath='/opt/code/DubboLearning/target/provider.jar'
readonly loggingPath="/opt/app/dubbo/provider.log"
readonly configLocation='/opt/app/dubbo/provider.yml'
readonly scriptName=$(pwd)/$(basename $0)

function main() {
    if [[ $# -ne 1 ]]; then
        echo -en "${red}用法：${scriptName} <[start|stop|restart|run]>${endColor}\n"
        return 1
    fi
    local d=$(pwd)
    local result=0
    case "$1" in
        "start")
            __start "${providerJarAbsolutePath}" "${newProviderJarPath}" "${loggingPath}" "${configLocation}"
            result=$?
        ;;
        "stop")
            __stop "${providerJarAbsolutePath}"
            result=$?
        ;;
        "restart")
            __restart "${providerJarAbsolutePath}" "${newProviderJarPath}" "${loggingPath}" "${configLocation}"
            result=$?
        ;;
        "run")
            __run "${providerJarAbsolutePath}" "${newProviderJarPath}" "${loggingPath}" "${configLocation}"
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

main $@
exit $?

