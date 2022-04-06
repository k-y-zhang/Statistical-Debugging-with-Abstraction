#!/bin/bash --verbose
root=$PWD
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

# 处理输入参数
pid=$1
shift
bid=$1
shift
mth=$1
shift
RQ=$1

[ -z "$pid" ] && pid=Lang
[ -z "$bid" ] && bid=2
[ -z "$mth" ] && mth="coarse-grained"
[ -z "${RQ}" ] && RQ=""
#test
#echo "> ($RQ)"
[[ -z "$RQ" || "$RQ" = "-3" || "$mth" = "include" ]] || {
    echo "fail> $RQ."
    exit

}

if grep -q "${pid}-${bid}:${mth}${RQ}$" "$root/log.txt" && [ ! $mth = "include" ]; then
    echo "skip finished $*"
    exit 0
fi

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
    # -sampler-include-method=-org.apache.tools.ant.AntTypeDefinition--java.lang.Object-createAndSet-org.apache.tools.ant.Project,java.lang.Class--
else
    echo ${coarse_grained}
    exit 1
fi
ver="v${pid_n}/subv$bid"
echo "${sample_method[@]}"
echo $ver
#exit
root=/home/user/Desktop/lab4
root=$PWD
export PATH=$PATH:$PWD/defects4j/framework/bin/
# sed -i /$project->compile_tests()/

#exit
out=$root/nanoxml
dir=$root/tmp/${pid}-${bid}/${mth}
#rm -rf $dir
mkdir "$dir" -p
mkdir "$out" -p
mkdir -p log
cd "$dir" || exit 1

#    _____ _______ ______ _____     ___
#   / ____|__   __|  ____|  __ \   / _ \
#  | (___    | |  | |__  | |__) | | | | |
#   \___ \   | |  |  __| |  ___/  | | | |
#   ____) |  | |  | |____| |      | |_| |
#  |_____/   |_|  |______|_|       \___/

# 一些辅助函数
# 查找所有单元测试
# 注意是否有遗漏？
find_tests() {
    #S='puts File.read(ARGV[0].gsub(/\./,"/")+".java").scan(/(@\w+.*\n)?\s*@Test(@\w+.*\n)?\s*(\s|\n|\r|public|void)+([_\w]+?)\(\).*?{/im).map{|e|e[4]}'
    S=$(
        cat <<-'EOF'
file=ARGV[0].gsub(/\./,"/")+".java"
data=File.read(file)
data.gsub!(/^\s*\/\/.*$/,'')
if data=~/@Test/
#warn data.scan(/(@\w+[^\n]*?)?\s*@Test(@\w+[^\n]*?)?\s*(\s|\n|\r|public|void)+([_\w]+?)\(\).*?{/im).map{|e|e}

    puts data.scan(/(@\w+[^\n]*?)?\s*@Test\b[^@]*?(@\w+[^\n]*?)?\s*(\s|\n|\r|public|void)+([_\w]+?)\(\).*?{/im).map{|e|
    # warn [*e,e.any?{|x|x=~/@Ignore/}]
    if e.any?{|x|x=~/@Ignore/} then nil
    else    e[3] end
    }.compact
else
    puts data.scan(/\b (test[_\w]+?)\(\).*?{/im).map{|e|e[0]}
end
EOF
    )
    src_test_java=$(defects4j export -p dir.src.tests)
    for class in $(defects4j export -p tests.relevant | grep -F -v '$'); do
        echo class $class 1>&2
        local i=0
        for method in $(ruby -e "$S" "$dir/${src_test_java}/$class"); do
            echo "$class::$method"
            i=$((i + 1))
        done
        # [ $i = 0 ] && {
        #     echo ">>> $i"
        #     exit 1
        # }
    done
}

#find_tests
#exit
# test "$(find_tests | wc -l)" -gt 0 || {
#     echo "fail> no tests"
#     exit 1
# }
# echo "$PWD"
#exit
#defects4j export -p tests.trigger || exit 1 # | sed -re 's/[\.:]+/_/g'
#exit
#sudo chmod +666 -R .

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

    defects4j checkout -p "$pid" -v "${bid}b" -w "$dir" || exit 1
    find_tests
    test "$(find_tests | wc -l)" -gt 0 || {
        echo "fail> no tests"
        exit 1
    }
    src_main_java=$(defects4j export -p dir.src.classes)  #Source directory of classes (relative to working directory)
    target_classes=$(defects4j export -p dir.bin.classes) #Target directory of classes (relative to working directory)
    src_test_java=$(defects4j export -p dir.src.tests)    #Source directory of tests (relative to working directory)
    target_tests=$(defects4j export -p dir.bin.tests)     #Target directory of test classes (relative to working directory)
    cppp=$(defects4j export -p cp.compile)
    #exit
    echo "--"
    defects4j export -p tests.relevant
    echo "--"
    find_tests # | sort
    echo "--"
    defects4j export -p tests.trigger
    echo "--"
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
    [ "$(find "$dir/${src_test_java}/" -name '*Test.java' -or -name '*Tests.java' | wc -l)" = 0 ] && {
        echo "$dir/${src_test_java}/"
        echo "fail"
        exit
    }
    #exit
    S=$(
        cat <<-'EOF'
name = ARGV[0]
#junit = ARGV[1]
data = File.read(name)
if data=~/junit\.framework\.TestCase/ #junit=='3'
    puts ">junit3 #{name}"
    if data=~/tearDown\(\)/
        data.sub!(/tearDown\(\).*?{/,'\0Class.forName("AtExit").getMethod("main", new Class[]{ String[].class }).invoke((Object)null,new Object[]{new String[0]});')
    else
        data.sub!(/\{\s*$/,'{public void tearDown() throws Exception{Class.forName("AtExit").getMethod("main", new Class[]{ String[].class }).invoke((Object)null,new Object[]{new String[0]});}')
    end
elsif data=~/@Test/ #junit=='4'
    puts ">junit4 #{name}"
    data.sub!(/^(package.*)$/,"\\1\nimport org.junit.After;\n")
    data.sub!(/\{\s*$/,"{\n        @After\npublic void tearDownAfterTest() throws Exception{\nClass.forName(\"AtExit\").getMethod(\"main\",String[].class).invoke(null,(Object) new String[] {});\n}\n")
else
    #fail junit.to_s
    puts ">uknow #{name}"
end
File.write(name,data)
puts "write #{name}."
# Dir["#{ARGV[0]}/**/*.java"]
EOF
    )
    echo ">src> $dir/${src_test_java}/"
    #grep -F '@Test' "$dir/${src_test_java}/" -R
    # if grep -q -F '@Test' "$dir/${src_test_java}/" -R; then
    #     junit=4
    # else
    #     junit=3
    # fi
    # echo ">junit> $junit"
    #exit
    for file in $(find "$dir/${src_test_java}/" -name '*Test.java' -or -name '*Tests.java'); do
        echo "find test file>" "$file"
        ruby -e "$S" "$file" || exit 1
        grep -q -F 'tearDown' "$file" || {
            cat "$file"
            echo "fail> file $file"
            # exit 1
        }
    done
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
    #exit
    #JSampler_CLASSPATH=/home/user/Desktop/tmp/bin/JSampler.jar
    if [ "${coarse_grained}" = "outputs" ]; then
        echo "no sample"
        return
    fi
    echo ""
    JSampler_CLASSPATH=$root/tools/JSampler.jar
    echo "sample/soot ${sample_method[*]}"
    echo "cp.compile> $(defects4j export -p cp.compile)"
    mkdir -p "$out/versions/$ver/${coarse_grained}/"
    java -ea -cp "${JSampler_CLASSPATH}" edu.uci.jsampler.client.JSampler -validate \
        "${sample_method[@]}" \
        -cp "$dir/${target_classes}/:$cppp:$(defects4j export -p cp.compile):$(defects4j export -p cp.test)" \
        -pp \
        -process-dir "$dir/${target_classes}/" \
        -sampler-out-sites="$out/versions/$ver/${coarse_grained}/output.sites" \
        -d "$dir/${target_classes}2/" || exit 1
    echo "> $(cat "$out/versions/$ver/${coarse_grained}/output.sites" | wc -l)"
    [ -e "$out/versions/$ver/${coarse_grained}/output.sites" ] || exit 1
    rm -f $dir/${target_classes}2/*.jimple
    cp -rf $dir/${target_classes}2/* "$dir/${target_classes}/" || exit 1
    rm -rf "$dir/${target_classes}2/"
    #cp -rf /home/user/Desktop/tmp/bin/edu/* $dir/${target_classes}/edu/
    unzip -n "${JSampler_CLASSPATH}" "edu/*" -d "$dir/${target_classes}/" || exit 2
    #sudo chmod +666 -R .

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
    #cp -rf /home/user/Desktop/tmp/bin/edu/* $dir/${target_classes}/edu/
    export CLASSPATH=$root/tools/JSampler.jar
    #unzip -n "$root/JSampler.jar" "edu/*" -d "$dir/${target_classes}/"
    export VERSIONSDIR=$out/versions/$ver/${coarse_grained}/
    export TRACESDIR=$out/traces/$ver/${coarse_grained}/
    rm -rf "$TRACESDIR"
    mkdir -p "$TRACESDIR"
    mkdir -p "$VERSIONSDIR"
    # export SAMPLER_FILE=$TRACESDIR/o1.fprofile
    # sudo chmod +666 -R .
    # defects4j test -t org.apache.commons.lang3.tuple.NumberUtilsTest::TestLang747 # -w /home/user/Desktop/tmp/out/lang_1_buggy/
    # cat failing_tests
    # cat $SAMPLER_FILE
    #exit
    #test -a $TRACESDIR/o1.fprofile || exit 1
    #rm $TRACESDIR/o1.fprofile || exit 1
    count=$(find_tests | sed -re 's/^/> /' | wc -l)
    while read -r test; do
        echo "try test> ${test}"
        name=$(echo "$test" | sed -re 's/[\.:]+/_/g')
        echo "try name> $name"
        export SAMPLER_FILE=$TRACESDIR/$name.pprofile
        defects4j test -t "$test"
        echo defects4j test -t "$test"
        if [ ${coarse_grained} = "outputs" ]; then
            echo "count> $((count--))"
            continue
        fi
        test -a "$SAMPLER_FILE" || {
            cat failing_tests # || echo "$pid $bid failing_tests">log_err.txt
            echo "fail, sample not found"
            echo "$(echo "$dir/$(defects4j export -p dir.src.tests)/$test" | sed 's/\./\//g;s/::.*$//').java"
            echo "$pid $bid $test not found" >>"$root/log_err.txt"
            # ruby -e '' $test
            exit 1
        }
        echo "count> $((count--))"
    done < <(find_tests | sort -r)
    local failnum=0
    for fail in $(defects4j export -p tests.trigger | sed -re 's/[\.:]+/_/g'); do
        echo "mv fail test"
        echo "$fail"
        mv "$TRACESDIR/$fail.pprofile" "$TRACESDIR/$fail.fprofile" && failnum=$((failnum + 1))
        # || exit 1
    done
    [ $failnum = 0 ] && [ $mth != outputs ] && {
        echo "failnum>$failnum"
        exit 1
    }
    echo "failnum>$failnum"
    i=1
    for file in $(find "$TRACESDIR" -name "*.*profile" | sort); do
        echo "$i"
        to=$(echo "${file}" | sed -re "s/[^/]+(\..profile)/o$((i * 2))\1/")
        echo "rename $file -> $to"
        mv "$file" "$to"
        _=$((i++))

    done
}

#    _____ _______ ______ _____    _____ _____ _____
#   / ____|__   __|  ____|  __ \  |_   _|_   _|_   _|
#  | (___    | |  | |__  | |__) |   | |   | |   | |
#   \___ \   | |  |  __| |  ___/    | |   | |   | |
#   ____) |  | |  | |____| |       _| |_ _| |_ _| |_
#  |_____/   |_|  |______|_|      |_____|_____|_____|

# 收集执行时间

step_iii() {

    # case "${coarse_grained}"
    # "none")outputs=outputs
    # ""
    # *)exit
    # esac

    defects4j test

}

#

step_i

#
if [ "${coarse_grained}" = "include" ]; then
    outputs="include"
    #exit 1
else
    outputs="${coarse_grained}"
fi
stime="$(date +%s%N)"
if [ "$RQ" = "-3" ]; then
    step_iii
    # step_ii
else
    step_ii
fi
time="$(($(date +%s%N) - stime - 0))"
mkdir -p "$root/nanoxml/outputs.alt/v$pid_n/versions/subv$bid/$outputs/"
echo -e "Time in seconds: $((time / 1000000000)) \nTime in milliseconds: $((time / 1000000))" >"$root/nanoxml/outputs.alt/v$pid_n/versions/subv$bid/$outputs/time" 2>&1
echo "time> $time"
echo "time> $root/nanoxml/outputs.alt/v$pid_n/versions/subv$bid/$outputs/time"

echo "task ${pid}-${bid}/${mth}${RQ} finished!"
echo "finished> ${pid}-${bid}:${mth}${RQ}" >>$root/log.txt

#java -jar /home/user/Desktop/tmp/bin/HI.jar "$out/.." nanoxml /home/user/Desktop/lab4/out/
