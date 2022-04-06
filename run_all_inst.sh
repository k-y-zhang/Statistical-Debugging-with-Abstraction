#!/bin/bash
PROCESS_NUM=1
[ -z "$1" ] || PROCESS_NUM="$1"
# 这个脚本用来获取 RQ1和RQ2的数据。支持多线程。

# java -jar /home/user/Desktop/tmp/bin/HI.jar "/home/user/Desktop/lab4/" nanoxml /home/user/Desktop/lab4/out/
# java -jar tools/HI.jar "outputs" siena outputs/out/
# #exit
# for bid in ; do

#     ./profile.sh Lang $bid "coarse-grained" | tee  "Lang-2-cg.log"
#     bash profile.sh Lang $bid "fine-grained" | tee > "Lang-2-fg.log"

# done
#mkdir -p log 项目信息

pids=(Lang Closure Chart Time Math Mockito) # Chart Time Closure Math Mockito
declare -A bids
bids["Lang"]=65
bids["Chart"]=26
bids["Math"]=106
bids["Mockito"]=38
bids["Time"]=27
bids["Closure"]=176
echo "${pids[@]}"
echo "keys ${!bids[*]}"
echo "values ${bids[*]}"


# 测试一个例子
testit() {
    local bid=$1
    for pid in "${pids[@]}"; do
        echo "$pid"
        bash -v profile_v2.sh "$pid" "$bid" "coarse-grained" || exit 1
    done
}

testit 2
read
read

# exit
# 检查日志，完成进度。
for pid in "${pids[@]}"; do
    for ((i = 1; i <= ${bids[$pid]}; i++)); do
        if ! grep -q "${pid}-${i}:fine-grained$" "outputs/log.txt"; then
            echo "TODO " "$pid" "$i"
        fi
    done
done
read -r

# 执行profile过程，收集数据。


mkdir -p outputs/log
f1() {
    echo "$1" "$2"
    { bash -v profile_v2.sh "$1" "$2" "coarse-grained" 2>&1 || exit 1; } | tee "outputs/log/$1_$2_cg.log"
    { bash -v profile_v2.sh "$1" "$2" "fine-grained" 2>&1 || exit 1; } | tee "outputs/log/$1_$2_fg.log"
    rm -f "outputs/log/$1_$2_cg.log" "outputs/log/$1_$2_fg.log"
}
export -f f1
for pid in "${pids[@]}"; do
    for ((i = 1; i <= ${bids[$pid]}; i++)); do
        echo "$pid" "$i"
    done
done | xargs -L1 -n2 -P "$PROCESS_NUM" bash -c 'f1 "$@"' _
