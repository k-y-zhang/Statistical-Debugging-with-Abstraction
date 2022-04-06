#!bash
export mbs_bin="../tools/mps/mbs"
export OUT="log_uuhda233"
rm -rf "$OUT"
mkdir -p $OUT
timeit() {
  
  echo "argv:" "$@"
  # local row_name="$key,$1"
  local row_name="$1"
  local o="$OUT/${row_name}.txt"
  echo "OUT>$o"
  echo -n "${row_name}.size," >>$o
  shift
  stime="$(date +%s%N)"
  /usr/bin/time -f "%M" -a -o "$o" "$@" # 有的程序自己会返回运行信息。
  time="$(($(date +%s%N) - stime - 0))"
  echo -e "${row_name}.time,$((time / 1000000))" >>"$o"
}

mine() {
  local name="$1"
  local preprocess_output_folder=$2
  local k=$3
  local mbs_output_file="${preprocess_output_folder}/mbs_output_file.txt"
  rm -f "$mbs_output_file"
  timeit "${name}.mine" "${mbs_bin}" -k "$k" -n 0.5 -g --refine 2 --dfs --merge --cache 9999 --up-limit 2 "${preprocess_output_folder}/mps-ds.pb" -o "$mbs_output_file" | tee -a "${preprocess_output_folder}/log_mine.txt"
  cat "${preprocess_output_folder}/log_mine.txt"
  echo -n "${row_name}.time_p," >>$o
  grep 'time-cost' "${preprocess_output_folder}/log_mine.txt" >$o
}

#find ./data3 -name '*data*'

sub="grep"

task="./data3/nanoxml/dataset_output_folder_nanoxml_2_5_1_fine-grained"

#mine $task 1
# rm "log_uuhda.txt"
# cat "log_uuhda.txt"

ff(){

local line=$1
echo $line
  oo=$(ruby -e 'm=ARGV[0].match(/dataset_output_folder_(\w+)_([^_]+_[^_]+)_(\d+)_(.+)/);if m then _,sub,ver,k,mth =m.to_a;puts [sub,ver,k,mth]*"\t";end' "$line")
  #echo "$oo"
  #exit
  sub=$(echo "$oo" | awk '{print $1}')
  ver=$(echo "$oo" | awk '{print $2}')
  k=$(echo "$oo" | awk '{print $3}')
  mth=$(echo "$oo" | awk '{print $4}')
  echo "> $sub,$ver,$k,$mth"
  #exit
  if [ -n "$sub" ] ; then 
    mine "${sub},${ver},$k,${mth}" "$line" "$k"
    #exit
  fi
}
export -f ff
export -f mine
export -f timeit
find ./data3 -name '*data*'|sort | xargs -L1 -n1 -P "20" bash -c 'ff "$@"' _

#cat "log_uuhda.txt"

