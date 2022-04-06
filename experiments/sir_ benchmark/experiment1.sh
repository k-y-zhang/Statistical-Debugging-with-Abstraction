#!/usr/bin/bash
# himps1
# 实验 1 脚本
# 这个脚本用来运行原实验 1，
# 包括 c 和 java 程序的差异。
# 以及目录结构的差异。
# TODO: check sed 3 1 ?

root="/home/sunzzq2"
LIB="/home/paper_60/exp2/"
cp -f himps.jar "${LIB}/himps.jar"
BOOST=0.05
theta=1

set -e
#set -v
#set -x
trap 'echo "ERROR: $BASH_SOURCE:$LINENO $BASH_COMMAND" >&2' ERR

sub=$1
pid=$2
bid=$3
k=$4

test -z "$sub" && exit 1 #sub='grep'
test -z "$pid" && exit 1 #pid=1
test -z "$bid" && exit 1 #bid=3
test -z "$k" && exit 1   #k=10
if [ "$sub" = 'siena' ]; then
  sudo echo 'net.ipv4.tcp_tw_reuse=1' | sudo tee -a '/etc/sysctl.conf'
  sudo echo 'net.ipv4.tcp_tw_recycle=1' | sudo tee -a '/etc/sysctl.conf'
  sudo sysctl -p /etc/sysctl.conf
fi
########

HIMPS_JAR="himps.jar"
SUBJECT_TYPE=C
# case $1
#   )
#   *)HIMPS=2
# esac
GENSCRIPT="java -cp /home/paper_60/exp2/zuo3.jar zuo.processor.genscript.client.twopass.GenSirScriptClient"
case $1 in
grep | sed | gzip)
  GENSCRIPT="java -cp /home/paper_60/exp2/zuo3.jar zuo.processor.genscript.client.twopass.GenSirScriptClient"
  ;;
space)
  GENSCRIPT="java -cp /home/paper_60/exp2/zuo3.jar zuo.processor.genscript.client.twopass.GenSiemensScriptsClient"
  ;;
bash)
  GENSCRIPT="java -cp /home/paper_60/exp2/zuo3.jar zuo.processor.genscript.client.twopass.GenBashScriptClient"
  ;;
"apache-ant")
  GENSCRIPT="java -cp /home/paper_60/exp2/zuo3.jar zuo.processor.genscript.client.twopass.java.AntGenSirScriptClient"
  SUBJECT_TYPE=JAVA
  ;;
nanoxml)
  GENSCRIPT="java -cp /home/paper_60/exp2/zuo3.jar zuo.processor.genscript.client.twopass.java.NanoxmlGenSirScriptClient"
  SUBJECT_TYPE=JAVA
  ;;
derby)
  GENSCRIPT="java -cp /home/paper_60/exp2/zuo3.jar zuo.processor.genscript.client.twopass.java.DerbyGenSirScriptClient"
  SUBJECT_TYPE=JAVA
  #BOOST=1
  ;;
siena)
  GENSCRIPT="java -cp /home/paper_60/exp2/zuo3.jar zuo.processor.genscript.client.twopass.java.SienaGenSirScriptClient"
  SUBJECT_TYPE=JAVA
  ;;
*)
  echo "error $1"
  exit 1
  ;;
esac

SUBJECT_VER="v${pid}/subv${bid}"
SUBJECT_VER2="v${pid}_subv${bid}"
dir="/home/sunzzq2/Data/IResearch/Automated_Bug_Isolation/Twopass_heavy/Subjects/${sub}"
OUTPUTSDIR="${dir}/outputs.alt/v${pid}/versions/subv${bid}/{step_name}/time"
EXEPREFIX="${dir}/versions/${SUBJECT_VER}/subv${bid}_"

if [ "$sub" = "space" ]; then
  if [ "$bid" != "-" ]; then
    echo "FAIL> '$bid' is not None"
    exit 1
  fi
  SUBJECT_VER="v${pid}"
  SUBJECT_VER2="v${pid}"
  OUTPUTSDIR="${dir}/outputs/versions/v${pid}/{step_name}/time"
  EXEPREFIX="${dir}/versions/${SUBJECT_VER}/v${pid}_"
fi

for step_name in "coarse-grained" "fine-grained" "boost" "prune" "prune-minus-boost"; do
  rm -f "${OUTPUTSDIR/\{step_name\}/${step_name}}"
done

case "$1" in
"grep" | "sed" | "gzip" | "bash")
  CSITE="${dir}/versions/${SUBJECT_VER}/${SUBJECT_VER2}_c.sites"
  FSITE="${dir}/versions/${SUBJECT_VER}/${SUBJECT_VER2}_f.sites"
  BSITE="${dir}/versions/${SUBJECT_VER}/${SUBJECT_VER2}_b.sites"
  PSITE="${dir}/versions/${SUBJECT_VER}/${SUBJECT_VER2}_p.sites"
  PMBSITE="${dir}/versions/${SUBJECT_VER}/${SUBJECT_VER2}_pmb.sites"
  ;;
space)
  CSITE="${dir}/versions/${SUBJECT_VER}/${SUBJECT_VER2}_c.sites"
  FSITE="${dir}/versions/${SUBJECT_VER}/${SUBJECT_VER2}_f.sites"
  BSITE="${dir}/versions/${SUBJECT_VER}/${SUBJECT_VER2}_b.sites"
  PSITE="${dir}/versions/${SUBJECT_VER}/${SUBJECT_VER2}_p.sites"
  PMBSITE="${dir}/versions/${SUBJECT_VER}/${SUBJECT_VER2}_pmb.sites"
  ;;

"apache-ant" | nanoxml | derby | siena)
  CSITE="${dir}/versions/${SUBJECT_VER}/coarse-grained/output.sites"
  FSITE="${dir}/versions/${SUBJECT_VER}/fine-grained/output.sites"
  BSITE="${dir}/versions/${SUBJECT_VER}/boost/output.sites"
  PSITE="${dir}/versions/${SUBJECT_VER}/prune/output.sites"
  PMBSITE="${dir}/versions/${SUBJECT_VER}/prune-minus-boost/output.sites"
  HIMPS_JAR="himps2.jar"
  ;;
*)
  echo "fail!"
  exit 1
  ;;
esac
#rm -f "$CSITE" "$FSITE" "$BSITE" "$PSITE" "$PMBSITE"
####
Preprocess1_jar=${LIB}/preprocess1.jar
if [ $sub = "nanoxml" ]; then
  Preprocess1_jar=${LIB}/preprocess3.jar
fi
#root=$(pwd)

mkdir -p "$root/outputs/exp1_orig/tmp"
OUT="$root/outputs/exp1_orig/tmp/log_${sub}_${pid}_${bid}_${k}.csv"
echo "$OUT"
# read
OUT2="$root/outputs/exp1_orig/log_${sub}_${pid}_${bid}_${k}.csv"
if test -e "$OUT2"; then
  echo "skip '${sub}_${pid}_${bid}_${k}'"
  exit
fi
rm -rf "$OUT"

# if grep -q "^${pid},${bid},$k,end$" "$OUT2"; then
#     echo "skip finished $*"
#     exit 0
# fi
rm -rf "$root/tmp/"
mkdir -p "$root/tmp/"
# WS=$(mktemp -d -p "$root/tmp/" "orig-${sub}-${pid}-${bid}-$k.XXX")

# echo "${WS}"
# mkdir -p "${WS}/"

#[ -z "$pid" ] && pid=1
#pid_n=$pid
#pids=(NULL Lang Chart Math Time Mockito Closure) #

#[ -z "$bid" ] && bid=2
#[ -z "$k" ] && k=1 # k=1, 5, 10

key="${sub},${pid}_${bid},$k"
echo "$key,start" >>"$OUT"
echo "OUT>>$OUT"

timeit() {
  echo "argv:" "$@"
  local row_name="$key,$1"
  echo -n "$key,$1.size," >>$OUT
  shift
  local stime="$(date +%s%N)"
  # echo 1
  /usr/bin/time -f "%M" -a -o "$OUT" "$@" # 有的程序自己会返回运行信息，特别是时间。
  #echo 2
  local time="$(($(date +%s%N) - stime - 0))"
  # echo 3
  echo -e "${row_name}.time,$((time / 1000000))" >>"$OUT"
}

sizeit() {
  du --apparent-size -s "$1" | awk '{print $1}'
}

# count_p() {
#   ruby -e 'data=STDIN.read;puts (data[/scheme="branches".*?<\/sites>/m]||"\n").count("\n").pred*2+(data[/scheme="returns".*?<\/sites>/m]||"\n").count("\n").pred*6+(data[/scheme="scalar-pairs".*?<\/sites>/m]||"\n").count("\n").pred*6+(data[/scheme="(method|function)-entries".*?<\/sites>/m]||"\n").count("\n").pred*1' # < 'output.sites'
# }
count_p() {
  CODE='
data=STDIN.read;
f=->x{x.empty? ? 0 : x.map{|e|e.count("\n")-1}.inject(&:+)};
puts(
    f[data.scan(/scheme="branches".*?<\/sites>/m)]*2+
    f[data.scan(/scheme="returns".*?<\/sites>/m)]*6+
    f[data.scan(/scheme="scalar-pairs".*?<\/sites>/m)]*6+
    f[data.scan(/scheme="(?:method|function)-entries".*?<\/sites>/m)]*1
)
'
  ruby -e "$CODE"
}
read_profiles() {
  local step_name="$1"
  {
    echo -n "$key,${step_name}.profile.time,"
    cat "${OUTPUTSDIR/\{step_name\}/${step_name}}" | sed -ne '2p' | sed -re 's/[^0-9]+//g'
    echo "$key,${step_name}.profile.size,$(sizeit "${dir}/traces/${SUBJECT_VER}/${step_name}/")"
    local oo=""
    case "${step_name}" in
    "coarse-grained") oo="$CSITE" ;;
    "fine-grained") oo=$FSITE ;;
    "boost") oo=$BSITE ;;
    "prune") oo=$PSITE ;;
    "prune-minus-boost") oo=$PMBSITE ;;
    *)
      echo "step_name ${step_name}"
      exit 1
      ;;
    esac
    echo "# ${oo}"
    echo "$key,${step_name}.profile.number,$(cat "${oo}" | count_p)"
    #echo $(wc -l $oo)
    #echo $(count_p < "$oo")
    #echo "# ${oo}"
  } >>"$OUT"
}
####

dir="/home/sunzzq2/Data/IResearch/Automated_Bug_Isolation/Twopass_heavy/Subjects/${sub}"
cd "$dir/scripts/"

# dataset_output_folder="dataset_output_folder_${sub}_${pid}_${bid}_${k}"
# mbs_output_file="mbs_output_file_${sub}_${pid}_${bid}_${k}"
# mkdir -p ${dataset_output_folder}
# mkdir -p ${mbs_output_file}

############################

# baseline

# echo == 运行fg

collect_run_tests() {
  read_profiles "$1"
}

run_p_m() {
  local step_name=$1
  local profiles=$2  # "${dir}/traces/${SUBJECT_VER}/fine-grained/"
  local site_file=$3 # "${dir}/versions/${SUBJECT_VER}/${SUBJECT_VER2}_f.sites"
  local dataset_output_folder="dataset_output_folder_${sub}_${pid}_${bid}_${k}_${step_name}"
  local mbs_output_file="${dataset_output_folder}/mbs_output_file.txt"
  echo "preprocess ${step_name} ${profiles} ${site_file}"
  rm -rf "${dataset_output_folder}" "${mbs_output_file}"
  # rm -f "${dataset_output_folder}/log_preprocess.txt"

  mkdir -p "${dataset_output_folder}"
  timeit "${step_name}.preprocess" \
    java -Xmx4g -jar ${Preprocess1_jar} \
    "$profiles" \
    "$site_file" \
    "${dataset_output_folder}" | tee -a "${dataset_output_folder}/log_preprocess.txt"
  #    rm -rf "$preprocess_output_folder"

  echo "$key,${step_name}.preprocess.number,$(cat "${dataset_output_folder}/predicate.mapping" | grep '^Pred' | wc -l) " >>$OUT
  echo "$key,${step_name}.preprocess.time_p,$(ruby -e 'print STDIN.read.scan(/preprocessing time = (.+)/)[-1][0].to_f*1000' <"${dataset_output_folder}/log_preprocess.txt")" >>$OUT

  echo ">>>${step_name}.mine"

  timeit "${step_name}.mine" \
    sudo docker run -it --rm -v /home:/home -w "$PWD" mbs2 \
    mbs -k "$k" -n 0.5 -g --refine 2 --dfs --merge --cache 9999 --up-limit 2 "${dataset_output_folder}/mps-ds.pb" -o "${mbs_output_file}" # | tee -a "${dataset_output_folder}/log_mine.txt"  # --metric 0

}

mosh() {
  sed -i -re 's/^sleep [0-9]+$/sleep 0.3/' ./*.sh
  sed -i -re 's/-stime-[0-9]+/-stime/' ./*.sh
  sed -i -r -e 's/stime=/mkdir -p $VERSIONSDIR;mkdir -p $TRACESDIR\nstime=/' *.sh
  sed -i -r -e 's/\/home\/paper_60\/oopsla_artifacts\/single\/Subjects\/Java\//\/home\/sunzzq2\/Data\/IResearch\/Automated_Bug_Isolation\/Twopass_heavy\/Subjects\//g' *.sh
  if [ "$sub" = "derby" ]; then
    # sed -i -re 's/^(.*MySed.*)$/unset SAMPLER_FILE\n\1\n/' ./*.sh
    sed -i -re 's/^(java .*)$/\1\nunset SAMPLER_FILE\n/' ./*.sh
    # find . -name '*.sh' -maxdepth 1 | while read line; do
    #   awk '/SAMPLER_FILE=(.+)/{c=1;h=$0;}/^java/{s=substr(h,0);gsub("/","/" (c++) "/",s);print s;}{print $0}END{print "ruby /home/paper_60/cc.rb $TRACESDIR"}' "$line" >"$line.2"
    #   rm "$line"
    #   mv "$line.2" "$line"
    # done
    sed -i -re 's/^(.*shutdown.*)$/unset SAMPLER_FILE\n\1\n/' ./*.sh
    sed -i -re 's/^(.*MySed.*)$/unset SAMPLER_FILE\n\1\n/' ./*.sh
  fi
  if [ "$sub" = "siena" ]; then
    find . -name '*.sh' -maxdepth 1 | while read line; do
      awk '/^java/ && !/StartServer/{gsub(/\&$/,"")}/SAMPLER_FILE=(.+)/{c=1;h=$0;}/^java/{s=substr(h,0);gsub("/","/" (c++) "/",s);print s;}{print $0}END{print "ruby /home/paper_60/cc.rb $TRACESDIR"}' "$line" >"$line.2"

      # awk '/^java/ && /StartServer/{print "unset SAMPLER_FILE"}/^java/ && !/StartServer/{gsub(/\&$/,"");print h}{print}/SAMPLER_FILE=(.+)/{h=$0}' "$line" >"$line.2"
      rm "$line"
      mv "$line.2" "$line"
    done
    #sed -i -re 's/^(java .*)$/\1\nunset SAMPLER_FILE\n/' ./*.sh
  fi
  # if [ "$sub" = "siena" ]; then
  #   # sed -i -re 's/^(.*MySed.*)$/unset SAMPLER_FILE\n\1\n/' ./*.sh
  #   #sed -i -re 's/^(java .*)$/\1\nunset SAMPLER_FILE\n/' ./*.sh
  #   echo
  #   find . -name '*.sh' -maxdepth 1 | while read line; do
  #     awk '/SAMPLER_FILE=(.+)/{c=1;h=$0;}/^java/{s=substr(h,0);gsub("/","/" (c++) "/",s);print s;}{print $0}END{print "ruby /home/paper_60/cc.rb $TRACESDIR"}' "$line" >"$line.2"
  #     rm "$line"
  #     mv "$line.2" "$line"
  #   done
  # fi
  # if [ "$sub" = "apache-ant" ]; then
  #   sed -i -re 's/JSampler.jar/JSampler_orig.jar/' ./*.sh
  # el
  if [ "$sub" = "nanoxml" -o "$sub" = "siena" ]; then
    sed -i -re 's/JSampler.jar/JSampler_slow.jar/g' ./*.sh
    sed -i -re 's/JSampler_orig.jar/JSampler_slow.jar/g' ./*.sh
    # echo ">su1b $sub"
    # sed -i -re 's/JSampler_slow.jar/JSampler_orig.jar/g' ./*.sh
    #exit
  else
    sed -i -re 's/JSampler.jar/JSampler_orig.jar/g' ./*.sh
    sed -i -re 's/JSampler_slow.jar/JSampler_orig.jar/g' ./*.sh
    # echo ">su2b $sub"
  fi
  #echo ">sub $sub"
  #exit
}
baseline() {
  rm -f "$CSITE" "$FSITE" "$BSITE" "$PSITE" "$PMBSITE"
  echo "$GENSCRIPT"
  $GENSCRIPT || echo 1
  mosh
  ##
  rm -rf "${dir}/traces/${SUBJECT_VER}/coarse-grained/"
  rm -rf "${dir}/traces/${SUBJECT_VER}/fine-grained/"
  mkdir -p "${dir}/traces/${SUBJECT_VER}/coarse-grained/"
  mkdir -p "${dir}/traces/${SUBJECT_VER}/fine-grained/"
  # exit
  # 收集数据（不含运行测试用例）
  sed -i -re '${/^rm /d}' "${dir}/scripts/${SUBJECT_VER2}_cg.sh"
  sed -i -re '${/^rm /d}' "${dir}/scripts/${SUBJECT_VER2}_fg.sh"
  rm -f "${EXEPREFIX}cinst.exe" "${EXEPREFIX}finst.exe"
  bash "${dir}/scripts/${SUBJECT_VER2}_cg.sh" # || echo "ERROR"
  bash "${dir}/scripts/${SUBJECT_VER2}_fg.sh" # || echo "ERROR"
  [ "${SUBJECT_TYPE}" = "C" ] && extract-section .debug_site_info "${EXEPREFIX}cinst.exe" >"$CSITE"
  [ "${SUBJECT_TYPE}" = "C" ] && extract-section .debug_site_info "${EXEPREFIX}finst.exe" >"$FSITE"

  # exit
  # p+m

  collect_run_tests "coarse-grained"
  collect_run_tests "fine-grained"

  #run_p_m "fine-grained" "${dir}/traces/${SUBJECT_VER}/fine-grained/" "$FSITE"

}

#exit

hi_boost() {
  ## 计算 boost

  echo "${key},boost,$BOOST" >>$OUT
  echo "begin"

  wc $CSITE
  wc $FSITE
  du --apparent-size -s "${dir}/traces/${SUBJECT_VER}/coarse-grained"
  echo "end"
  rm -rf "${dir}/versions/${SUBJECT_VER}/predicate-dataset/boost/boost_functions_2_0.05.txt"
  mkdir -p "${dir}/versions/${SUBJECT_VER}/predicate-dataset/boost/"
  java -Xmx4g -jar "${LIB}/${HIMPS_JAR}" \
    "$CSITE" \
    "${dir}/traces/${SUBJECT_VER}/coarse-grained/" \
    "$FSITE" \
    --boost "$BOOST" \
    "${dir}/versions/${SUBJECT_VER}/predicate-dataset/boost/boost_functions_2_0.05.txt" | sudo tee -a "_log.txt"
  cat "${dir}/versions/${SUBJECT_VER}/predicate-dataset/boost/boost_functions_2_0.05.txt"

  echo "${key},boost.functions.count,$(wc -l <"${dir}/versions/${SUBJECT_VER}/predicate-dataset/boost/boost_functions_2_0.05.txt")" >>$OUT
  local includes=$(ruby -e 'puts $<.readlines.map{|e|"-sampler-include-method="+e.chomp.gsub(/->.*$/,"").gsub(/[ ():<>$]/, "-")}.sort*" "' <"${dir}/versions/${SUBJECT_VER}/predicate-dataset/boost/boost_functions_2_0.05.txt")

  echo "$key,boost.includes,$includes" >>$OUT
  #exit
  $GENSCRIPT || echo 1
  mosh
  #sed -i -re 's/^stime=/exit\n/' ./*.sh # for debug
  ## 运行测试用例
  rm -rf "${dir}/traces/${SUBJECT_VER}/boost/"   #!!
  mkdir -p "${dir}/traces/${SUBJECT_VER}/boost/" #!!
  sed -i -re 's/^rm \$TRACE.*$//' "${dir}/scripts/${SUBJECT_VER2}_boost.sh"
  rm -f "${EXEPREFIX}binst.exe"
  bash "${dir}/scripts/${SUBJECT_VER2}_boost.sh" || echo "ERROR"
  #exit
  [ "${SUBJECT_TYPE}" = "C" ] && {
    rm -f "$BSITE"
    extract-section .debug_site_info "${EXEPREFIX}binst.exe" >$BSITE
  }

  ## 预处理
  echo "$BSITE"
  run_p_m "boost" "${dir}/traces/${SUBJECT_VER}/boost/" "$BSITE"
  local step_name="boost"
  local dataset_output_folder="dataset_output_folder_${sub}_${pid}_${bid}_${k}_${step_name}"
  local mbs_output_file="${dataset_output_folder}/mbs_output_file.txt"
  echo 计算 theta
  cat "${mbs_output_file}"
  theta=$(ruby -e "xs=STDIN.read.scan(/TOP-\(\d+\) SUP=.+ IG=(.+)$/);puts(xs[ARGV[0].to_i-1]||xs.last)" "$k" <"${mbs_output_file}")
  echo "theta>$theta"
  # echo "${key},theta,${theta}" >>$OUT

}

hi_prune() {
  ## 首先，生成函数列表
  echo "theta>$theta"
  #[ "$sub" = "gzip" ] &&
  echo "${key},theta,${theta}" >>$OUT
  if [ "$sub" = "gzip" ]; then
    echo
  # theta=$(echo "$theta - 0.000001" | bc) # gzip 向下取整
  fi
  local himps_prune_output_file="${dir}/versions/${SUBJECT_VER}/predicate-dataset/prune/prune_functions_2_0.05.txt"
  mkdir -p "$(dirname "${himps_prune_output_file}")"
  rm -rf "${himps_prune_output_file}"
  #rm -rf "${himps_prune_output_file}"
  rm -rf "${dir}/versions/${SUBJECT_VER}/predicate-dataset/pruneMinusBoost/prune_minus_boost_functions_2_0.05.txt"
  #
  echo java -Xmx4g -jar "${LIB}/${HIMPS_JAR}" \
    "$CSITE" \
    "${dir}/traces/${SUBJECT_VER}/coarse-grained" \
    "$FSITE" \
    --prune "$theta" \
    "${himps_prune_output_file}" >_debug.txt
  #
  java -Xmx4g -jar "${LIB}/${HIMPS_JAR}" \
    "$CSITE" \
    "${dir}/traces/${SUBJECT_VER}/coarse-grained" \
    "$FSITE" \
    --prune "$theta" \
    "${himps_prune_output_file}" | sudo tee -a "_log.txt"

  #
  test -a "${himps_prune_output_file}"
  echo "${key},prune.functions.count,$(wc -l <"${himps_prune_output_file}")" >>$OUT

  # local includes=$(ruby -e 'puts $<.readlines.map{|e|"-sampler-include-method="+e.chomp.gsub(/->.*$/,"").gsub(/[ ():<>$]/, "-")}.sort*" "' <"$himps_prune_output_file")
  local includes=$(ruby -e 'puts $<.readlines.map{|e|"-sampler-include-method="+e.chomp.gsub(/->.*$/,"").gsub(/[ ():<>$]/, "-")}.sort*" "' <"$himps_prune_output_file")

  echo "$key,prune.includes,$includes" >>$OUT
  mkdir -p $(dirname "${dir}/versions/${SUBJECT_VER}/predicate-dataset/pruneMinusBoost/prune_minus_boost_functions_2_0.05.txt")
  ruby -e 'a,b=ARGV.map{|e|open(e).readlines};puts(b-a)' \
    "${dir}/versions/${SUBJECT_VER}/predicate-dataset/boost/boost_functions_2_0.05.txt" \
    "${himps_prune_output_file}" >"${dir}/versions/${SUBJECT_VER}/predicate-dataset/pruneMinusBoost/prune_minus_boost_functions_2_0.05.txt"
  echo "${key},prune.functions.count,$(wc -l <"${dir}/versions/${SUBJECT_VER}/predicate-dataset/pruneMinusBoost/prune_minus_boost_functions_2_0.05.txt")" >>$OUT
  #exit
  ## 然后，生成执行脚本
  $GENSCRIPT || echo 1
  mosh
  rm -f "$PSITE" "$PMBSITE" # !
  ## 并执行（记录pruneMinusBoost的运行数据，用prune的结果mine）。
  rm -rf "${dir}/traces/${SUBJECT_VER}/prune/"
  mkdir -p "${dir}/traces/${SUBJECT_VER}/prune/" #!!
  rm -rf "${dir}/traces/${SUBJECT_VER}/prune-minus-boost/"
  mkdir -p "${dir}/traces/${SUBJECT_VER}/prune-minus-boost/" #!!
  sed -i -re 's/^rm \$TRACE.*$//' "${dir}/scripts/${SUBJECT_VER2}_prune.sh"
  sed -i -re 's/^rm \$TRACE.*$//' "${dir}/scripts/${SUBJECT_VER2}_pruneMinusBoost.sh"
  rm -f "${EXEPREFIX}pinst.exe" "${EXEPREFIX}pmbinst.exe"
  bash "${dir}/scripts/${SUBJECT_VER2}_prune.sh" || echo "ERROR"
  bash "${dir}/scripts/${SUBJECT_VER2}_pruneMinusBoost.sh" || echo "ERROR"
  [ "${SUBJECT_TYPE}" = "C" ] && {
    rm -f "$PSITE" "$PMBSITE" # !
    extract-section .debug_site_info "${EXEPREFIX}pinst.exe" >$PSITE
    extract-section .debug_site_info "${EXEPREFIX}pmbinst.exe" >$PMBSITE
  }

  # sed -i -re 's/([0-9]+\t[0-9]+\t[0-9]+)\t[0-9]+/\1/' ${dir}/traces/${SUBJECT_VER}/prune/* # bug?
  ## 最后，预处理（只处理 prune 的）
  ## 并挖掘（只挖掘 prune 的）
  if test -s "${himps_prune_output_file}"; then
    run_p_m "prune" "${dir}/traces/${SUBJECT_VER}/prune/" "$PSITE"
  fi

}

hi_method() {
  # cg
  run_p_m "fine-grained" "${dir}/traces/${SUBJECT_VER}/fine-grained/" "$FSITE"
  # boost
  hi_boost

  hi_prune

  # collect_run_tests "coarse-grained"
  # collect_run_tests "fine-grained"
  collect_run_tests "boost"
  collect_run_tests "prune"
  if [ -s "${dir}/versions/${SUBJECT_VER}/predicate-dataset/pruneMinusBoost/prune_minus_boost_functions_2_0.05.txt" ]; then
    collect_run_tests "prune-minus-boost"
  fi
}

[ "$k" = 1 ] && baseline
# exit
hi_method

echo "END"
echo "$key,end" >>"$OUT"
cat "$OUT"
cat "$OUT" >"$OUT2"
rm -f "$OUT"
exit

############################

# 收集数据。

# baseline
# hi
#
#
#

grep v1_subv3
grep v1_subv7
grep v1_subv8
grep v1_subv11
grep v3_subv12
grep v3_subv2
grep v4_subv10
grep v4_subv12

gzip v1_subv4
gzip v1_subv5
gzip v1_subv13
gzip v1_subv15
gzip v1_subv16
gzip v2_subv1
gzip v2_subv3
gzip v2_subv6
gzip v4_subv6
gzip v5_subv13
gzip v5_subv1
gzip v5_subv6
gzip v5_subv7

sed v2_subv1
sed v3_subv1
sed v3_subv2
sed v3_subv5

gzip 1 5
# # # #

grep 1 8 1
gzip 1 4 1
sed 2 1 1

space 3

bash 1 4

apache-ant 8 1

derby 5 8

nanoxml 1 1

siena 1 2

# # # #
csh
# predicate-dataset
# csh,bison

TOTO: include 为空的情况的处理。
