#!/bin/bash
# 这个脚本用来获取 RQ3 的数据
# 这个是性能测试，就不改成多线程了。
# 依赖 RQ1 的输出数据。
set -e
trap 'echo "ERROR: $BASH_SOURCE:$LINENO $BASH_COMMAND" >&2' ERR

PROCESS_NUM=1
[ -z "$1" ] || PROCESS_NUM="$1"
pids=(NULL Lang Chart Math Time Mockito Closure) #  Chart Math Time Closure Mockito
declare -A bids
bids["Lang"]=65
bids["Chart"]=26
bids["Math"]=106
bids["Mockito"]=38
bids["Time"]=27
bids["Closure"]=176
#ruby check_results.rb

i_hash() {
    echo -n "$(echo "$@" | md5sum | awk '{ print $1 }')"
}
run_tests() {
    local pid="${pids[$1]}"
    for m in "outputs" "coarse-grained" "fine-grained" "fine-grained-sampled-1" "fine-grained-sampled-100" "fine-grained-sampled-10000" "fine-grained-adaptive"; do
        if [ "$m" = "fine-grained-adaptive" ]; then
            [ -e "outputs/out/siena/SimuInfo/v$1_subv$2/R0T5" ] || return 0
            local includes=$(ruby -e 'print $<.readlines.select{|e|e=~/^</}.map{|e|"-sampler-include-method="+e.chomp.gsub(/->.*$/,"").gsub(/[ ():<>$]/, "-")}*" "' "outputs/out/siena/SimuInfo/v$1_subv$2/R0T5") # FunctionList/v${1}_subv${2}_C_LESS_FIRST_1_average 
            echo echo profile_v2.sh "$pid" "$2" include3 $includes
        else
            echo echo profile_v2.sh "$pid" "$2" "$m" # "-3"
        fi
        # return 0
    done
}
collect_running_time() {
    local pid="${pids[$1]}"
    for m in "fine-grained-adaptive" "outputs" "coarse-grained" "fine-grained" "fine-grained-sampled-1" "fine-grained-sampled-100" "fine-grained-sampled-10000"; do
        local time_file="outputs/nanoxml/outputs.alt/v$1/versions/subv$2/$m/time"

        if [ "$m" = "fine-grained-adaptive" ]; then
            local time=0
            # 插桩时间
            local includes=$(ruby -e 'print $<.readlines.select{|e|e=~/^</}.map{|e|"-sampler-include-method="+e.chomp.gsub(/->.*$/,"").gsub(/[ ():<>$]/, "-")}*" "' "outputs/out/siena/SimuInfo/v$1_subv$2/R0T5")
            #echo "include1>$includes\n$(i_hash $includes)"
            local time_file2="outputs/nanoxml/outputs.alt/v$1/versions/subv$2/include-$(i_hash $includes)/time4"
            #time=$((time + $(cat "${time_file2}" | sed -ne '2p' | sed -re 's/[^0-9]+//g')))
            time=$(cat "${time_file2}" | sed -ne '2p' | sed -re 's/[^0-9]+//g')
            # 不插桩时间
            local time_file1="outputs/nanoxml/outputs.alt/v$1/versions/subv$2/outputs/time4"
            timezero=$(cat "${time_file1}" | sed -ne '2p' | sed -re 's/[^0-9]+//g')
            # 数量
            local count=0
            for inc in $includes; do
            echo $inc
                echo $((count++))
            done
            echo "${time} ${timezero} ${count}"
            #read
            # time=$((time*1000000))
            time=$(((time - timezero) * 1000000 / count + timezero * 1000000))
            echo "$time"
            echo -e "Time in seconds: $((time / 1000000000)) \nTime in milliseconds: $((time / 1000000))" >"${time_file}"
        else 
            cp -f "${time_file}4" "${time_file}"
        fi
    done 2>&1 | tee "log/RQ3-$1-$2.log"

    #rm -f "log/RQ3-$pid-$i.log"
}

if false ; then
for p in 1 2 3 4 5 6; do
    pid="${pids[$p]}"
    echo "${bids[$pid]}" "$pid"
    for i in $(seq 1 "${bids[$pid]}"); do
        echo "$p" "$i"
        collect_running_time "$p" "$i"
    done
done
#read
fi
#exit

echo END
#read -r
#for pid in "${pids[@]}"; do
echo "{" >a3.sh
#echo "PROCESS_NUM=\$1" >>a3.sh
#echo "{" >>a3.sh
for p in 1 2 3 4 5 6; do
    pid="${pids[$p]}"
    echo "${bids[$pid]}" "$pid"
    for i in $(seq 1 "${bids[$pid]}"); do
        echo "$p" "$i"
        run_tests "$p" "$i" | awk '{print substr($0,0,130000)}' >>a3.sh
        # 
        # collect_time "$p" "$i"
    done
done
echo "} | xargs -L1 -P \"\$1\" bash -c 'bash \"\$@\"' _" >> a3.sh
#exit
read
read

bash a3.sh "$PROCESS_NUM"

# exit
# #echo "} | xargs -L1 -n5 -P \"\$PROCESS_NUM\" bash -c 'bash \"\$@\"' _" >>a3.sh
# #exit
# cat a3.sh | less # | grep -v 'Mockito 5 '
# bash a3.sh  | xargs -L1 -P "$PROCESS_NUM" bash -c 'bash "$@"' _
exit
#ruby ../paper_60/c1.rb

for p in 1 2 3 4 5 6; do
    pid="${pids[$p]}"
    echo "${bids[$pid]}" "$pid"
    for i in $(seq 1 "${bids[$pid]}"); do
        echo "$p" "$i"
        collect_running_time "$p" "$i"
    done
done

#exit
java -cp tools/HI.jar zuo.util.readfile.IterativeTimeReader "$PWD/outputs" nanoxml "$PWD/outputs/out/"
#java -cp tools/HI.jar zuo.util.readfile.IterativeTimeReader "$PWD/outputs" derby "$PWD/outputs/out/"
# java -cp tools/HI.jar zuo.util.readfile.IterativeTimeReader "outputs" derby "outputs/out/"
