#!/bin/bash

# 该脚本用于解析iOS崩溃日志
# 使用方法: ./crash_analysis.sh <dsym_file> <ips_file>
# 示例: ./crash_analysis.sh YourApp.app.dSYM/Contents/Resources/DWARF/YourApp YourApp.ips

if [ $# -ne 2 ]; then
    echo "错误的输入参数！"
    echo "使用方法: ./crash_analysis.sh <dsym_file> <ips_file>"
    exit 1
fi

dsym_file=$1
ips_file=$2

# 解析崩溃日志
atos_cmd="atos -o ${dsym_file} -arch arm64 -l `xcrun dwarfdump --uuid ${dsym_file} | awk '{print $2}'`"
while read -r line; do
    if [[ ${line} = *+[0-9]* ]]; then
        address=`echo ${line} | grep -oE "\[.*\]" | sed 's/\[//g' | sed 's/\]//g'`
        $atos_cmd ${address}
    else
        echo ${line}
    fi
done < ${ips_file}