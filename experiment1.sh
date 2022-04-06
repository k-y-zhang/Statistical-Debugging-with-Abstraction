#!/bin/bash

# 说明
# - 这个实验由两个独立的部分结合在一起
#   - 一个是求MPS，另一个是做性能优化
#   - 两个部分不相互影响正确性
# 参数 pid bid k
# 输出到 log 文件，然后再解析 log，包括
#  - 插桩个数
#  - 三次profie的分别的执行时间和输出文件大小
#  - mbs的两步的执行时间和内存大小
#  - log 文件为 csv 格式，按时间排列

# 具体步骤

# step:1.cg 2.boost 3.prune
# mtehod: 1 inst（个数） 2 run（时间+磁盘） 3 preprocess（时间+内存） 4 mine（时间+内存）
# 每个 method 对 3 个 step 汇总。时间相加，注意不要重叠。空间。
# 数据集：SIR，defect4j

# 注意
# - 计算 prune 的时候，实验中是包含 boost 的，已经算是汇总的值了。
# - 依赖 实验2 RQ1的分析数据。那个要先跑完。
# - 注意 top-k 中 k 的取值。


#
## read the last item from time4, can run several times and calcuate the average of the last three rounds.
#

BOOST=0.00005
test "$1" = "5"  && BOOST=0.05
root=$(pwd)
set -e
#set -v
trap 'echo "ERROR: $BASH_SOURCE:$LINENO $BASH_COMMAND" >&2' ERR

pid=$1
bid=$2
k=$3


mkdir -p 'outputs/exp1/tmp'
OUT="outputs/exp1/tmp/log_$1_$2_$3.csv"
OUT2="outputs/exp1/log_$1_$2_$3.csv"
rm -rf "$OUT"

if grep -q "^${pid},${bid},$k,end$" "$OUT2"; then
    echo "skip finished $*" # 
    exit 0
fi
mkdir -p tmp
WS=$(mktemp -d -p "$PWD/tmp/" "${pid}-${bid}-$k.XXX")

echo "${WS}"
mkdir -p "${WS}/"

[ -z "$pid" ] && pid=1
pid_n=$pid
pids=(NULL Lang Chart Math Time Mockito Closure) #

[ -z "$bid" ] && bid=2
[ -z "$k" ] && k=1 # k=1, 5, 10
key="$pid,$bid,$k"
echo "$key,start" >>"$OUT"

himps_boost_output_file="${WS}/himps_boost_output.txt"
himps_prune_output_file="${WS}/himps_prune_output.txt"
himps_full_output_file="${WS}/himps_full_output.txt"
preprocess_output_folder="${WS}/preprocess_output_folder"
mbs_output_file="${WS}/mbs_output_file"

timeit() {
    echo "argv:" "$@"
    local row_name="$key,$1"
    echo -n "$key,$1.size," >>$OUT
    shift
    stime="$(date +%s%N)"
    /usr/bin/time -f "%M" -a -o "$OUT" "$@" # 有的程序自己会返回运行信息。
    time="$(($(date +%s%N) - stime - 0))"
    echo -e "${row_name}.time,$((time / 1000000))" >>"$OUT"
}

sizeit() {
    du --apparent-size -s "$1" | awk '{print $1}'
}

count_p(){
	ruby -e 'data=STDIN.read;puts (data[/scheme="branches".*?<\/sites>/m]||"\n").count("\n").pred*2+(data[/scheme="returns".*?<\/sites>/m]||"\n").count("\n").pred*6+(data[/scheme="scalar-pairs".*?<\/sites>/m]||"\n").count("\n").pred*6+(data[/scheme="method-entries".*?<\/sites>/m]||"\n").count("\n").pred*1' # < 'output.sites'
}


#########################################################################################

method_runtests_boost() {
    local himps_output_file="$1"
    local step_name="$2"
    echo "# profile $himps_boost_output_file"
    includes=$(ruby -e 'puts $<.readlines.map{|e|"-sampler-include-method="+e.chomp.gsub(/->.*$/,"").gsub(/[ ():<>$]/, "-")}*" "' <"$himps_output_file")
    echo "$key,${step_name}.includes,$includes" >>$OUT

    bash profile_v2.sh "${pids[$pid_n]}" "$bid" include $includes # several args, no quote!
    {
        echo -n "$key,${step_name}.profile.number,"
        echo $(($(cat "$root/outputs/nanoxml/versions/v${pid_n}/subv${bid}/include-$(echo $includes | md5sum | awk '{ print $1 }')/output.sites" |count_p) - 0))
        echo -n "$key,${step_name}.profile.time,"
        cat "$root/outputs/nanoxml/outputs.alt/v$pid_n/versions/subv$bid/include-$(echo $includes | md5sum | awk '{ print $1 }')/time4" | sed -ne '2p' | sed -re 's/[^0-9]+//g'
        echo "$key,${step_name}.profile.size,$(sizeit "$root/outputs/nanoxml/traces/v${pid_n}/subv${bid}/include-$(echo $includes | md5sum | awk '{ print $1 }')/")"
    } >>"$OUT"
    method_collect "${step_name}" $includes
}

method_runtests_prune() {
    local step_name="prune"
    echo "# profile $himps_prune_output_file"
    includes=$(ruby -e 'puts $<.readlines.map{|e|"-sampler-include-method="+e.chomp.gsub(/->.*$/,"").gsub(/[ ():<>$]/, "-")}*" "' <"$himps_prune_output_file")

    includes_diff=$(ruby -e 'puts (open(ARGV[0]).readlines-open(ARGV[1]).readlines).map{|e|"-sampler-include-method="+e.chomp.gsub(/->.*$/,"").gsub(/[ ():<>$]/, "-")}*" "' $himps_prune_output_file $himps_boost_output_file)
   # includes_sum=$(ruby -e 'puts (open(ARGV[0]).readlines|open(ARGV[1]).readlines).map{|e|"-sampler-include-method="+e.chomp.gsub(/->.*$/,"").gsub(/[ ():<>$]/, "-")}*" "' $himps_prune_output_file $himps_boost_output_file)

    echo "$key,${step_name}.includes,$includes" >>$OUT

    echo "$key,${step_name}.includes_diff,$includes_diff" >>$OUT
    #echo "$key,${step_name}.includes_sum,$includes_sum" >>$OUT

    test -z "$includes_diff" && return 0

    ddd "prune-minus-boost" $includes_diff

    ddd "prune" $includes
    method_collect "prune" $includes
   mv "$preprocess_output_folder" "${WS}/prune_preprocess_output"
   cp -f "$mbs_output_file" "${WS}/prune_mbs_output.txt"
   rm "$mbs_output_file"

}
ddd() {
    local name=$1
    shift

    bash profile_v2.sh "${pids[$pid_n]}" "$bid" include "$@" # several args, no quote!
    {
        echo -n "$key,${name}.profile.number,"
        echo $(($(cat "$root/outputs/nanoxml/versions/v${pid_n}/subv${bid}/include-$(echo "$@" | md5sum | awk '{ print $1 }')/output.sites" |count_p) - 0))
        echo -n "$key,${name}.profile.time,"
        cat "$root/outputs/nanoxml/outputs.alt/v$pid_n/versions/subv$bid/include-$(echo "$@" | md5sum | awk '{ print $1 }')/time4" | sed -ne '2p' | sed -re 's/[^0-9]+//g'
        echo "$key,${name}.profile.size,$(sizeit "$root/outputs/nanoxml/traces/v${pid_n}/subv${bid}/include-$(echo "$@" | md5sum | awk '{ print $1 }')/")"
    } >>"$OUT"

}


method_collect() {
    echo "preprocess"
    rm -rf "$preprocess_output_folder"
    local name=$1
    shift
    timeit "${name}.preprocess" java -jar tools/preprocess2.jar \
        "$root/outputs/nanoxml/traces/v${pid_n}/subv${bid}/include-$(echo "$@" | md5sum | awk '{ print $1 }')" \
        "$root/outputs/nanoxml/versions/v${pid_n}/subv${bid}/include-$(echo "$@" | md5sum | awk '{ print $1 }')/output.sites" \
        "$preprocess_output_folder" | tee -a "${WS}/log_preprocess.txt"
    echo  "$key,${step_name}.preprocess.number,$(($(cat "$preprocess_output_folder/predicate.mapping" | wc -l) / 5))" >> $OUT
    echo  "$key,${step_name}.preprocess.time_p,$(ruby -e 'print STDIN.read.scan(/preprocessing time = (.+)/)[-1][0].to_f*1000' < "${WS}/log_preprocess.txt")"  >> $OUT
   # exit
    echo "then mbs"
    rm -f "$mbs_output_file"
    timeit "${name}.mine" ./tools/mps/mbs -k "$k" -n 0.5 -g --refine 2 --dfs --merge --cache 9999 --up-limit 2 "$preprocess_output_folder/mps-ds.pb" -o "$mbs_output_file" | tee -a "${WS}/log_mine.txt"
    #cat "$mbs_output_file" | tee -a "${WS}/o1.txt"
    #rm -rf "$preprocess_output_folder"
}

##########################################################################################
step_boost() {
    echo "> step_boost"
    echo "himps"

    java -jar tools/himps2.jar \
        "$root/outputs/nanoxml/versions/v${pid_n}/subv${bid}/coarse-grained/output.sites" \
        "$root/outputs/nanoxml/traces/v${pid_n}/subv${bid}/coarse-grained" \
        "$root/outputs/nanoxml/versions/v${pid_n}/subv${bid}/fine-grained/output.sites" \
        --boost $BOOST \
        "$himps_boost_output_file"
    method_runtests_boost "$himps_boost_output_file" "boost"
    

}

step_prune() {
    echo "prune"
    cat "$mbs_output_file"
    theta=$(ruby -e "xs=STDIN.read.scan(/TOP-\(\d+\) SUP=.+ IG=(.+)$/);puts(xs[ARGV[0].to_i-1]||xs.last)" "$k" <"$mbs_output_file")
    echo "$key,prune.theta,$theta" >>"$OUT" # ,0$(echo "$t-0.001" | bc)
    test -n "$theta"

    java -jar tools/himps2.jar \
        "$root/outputs/nanoxml/versions/v${pid_n}/subv${bid}/coarse-grained/output.sites" \
        "$root/outputs/nanoxml/traces/v${pid_n}/subv${bid}/coarse-grained" \
        "$root/outputs/nanoxml/versions/v${pid_n}/subv${bid}/fine-grained/output.sites" \
        --prune "$theta" \
        "$himps_prune_output_file"
    method_runtests_prune "$himps_prune_output_file" "prune"
}

### 主函数
main() {
    ## boost
    step_boost
    mv "$preprocess_output_folder" "${WS}/boost_preprocess_output"
    cp -f "$mbs_output_file" "${WS}/boost_mbs_output.txt"
    ## prune
    step_prune
    # mv "$preprocess_output_folder" "${WS}/prune_preprocess_output"
    # cp -f "$mbs_output_file" "${WS}/prune_mbs_output.txt"
    # rm "$mbs_output_file"
}

##### 用于对比的数据
setup_full() {
    # 会跳过？
    if [ $pid_n -ne 7 ]; then
        bash profile_v2.sh "${pids[$pid_n]}" "$bid" "coarse-grained" # "again"
        test -e "$root/outputs/nanoxml/outputs.alt/v$pid_n/versions/subv$bid/coarse-grained/time4" || {
            echo "where time4?"
            bash profile_v2.sh "${pids[$pid_n]}" "$bid" "coarse-grained" "again"
            # exit
        }
        bash profile_v2.sh "${pids[$pid_n]}" "$bid" "fine-grained" # "again"
        test -e "$root/outputs/nanoxml/outputs.alt/v$pid_n/versions/subv$bid/fine-grained/time4" || {
            echo "where time4?"
            bash profile_v2.sh "${pids[$pid_n]}" "$bid" "fine-grained" "again"
            # exit
        }
    fi
    bash profile_v2.sh "${pids[$pid_n]}" "$bid" "outputs" # "again"

    {
        #siena
        echo -n "$key,raw.profile.time,"
        cat "$root/outputs/nanoxml/outputs.alt/v$pid_n/versions/subv$bid/outputs/time4" | sed -ne '2p' | sed -re 's/[^0-9]+//g'
        echo -n "$key,coarse-grained.profile.time,"
        cat "$root/outputs/nanoxml/outputs.alt/v$pid_n/versions/subv$bid/coarse-grained/time4" | sed -ne '2p' | sed -re 's/[^0-9]+//g'
        echo "$key,coarse-grained.profile.number,$(($(cat "$root/outputs/nanoxml/versions/v${pid_n}/subv${bid}/coarse-grained/output.sites" | count_p ) - 0))"
        echo "$key,coarse-grained.profile.size,$(sizeit "$root/outputs/nanoxml/traces/v${pid_n}/subv${bid}/coarse-grained/")"

        echo -n "$key,fine-grained.profile.time,"
        cat "$root/outputs/nanoxml/outputs.alt/v$pid_n/versions/subv$bid/fine-grained/time4" | sed -ne '2p' | sed -re 's/[^0-9]+//g'
        # echo -n "$key,fine-grained,size,"
        echo "$key,fine-grained.profile.size,$(sizeit "$root/outputs/nanoxml/traces/v${pid_n}/subv${bid}/fine-grained/")"
        echo "$key,fine-grained.profile.number,$(($(cat "$root/outputs/nanoxml/versions/v${pid_n}/subv${bid}/fine-grained/output.sites" | count_p) - 0))"
    } >>"$OUT"
    method_full
}

method_full() {
    local himps_boost_output_file="$himps_full_output_file"
    local step_name="fine-grained"

    echo "preprocess"
    rm -rf "$preprocess_output_folder"
    timeit "fine-grained.preprocess" java -jar tools/preprocess2.jar \
        "$root/outputs/nanoxml/traces/v${pid_n}/subv${bid}/fine-grained" \
        "$root/outputs/nanoxml/versions/v${pid_n}/subv${bid}/fine-grained/output.sites" \
        "$preprocess_output_folder" | tee -a "${WS}/log_preprocess.txt"
    #cat "$preprocess_output_folder/predicate.mapping"
    #exit
    echo  "$key,${step_name}.preprocess.number,$(($(cat "$preprocess_output_folder/predicate.mapping" | wc -l) / 5))"  >> $OUT
    echo  "$key,${step_name}.preprocess.time_p,$(ruby -e 'print STDIN.read.scan(/preprocessing time = (.+)/)[-1][0].to_f*1000' < "${WS}/log_preprocess.txt")"  >> $OUT
    
    #echo "eixit"
    #exit
    test -s "$preprocess_output_folder/predicate.mapping" || {
        echo 1
        echo "# fail for being empty" >>$OUT
        exit 1
    }
    echo "then mbs"
    rm -f "$mbs_output_file"
    timeit "fine-grained.mine" ./tools/mps/mbs -k "$k" -n 0.5 -g --refine 2 --dfs --merge --cache 9999 --up-limit 2 "$preprocess_output_folder/mps-ds.pb" -o "$mbs_output_file" | tee -a "${WS}/log_mine.txt"
    #cat "$mbs_output_file" | tee -a "${WS}/log_mbs.txt"
    mv "$preprocess_output_folder" "${WS}/full_preprocess_output"
    #rm -rf "$preprocess_output_folder"
}

mkdir -p "outputs/exp1"
setup_full
main
echo "$key,end" >>$OUT
#ruby check_results.rb
#rm -rf "${WS:?}"
mv -f "$OUT" "outputs/exp1/"
