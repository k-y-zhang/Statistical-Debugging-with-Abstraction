#!/usr/bin/bash

echo 123
set -e

# 2021年9月30日
# 41c3458f6392   dockerbase/java7                 "/bin/bash"              2 months ago   Exited (0) 6 weeks ago                                                  nostalgic_borg

# "$out/projects.txt"

# 收集项目信息，支持多进程。
pids=(Lang Chart Math Time Mockito Closure) # Chart Time Closure Math Mockito
declare -A bids
bids["Lang"]=65
bids["Chart"]=26
bids["Math"]=106
bids["Time"]=27
bids["Mockito"]=38
bids["Closure"]=176
count_p(){
	ruby -e 'data=STDIN.read;puts (data[/scheme="branches".*?<\/sites>/m]||"\n").count("\n").pred*2+(data[/scheme="returns".*?<\/sites>/m]||"\n").count("\n").pred*6+(data[/scheme="scalar-pairs".*?<\/sites>/m]||"\n").count("\n").pred*6+(data[/scheme="method-entries".*?<\/sites>/m]||"\n").count("\n").pred*1' # < 'output.sites'
}
if true; then
    out="outputs/table1.csv"
    echo "Subject,versions,LoC,Functions,Predicates,Tests,Language" >"outputs/table1.csv"
    for p in {1..6}; do
        pid="${pids[$((p - 1))]}"
        for ((i = 1; i <= ${bids[$pid]}; i++)); do
            #echo "$pid" "$i"
            echo -n "$pid,$i,"
            echo -n "$(ruby -e 'print STDIN.read.match(/#{ARGV[0]},java:\s+(\d+)/)[1]' "$pid,$i" <"outputs/nanoxml/projects.txt")," # LoC
            echo -n "$(($(cat "outputs/nanoxml/versions/v${p}/subv${i}/coarse-grained/output.sites" | wc -l) - 2)),"                # Functions
            echo -n "$(($(cat "outputs/nanoxml/versions/v${p}/subv${i}/fine-grained/output.sites" | count_p) - 0)),"                # Predicates
            echo -n "$(find "outputs/nanoxml/traces/v${p}/subv${i}/coarse-grained/" | wc -l),"                                      # Tests
            echo -n "Java"                                                                                                          # Language
            echo                                                                                                                    # Next
        done | tee -a "$out"
    done
fi

#exit

read
read

#
PROCESS_NUM=1
f1() {
    echo "$1" "$2"
    bash profile_v2.sh "$1" "$2" "check" 2>&1
}
export -f f1
for pid in "${pids[@]}"; do
    for ((i = 1; i <= ${bids[$pid]}; i++)); do
        echo "$pid" "$i"
    done
done | xargs -L1 -n2 -P "$PROCESS_NUM" bash -c 'f1 "$@"' _
