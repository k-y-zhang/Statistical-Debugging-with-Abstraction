#!bash
# 实验2 RQ3 的脚本
set -e
lang=$1
sub=$2
name="$1/$2"
mode="$3"
echo "> $name"
if [ "$sub" = "derby" -o "$sub" = "siena" ]; then
    lsof -i:7000 || echo 1
    sudo echo 'net.ipv4.tcp_tw_reuse=1' | sudo tee -a '/etc/sysctl.conf'
    sudo echo 'net.ipv4.tcp_tw_recycle=1' | sudo tee -a '/etc/sysctl.conf'
    sudo sysctl -p /etc/sysctl.conf
fi
genscript() {
    if [ "$lang" = C ]; then
        [ "$sub" = "bash" ] && java -cp "/home/paper_60/HI.jar" zuo.processor.genscript.client.iterative.GenBashScriptClient
        [ "$sub" != "bash" ] && java -cp "/home/paper_60/HI.jar" zuo.processor.genscript.client.iterative.GenSiemensScriptsClient
        [ "$sub" != "bash" ] && java -cp "/home/paper_60/HI.jar" zuo.processor.genscript.client.iterative.GenSirScriptClient
    else
        [ "$sub" = "apache-ant" ] && java -cp "/home/paper_60/HI.jar" zuo.processor.genscript.client.iterative.java.AntGenSirScriptClient
        [ "$sub" = "derby" ] && java -cp "/home/paper_60/HI.jar" zuo.processor.genscript.client.iterative.java.DerbyGenSirScriptClient
        [ "$sub" = "nanoxml" ] && java -cp "/home/paper_60/HI.jar" zuo.processor.genscript.client.iterative.java.NanoxmlGenSirScriptClient
        [ "$sub" = "siena" ] && java -cp "/home/paper_60/HI.jar" zuo.processor.genscript.client.iterative.java.SienaGenSirScriptClient
    fi
    echo "done1 "
}
f1() {
    local i=$1
    echo "$i"
    #local lang=$1
    #local subject=$2
    #for $i in "C/grep" ; do
    find "/home/paper_60/oopsla_artifacts/single/Subjects/${i}/scripts/" -name '*.sh' -maxdepth 1 -delete
    find "/home/paper_60/oopsla_artifacts/single/Subjects/${i}/" -wholename '*adaptive/time' -delete
    find "/home/paper_60/oopsla_artifacts/single/Subjects/${i}/" -wholename '*outputs/time' -delete
    #done
    #genscript
    cd "/home/paper_60/oopsla_artifacts/single/Subjects/${i}/scripts/"

}
f2() {
    local i=$1
    cd "/home/paper_60/oopsla_artifacts/single/Subjects/${i}/scripts/"
    sed -i -re 's/^sleep [0-9]+$/sleep 0.5/' ./*.sh
    sed -i -re 's/-stime-[0-9]+/-stime/' ./*.sh
    sed -i -r -e 's/stime=/mkdir -p $VERSIONSDIR;mkdir -p $TRACESDIR\nstime=/' *.sh
    find . -name '*_fg_a.sh'
    #exit
    #bash
    find . -name '*_fg_a.sh' -exec bash {} \;
    {
        echo "${i}"
        echo "adaptive"
        find "/home/paper_60/oopsla_artifacts/single/Subjects/${i}/" -wholename '*adaptive/time' | sort
        find "/home/paper_60/oopsla_artifacts/single/Subjects/${i}/" -wholename '*adaptive/time' | sort | xargs -n1 cat | grep "milli" | sed -re 's/[^0-9-]//g'
        echo "end"
    } | tee -a "/home/paper_60/log_dggs_${sub}.txt"
    #bash
    find . -name '*_fg_a.sh' | sed -re 's/_fg_a//' | xargs -n1 bash
    find "/home/paper_60/oopsla_artifacts/single/Subjects/${i}/" -wholename '*adaptive/time'
    {
        echo "${i}"
        echo "outputs"
        find "/home/paper_60/oopsla_artifacts/single/Subjects/${i}/" -wholename '*outputs/time' | sort
        find "/home/paper_60/oopsla_artifacts/single/Subjects/${i}/" -wholename '*outputs/time' | sort | xargs -n1 cat | grep "milli" | sed -re 's/[^0-9-]//g'
        echo "end"
    } | tee -a "/home/paper_60/log_dggs_${sub}.txt"
    # find "/home/paper_60/oopsla_artifacts/single/Subjects/${i}/" -wholename '*adaptive/time' -exec cat {} \; | grep "^T"
    # find "/home/paper_60/oopsla_artifacts/single/Subjects/${i}/" -wholename '*adaptive/time' -exec cat {} \; | grep "^T" | sed -re 's/[^0-9]//g' | awk '{a+=$0;b++}END{print(a/b)}'
    #find "/home/paper_60/oopsla_artifacts/single/Subjects/${i}/" -wholename '*/time'
}
cd "/home/paper_60/oopsla_artifacts/single/Subjects/${name}/scripts/"
if [ "$mode" = 'inst' ]; then
    find . -name '*_fg_a.sh' | sed -re 's/_fg_a/_cg/' | xargs -n1 bash
    find . -name '*_fg_a.sh' | sed -re 's/_fg_a/_fg/' | xargs -n1 bash
    cd /home/paper_60/
    java -jar HI.jar "oopsla_artifacts/single/Subjects/$lang/" "$sub" out &
    exit
fi
f1 "$name"
genscript
f2 "$name"
find "/home/paper_60/oopsla_artifacts/single/Subjects/${i}/" -wholename '*outputs/time' | sort | xargs -n1 cat
# for i in  "C/grep" "C/sed" "C/space" "C/bash" "C/gzip" "Java/nanoxml" "Java/siena" "Java/derby" "Java/apache-ant"; do
#     f1 "$i"
# done

# genscript

# #tcp
# #sleep

# for i in  "C/grep" "C/sed" "C/space" "C/bash" "C/gzip" "Java/nanoxml" "Java/siena" "Java/derby" "Java/apache-ant"; do
#     f2 "$i"
# done

#mkdir out2 -p
#java -cp "/home/paper_60/HI.jar" zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/C/ grep out2
# java -cp "/home/paper_60/HI.jar" zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/C/ bash out2
# java -cp "/home/paper_60/HI.jar" zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/C/ gzip out2
# java -cp "/home/paper_60/HI.jar" zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/C/ space out2
# java -cp "/home/paper_60/HI.jar" zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/C/ sed out2
# java -cp "/home/paper_60/HI.jar" zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/Java/ nanoxml out2
# java -cp "/home/paper_60/HI.jar" zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/Java/ siena out2
# java -cp "/home/paper_60/HI.jar" zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/Java/ derby out2
# java -cp "/home/paper_60/HI.jar" zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/Java/ apache-ant out2

#find "/home/paper_60/oopsla_artifacts/single/Subjects" -wholename '*/time'
exit
cd /home/paper_60/
java -jar HI.jar oopsla_artifacts/single/Subjects/C/ grep out &
java -jar HI.jar oopsla_artifacts/single/Subjects/C/ bash out &
java -jar HI.jar oopsla_artifacts/single/Subjects/C/ gzip out &
java -jar HI.jar oopsla_artifacts/single/Subjects/C/ space out &
java -jar HI.jar oopsla_artifacts/single/Subjects/C/ sed out &
java -jar HI.jar oopsla_artifacts/single/Subjects/Java/ nanoxml out &
java -jar HI.jar oopsla_artifacts/single/Subjects/Java/ siena out &
java -jar HI.jar oopsla_artifacts/single/Subjects/Java/ derby out &
java -jar HI.jar oopsla_artifacts/single/Subjects/Java/ apache-ant out &

# -Xmx1g
