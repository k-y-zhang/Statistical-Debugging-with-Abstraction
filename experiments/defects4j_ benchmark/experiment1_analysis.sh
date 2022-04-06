#!/bin/bash
set -e -v
# 这个脚本用来分析 RQ1 和 RQ2 的数据
# case "$1"

# ''|_scalar|_return|_branch);;
# *)echo "fail $1" ; exit ;;

# esac
# [ "$1" match ]
#ruby tool.rb
echo "start"
find outputs/siena -type d
java -jar "tools/HI$1.jar" "$PWD/outputs/" siena "$PWD/outputs/out/"
