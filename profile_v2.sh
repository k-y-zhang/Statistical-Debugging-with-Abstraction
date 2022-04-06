#!/bin/bash --verbose
# profile.sh Lang 2 check

root=$PWD
export JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
trap 'echo "ERROR: $BASH_SOURCE:$LINENO $BASH_COMMAND" >&2' ERR

#set -v
#set -e # 错误发生时立即退出

#   _   _  ____ _______ _____ _____ ______
#  | \ | |/ __ \__   __|_   _/ ____|  ____|
#  |  \| | |  | | | |    | || |    | |__
#  | . ` | |  | | | |    | || |    |  __|
#  | |\  | |__| | | |   _| || |____| |____
#  |_| \_|\____/  |_|  |_____\_____|______|

# 关于脚本的说明
#
# defects4j 中不同的项目由不同的结构
# - 不同的项目目录结构的差异
# - 构建工具 maven 和 ant
# - 版本管理 git 和 svn
# - JUnit3 和 JUnit 4 的语法差异
# - Java 版本差异，比如 Java 1.4 不支持范型，Java 1.7 和 1.8 有执行结果差异
# - mockito 是测试用的
#
# 解决思路
# - defect4j 数据集在不断扩充，且版本多，不想把条件写死
#
# 解决办法
# - defect4j 提供一些元信息
# - 脚本对不同情况这些都有判断

# 软件版本
# - JSampler 中依赖的 Soot 版本是 Java 1.7，升级 Soot 会有不兼容的地方，所以暂时限定 Java 1.7 跑。
# - Defect4j 的 1.5 依赖 Java 7，2.0 依赖 Java 8

# docker 使用 java7 的镜像
# - docker run -it --rm  -v "$PWD:$PWD" -w "$PWD" dockerbase/java7
# - 先用 screen 保持后台执行

# 安装依赖的包
# - sudo apt update
# - sudo apt install -y subversion cpanminus git build-essential patch ruby unzip

# 下载 defects4j
# - git clone
# - cd defects4j
# - git checkout v1.5.0
# - ./init.sh
# - cpanm --installdeps .

# 上传修改到服务器
# - rsync -vrp /media/sf_OneDrive/_我的笔记/回收/SE/zuo/ zhangsy@210.28.135.32:/home/zhangsy/2021C/

# 关于 Shell 脚本
# - 多写一点检查断言可以帮助正确性
# - 记录执行日志

# 关于论文与实验
# - 项目名词硬编码在分析程序里了，不同项目会有格式差异。
# - RQ 1 和 RQ 2 比较插桩数
# - RQ 3 收集执行时间
#
# TODO
# - JUnit 版本检测现在还是有点 Bug。

# 其他
# docker run -it --name nostalgic_borg  -v $PWD:$PWD -w $PWD dockerbase/java7
#docker start nostalgic_borg && docker exec -it  nostalgic_borg bash -c "cd $PWD;bash"

#docker exec -it nostalgic_borg sudo chmod +666 -R .
#docker exec -it  nostalgic_borg bash -c "cd $PWD;bash"
#java -jar /home/user/Desktop/tmp/bin/HI.jar "/home/user/Desktop/lab4/" nanoxml /home/user/Desktop/lab4/out/

#exit

#       _             _
#      | |           | |
#   ___| |_ __ _ _ __| |_
#  / __| __/ _` | '__| __|
#  \__ \ || (_| | |  | |_
#  |___/\__\__,_|_|   \__|

# 脚本开始

export LANG=C
clear
echo "starting..."
ARGV="profile,$*,finished"
ARGV="${ARGV/ -3/}"
# 处理输入参数
pid=$1
shift
bid=$1
shift
mth=$1
shift || echo
RQ=$1

[ -z "$pid" ] && pid=Lang
[ -z "$bid" ] && bid=2
[ -z "$mth" ] && mth="coarse-grained"
[ -z "${RQ}" ] && RQ=""
#test
#echo "> ($RQ)"
[[ -z "$RQ" || "$RQ" = "-3" || "$RQ" = "again" || "$mth" = "include" || "$mth" = "include3" ]] || {
    echo "fail> $RQ."
    exit

}
if [ "${mth}" = "include3" ]; then
    echo "include2>$*\n$(echo "$@" | md5sum | awk '{ print $1 }')"
fi
echo "ARGV=\"$ARGV\""
#fgrep  "$ARGV" "$root/outputs/logs2.txt"
if fgrep -q "$ARGV" "$root/outputs/logs2.txt" && [ ! "$mth" = "check1" ] && [ ! "$RQ" = "again" ] ; then
    echo "skip finished0 $ARGV"
    exit 0
fi
# if fgrep -q "$ARGV" "$root/outputs/logs_mutex.txt" && [ ! "$mth" = "check1" ]; then
#     echo "skip finished1 $ARGV"
#     #exit 0
# fi
# echo "$ARGV" >>"$root/outputs/logs_mutex.txt"

# if grep -q "${pid}-${bid}:${mth}${RQ}$" "$root/outputs/log.txt" && [ ! $mth = "include" ] && [ ! "$RQ" = "again" ] && [ ! "$mth" = "check1" ]; then
#     echo "skip finished $*"
    
#     exit 0
# fi

case $pid in
Lang) pid_n=1 ;;
Chart) pid_n=2 ;;
Math) pid_n=3 ;;
Time) pid_n=4 ;;
Mockito) pid_n=5 ;;
Closure) pid_n=6 ;;
*)
    echo "$pid not found"
    exit 1
    ;;
esac

coarse_grained="$mth"
echo ${coarse_grained}
sample_method=("-sampler-scheme=method-entries")

if test "${coarse_grained}" = "coarse-grained"; then
    sample_method=("-sampler-scheme=method-entries")
elif [ "${coarse_grained}" = "fine-grained" ]; then
    sample_method=("-sampler-scheme=branches" "-sampler-scheme=returns" "-sampler-scheme=scalar-pairs")
elif [ "${coarse_grained}" = "fine-grained-adaptive" ]; then
    echo "not impl"
    exit 0
elif [ "${coarse_grained}" = "fine-grained-sampled-1" ]; then
    sample_method=("-sampler" "-sampler-scheme=branches" "-sampler-scheme=returns" "-sampler-scheme=scalar-pairs")
    export SAMPLER_SPARSITY=1
elif [ "${coarse_grained}" = "fine-grained-sampled-100" ]; then
    sample_method=("-sampler" "-sampler-scheme=branches" "-sampler-scheme=returns" "-sampler-scheme=scalar-pairs")
    export SAMPLER_SPARSITY=100
elif [ "${coarse_grained}" = "fine-grained-sampled-10000" ]; then
    sample_method=("-sampler" "-sampler-scheme=branches" "-sampler-scheme=returns" "-sampler-scheme=scalar-pairs")
    export SAMPLER_SPARSITY=10000
elif [ "${coarse_grained}" = "outputs" ]; then
    echo
elif [ "${coarse_grained}" = "include" ]; then
    sample_method=("-sampler-scheme=branches" "-sampler-scheme=returns" "-sampler-scheme=scalar-pairs" "$@")
    [ $# -gt 0 ] || exit 1
    coarse_grained="include-$(echo "$@" | md5sum | awk '{ print $1 }')"
    mth="include-$(echo "$@" | md5sum | awk '{ print $1 }')"
    # -sampler-include-method=-org.apache.tools.ant.AntTypeDefinition--java.lang.Object-createAndSet-org.apache.tools.ant.Project,java.lang.Class--
elif [ "${coarse_grained}" = "include3" ]; then
    sample_method=("-sampler-scheme=branches" "-sampler-scheme=returns" "-sampler-scheme=scalar-pairs" "$@")
    [ $# -gt 0 ] || exit 1
    RQ="-3"
    coarse_grained="include-$(echo "$@" | md5sum | awk '{ print $1 }')"
    mth="include-$(echo "$@" | md5sum | awk '{ print $1 }')"
elif [ "${coarse_grained}" = "check" ]; then
    echo
else
    echo "not support ${coarse_grained}"
    exit 1
fi
ver="v${pid_n}/subv$bid"
echo "${sample_method[@]}"
echo $ver
#exit
#root=/home/user/Desktop/lab4
root=$PWD
defects4j_PATH="$PWD/defects4j/"
export PATH=$PATH:$PWD/defects4j/framework/bin/
echo $PATH
#chmod +x $PWD/defects4j/framework/bin/defects4j
#./$PWD/defects4j/framework/bin/defects4j
#defects4j || exit 1
#sleep 10
# sed -i /$project->compile_tests()/

#exit
out="$root/outputs/nanoxml"
dir="$root/outputs/tmp/${pid}-${bid}/${mth}"
#rm -rf $dir
#mkdir "$dir" -p
mkdir "$out" -p
mkdir -p log
#cd "$dir" || exit 1

#    _____ _______ ______ _____     ___
#   / ____|__   __|  ____|  __ \   / _ \
#  | (___    | |  | |__  | |__) | | | | |
#   \___ \   | |  |  __| |  ___/  | | | |
#   ____) |  | |  | |____| |      | |_| |
#  |_____/   |_|  |______|_|       \___/

# 一些辅助函数
JSampler_CLASSPATH=$root/tools/JSampler.jar
#    _____ _______ ______ _____    _____
#   / ____|__   __|  ____|  __ \  |_   _|
#  | (___    | |  | |__  | |__) |   | |
#   \___ \   | |  |  __| |  ___/    | |
#   ____) |  | |  | |____| |       _| |_
#  |_____/   |_|  |______|_|      |_____|

# 插桩

step_i() {
    rm -rf "$dir"
    mkdir "$dir" -p
    cd "$dir" || exit 1
    echo "dir>'$dir'"
    defects4j checkout -p "$pid" -v "${bid}b" -w "$dir" || exit 1
    src_main_java=$(defects4j export -p dir.src.classes)  #Source directory of classes (relative to working directory)
    target_classes=$(defects4j export -p dir.bin.classes) #Target directory of classes (relative to working directory)
    src_test_java=$(defects4j export -p dir.src.tests)    #Source directory of tests (relative to working directory)
    target_tests=$(defects4j export -p dir.bin.tests)     #Target directory of test classes (relative to working directory)
    CP="$dir/${target_classes}/:$(defects4j export -p cp.compile):$(defects4j export -p cp.test):$defects4j_PATH/framework/projects/$pid/lib/*:$(echo $defects4j_PATH/framework/projects/$pid/lib/*.jar | tr ' ' ':')"
    #CP="$dir/${target_classes}/:$(defects4j export -p cp.compile):$(defects4j export -p cp.test)"
    
    #cppp=$(defects4j export -p cp.compile)

    #exit
    echo "- - - -"
    defects4j export -p tests.relevant
    echo "- - - -"
    defects4j export -p tests.trigger
    echo "- - - -"
    #exit # org_apache_commons_lang3_time_FastDateFormat_PrinterTest_testCalendarTimezoneRespected

    #
    defects4j export -p dir.src.classes
    echo "> $src_main_java"
    [ -z "$src_main_java" ] && {
        echo "fail> src_main_java $src_main_java"
        exit 1
    }
    echo ">"
    #defects4j test
    #exit
    mkdir -p "$dir/${src_main_java}"
    cat >"$dir/${src_main_java}/AtExit.java" <<EOF
public class AtExit {
  public static void main(String[] args) { 
  }
}
EOF
    test -a $dir/${src_main_java}/AtExit.java || {
        echo "fail> AtExit"
        exit 1
    }
    #echo "test files> $(find "$dir/${src_test_java}/" -name '*Test*.java' | wc -l)"
    # [ "$(find "$dir/${src_test_java}/" -name '*Test.java' -or -name '*Tests.java' | wc -l)" = 0 ] && {
    #     echo "$dir/${src_test_java}/"
    #     echo "fail"
    #     exit
    # }
    #exit

    #exit
    rm -rf $dir/target/
    rm -rf "$target_classes"
    defects4j compile || exit 1
    test -a "$dir/${target_classes}/AtExit.class" || {
        # echo "fail> AtExit $dir/${target_classes}/AtExit.class"
        javac "$dir/${src_main_java}/AtExit.java"
        cp "$dir/${src_main_java}/AtExit.class" "$dir/${target_classes}/AtExit.class"
        #exit 1
    }
    #find "$target_tests"
    #defects4j compile || exit 1
    #exit
    #JSampler_CLASSPATH=/home/user/Desktop/tmp/bin/JSampler.jar
    echo ""

    if [ "${coarse_grained}" = "outputs" ]; then
        echo "no sample"
        defects4j compile || exit 1
        unzip -n "${JSampler_CLASSPATH}" "edu/*" -d "$dir/${target_classes}/" || exit 2
        return
    elif [ "${coarse_grained}" = "check" ]; then
        echo "just check"
        # sloccount 不支持并发重入
        echo "$pid,$bid,$(sloccount --duplicates "$dir/${src_main_java}/" | grep -F 'java: ')" >>"$out/projects.txt"
        exit
        defects4j compile || exit 1
        return
    fi
    echo "sample/soot ${sample_method[*]}"
    #read
    #echo "cp.compile> $(defects4j export -p cp.compile)"
    mkdir -p "$out/versions/$ver/${coarse_grained}/"
    rm -f "$out/versions/$ver/${coarse_grained}/output.sites"
    #find "$target_tests"

    
    #cp -rf "$target_tests" "${target_tests}2" 
    java -ea -cp "${JSampler_CLASSPATH}" edu.uci.jsampler.client.JSampler -validate \
        "${sample_method[@]}" \
        -cp "$CP" \
        -pp \
        -process-dir "$dir/${target_classes}/" \
        -sampler-out-sites="$out/versions/$ver/${coarse_grained}/output.sites" \
        -d "$dir/${target_classes}2/" || exit 1
    echo "> $(cat "$out/versions/$ver/${coarse_grained}/output.sites" | wc -l)"
    #echo "$target_tests"
    #find "$target_tests"

    [ -e "$out/versions/$ver/${coarse_grained}/output.sites" ] || exit 1
    rm -f $dir/${target_classes}2/*.jimple
    rm -rf "$dir/${target_classes:?}/"
    #mkdir -p "$dir/${target_classes:?}/"
    mv "$dir/${target_classes}2/" "$dir/${target_classes}/" || exit 1
    cp -rf "$dir/${target_classes}/" "$dir/${target_classes}3/"
    #cp -rf -v "$dir/${target_classes}2/" "$dir/${target_classes}/" || exit 1
    # rm -rf "$dir/${target_classes}2/" 
    #cp -rf /home/user/Desktop/tmp/bin/edu/* $dir/${target_classes}/edu/
    unzip -n "${JSampler_CLASSPATH}" "edu/*" -d "$dir/${target_classes}/" || exit 2
    #sudo chmod +666 -R .
    echo "ok1"
    #sleep 10
    # rm -rf "$src_main_java"
    [ `find "$target_tests" | wc -l` -gt 1 ] || { echo "ERROR>target_tests" ; exit 1 ; }
}

#exit
# defects4j export -p tests.relevant

#    _____ _______ ______ _____    _____ _____
#   / ____|__   __|  ____|  __ \  |_   _|_   _|
#  | (___    | |  | |__  | |__) |   | |   | |
#   \___ \   | |  |  __| |  ___/    | |   | |
#   ____) |  | |  | |____| |       _| |_ _| |_
#  |_____/   |_|  |______|_|      |_____|_____|

# 执行测试用例

step_ii() {
    cd "$dir" || exit 1
    #cp -rf /home/user/Desktop/tmp/bin/edu/* $dir/${target_classes}/edu/
    export CLASSPATH=$root/tools/JSampler.jar
    #unzip -n "$root/JSampler.jar" "edu/*" -d "$dir/${target_classes}/"
    export VERSIONSDIR=$out/versions/$ver/${coarse_grained}/
    export TRACESDIR=$out/traces/$ver/${coarse_grained}/
    rm -rf "$TRACESDIR"
    mkdir -p "$TRACESDIR"
    mkdir -p "$VERSIONSDIR"
    #unzip -n "${JSampler_CLASSPATH}" "edu/*" -d "$dir/${target_classes}/" || exit 2
    # export SAMPLER_FILE=$TRACESDIR/o1.fprofile
    # sudo chmod +666 -R .
    # defects4j test -t org.apache.commons.lang3.tuple.NumberUtilsTest::TestLang747 # -w /home/user/Desktop/tmp/out/lang_1_buggy/
    # cat failing_tests
    # cat $SAMPLER_FILE
    #exit
    #test -a $TRACESDIR/o1.fprofile || exit 1
    #rm $TRACESDIR/o1.fprofile || exit 1
    #count=$(find_tests | sed -re 's/^/> /' | wc -l)
    # while read -r test; do
    #     echo "try test> ${test}"
    #     name=$(echo "$test" | sed -re 's/[\.:]+/_/g')
    #     echo "try name> $name"
    #     export SAMPLER_FILE=$TRACESDIR/$name.pprofile
    #     defects4j test -t "$test"
    #     echo defects4j test -t "$test"
    #     if [ ${coarse_grained} = "outputs" ]; then
    #         echo "count> $((count--))"
    #         continue
    #     fi
    #     test -a "$SAMPLER_FILE" || {
    #         cat failing_tests # || echo "$pid $bid failing_tests">log_err.txt
    #         echo "fail, sample not found"
    #         echo "$(echo "$dir/$(defects4j export -p dir.src.tests)/$test" | sed 's/\./\//g;s/::.*$//').java"
    #         echo "$pid $bid $test not found" >>"$root/log_err.txt"
    #         # ruby -e '' $test
    #         exit 1
    #     }
    #     echo "count> $((count--))"
    # done < <(find_tests | sort -r)
    export SAMPLER_FILE=$TRACESDIR/
    #mkdir -p "/home/zhangsy/2021C/outputs/tmp/Mockito-11/coarse-grained/build/classes/main3"
    #cp -rf "/home/zhangsy/2021C/outputs/tmp/Mockito-11/coarse-grained/build/classes/main/" "/home/zhangsy/2021C/outputs/tmp/Mockito-11/coarse-grained/build/classes/main3/"
    sed -i -e 's/depends="compile.test, pmd"/depends="pmd"/' build.xml
    #sed -i -r -e 's/<target name="([^"]+?)" (.+?)>/<target name="\1" \2><echo message="\1..." \/>/g' build.xml
    stime="$(date +%s%N)"
    case $pid in
Math|Clo*)
    test_results=$(defects4j test -r) #run tests!!
    ;;
*)test_results=$(defects4j test) 
;;
    esac
    #step_ii
    time="$(($(date +%s%N) - stime - 0))"
    mkdir -p "$out/outputs.alt/v$pid_n/versions/subv$bid/$outputs/"
    echo -e "Time in seconds: $((time / 1000000000)) \nTime in milliseconds: $((time / 1000000))" > "$out/outputs.alt/v$pid_n/versions/subv$bid/$outputs/time1" 2>&1
    cp -f 'test.time.txt' "$out/outputs.alt/v$pid_n/versions/subv$bid/$outputs/time2"
    time=`ruby -rtime -e 'a,b=open("test.time.txt").readline.split(",").map{|e|Time.parse(e)};print(((b-a)*1000*1000000).to_i)'`
    echo -e "Time in seconds: $((time / 1000000000)) \nTime in milliseconds: $((time / 1000000))" > "$out/outputs.alt/v$pid_n/versions/subv$bid/$outputs/time3" 2>&1
    time=`ruby -e 'print open("all_tests").read.scan(/^time>(\d+)$/).map{|e|e[0].to_i}.reduce(:+)'`
    cp -f all_tests "$out/outputs.alt/v$pid_n/versions/subv$bid/$outputs/all_tests"
    echo -e "Time in seconds: $((time / 1000000000)) \nTime in milliseconds: $((time / 1000000))" >> "$out/outputs.alt/v$pid_n/versions/subv$bid/$outputs/time4" 2>&1
    
    echo "time> $time"
    #defects4j test
    echo "=1="
    echo "$test_results"
    echo "=2="
    #defects4j export -p tests.trigger
    #failnum0=$(grep -ch "^" < <(defects4j export -p tests.trigger)) # no wc
    failnum0=$(defects4j export -p tests.trigger| grep -v 'pure_mockito_should_not_depend_JUnit' )
    echo "$failnum0"
    #echo "$failnum0" | wc -l
    #defects4j export -p tests.trigger | wc -l
    echo "=3="
    cat failing_tests
    echo "=4="
    #echo "$test_results" | grep -F '  - ' | sed --re 's/^  - //'
    failnum1=$(echo "$test_results" | grep -F '  - ' | grep -v 'pure_mockito_should_not_depend_JUnit' | sed -re 's/^  - //')
    echo "$failnum1"
    echo "=5="
    if [ ! "$failnum0" = "$failnum1" ]; then
        echo "[$failnum0]" != "[$failnum1]"
        echo "$pid,$bid,no,$failnum0!=$failnum1" >>"$out/projects.txt"
        echo "profile fail!!"
        exit 1 ## 严格模式应该退出！
    else
        echo "$failnum0 == $failnum1"
        echo "$pid,$bid,yes,$failnum0" >>"$out/projects.txt"
        #echo "$pid,$bid,yes,$failnum0"
    fi
    if [ "${coarse_grained}" = "outputs" ] || [ "${coarse_grained}" = "check" ]; then
        echo "break ${coarse_grained}"
        return
    fi
    # if [ "${coarse_grained}" = "outputs" ]; then
    #     echo "no sample"
    #     defects4j compile || exit 1
    #     return
    # elif [ "${coarse_grained}" = "check" ] || [ "${coarse_grained}" = "outputs" ] ; then
    #     echo "just check"
    #     echo "$pid,$bid,$(sloccount --duplicates "$dir/${src_main_java}/" | grep -F 'java: ')" >>"$out/projects.txt"
    #     return
    # fi

    find "$TRACESDIR" -exec mv {} {}.pprofile \; || exit 1
    # find $TRACESDIR
    local failnum=0
    echo -n "$failnum0"
    echo 'fail case'
    #rm -f '$TRACESDIR/line.pprofile' # mock 5
    while read -r line; do
        echo "fail case : $line"
        mv "$TRACESDIR/${line}.pprofile" "$TRACESDIR/${line}.fprofile" && failnum=$((failnum + 1)) || exit 1
    done < <(echo "$failnum0" | sed -re 's/^\s*(.+)::(.+)/\2(\1)/')
    # <(echo "$test_results" | grep -F '  - ' | sed -re 's/^\s*-\s*(.+)::(.+)/\2(\1)/')
    #echo "$test_results"
    #echo "$test_results" | grep -F '  - '
    echo "$failnum"
    #exit
    # local failnum=0
    # for fail in $(defects4j export -p tests.trigger | sed -re 's/[\.:]+/_/g'); do
    #     echo "mv fail test"
    #     echo "$fail"
    #     mv "$TRACESDIR/$fail.pprofile" "$TRACESDIR/$fail.fprofile" && failnum=$((failnum + 1))
    #     # || exit 1
    # done
    # [ $failnum = 0 ] && [ $mth != outputs ] && {
    #     echo "failnum>$failnum"
    #     exit 1
    # }
    # echo "failnum>$failnum"
    local i=1
    #mkdir -p "$TRACESDIR_2"
    #cp -rf "$TRACESDIR" "{$TRACESDIR}_2" 
    #read
    for file in $(find "$TRACESDIR" -name "*.*profile" | sort); do
        # echo "$i"
        to=$(echo "${file}" | sed -re "s/[^/]+(\..profile)/o$((i))\1/")
        echo "rename $file -> $to"
        mv "$file" "$to"
        _=$((i++))

    done
    #exit
}

#    _____ _______ ______ _____    _____ _____ _____
#   / ____|__   __|  ____|  __ \  |_   _|_   _|_   _|
#  | (___    | |  | |__  | |__) |   | |   | |   | |
#   \___ \   | |  |  __| |  ___/    | |   | |   | |
#   ____) |  | |  | |____| |       _| |_ _| |_ _| |_
#  |_____/   |_|  |______|_|      |_____|_____|_____|

# 收集执行时间

step_iii() {
    cd "$dir" || exit 1
    # case "${coarse_grained}"
    # "none")outputs=outputs
    # ""
    # *)exit
    # esac

    export SAMPLER_FILE=$(mktemp -d)
    defects4j test -r
    defects4j test -r
    defects4j test -r
    rm -rf "$SAMPLER_FILE"
}

#

#
# if [ "${coarse_grained}" = "include" ]; then
#     outputs="include"
# else
#     outputs="${coarse_grained}"
# fi
outputs="${coarse_grained}"
if [ "$RQ" = "--3" ]; then
    # if [ -a  "$dir" ] ; then
    step_i
    # fi
    step_ii # 一次不算时间
    stime="$(date +%s%N)"
    step_iii # 三次算时间
    time="$(($(date +%s%N) - stime - 0))"
    mkdir -p "$out/outputs.alt/v$pid_n/versions/subv$bid/$outputs/"
    echo -e "Time in seconds: $((time / 1000000000)) \nTime in milliseconds: $((time / 1000000))" >"$out/outputs.alt/v$pid_n/versions/subv$bid/$outputs/time" 2>&1
    echo "time> $time" "$out/outputs.alt/v$pid_n/versions/subv$bid/$outputs/time"
else

    step_i
    step_ii

fi

echo "task ${pid}-${bid}/${mth}${RQ} finished!"
echo "finished> ${pid}-${bid}:${mth}${RQ}" >>"$root/outputs/log.txt"
echo "$ARGV" >>"$root/outputs/logs2.txt"
# if [ "$RQ" != "-3" ]; then
#    echo -e "Time in seconds: $((time / 1000000000)) \nTime in milliseconds: $((time / 1000000))" >"$out/outputs.alt/v$pid_n/versions/subv$bid/$outputs/time0" 2>&1
# else
#    echo "time> $out/outputs.alt/v$pid_n/versions/subv$bid/$outputs/time"
# fi

#java -jar /home/user/Desktop/tmp/bin/HI.jar "$out/.." nanoxml /home/user/Desktop/lab4/out/


# rm -rf "$dir"
# rm -rf $root/outputs/nanoxml/traces/
#rm -rf "$dir/.git"