#!
DIR="/home/sunzzq2/outputs/exp1_orig/tmp"
mkdir -p "$DIR"
f() {
	echo experiment1.sh "$1" "$2" "$3" 1 >>"${DIR}/_log.txt"
	bash experiment1.sh "$1" "$2" "$3" 1
	echo experiment1.sh "$1" "$2" "$3" 5 >>"${DIR}/_log.txt"
	bash experiment1.sh "$1" "$2" "$3" 5
	echo experiment1.sh "$1" "$2" "$3" 10 >>"${DIR}/_log.txt"
	bash experiment1.sh "$1" "$2" "$3" 10
}

export -f "f"

# f grep 1 8
# # exit
# ## sed
# f sed 2 1
# f sed 3 1
# f sed 3 2
# f sed 3 5
# #exit
# ## gzip
# f gzip 1 4
# f gzip 1 5
# f gzip 2 1
# f gzip 2 3
# f gzip 5 13

# f space 16 -
# f space 14 -
# f space 38 -
# f apache-ant 8 1
# f apache-ant 8 3
# f nanoxml 1 1
# f nanoxml 1 2
# f nanoxml 3 5
# f nanoxml 3 2
# exit
# f gzip 1 4
# f space 3 -
# f bash 1 4
# f apache-ant 8 1
# f nanoxml 1 1
# f siena 1 2
# exit
# #f derby 5 8

# exit
# ## grep
# f grep 1 3
# f grep 1 7
# f grep 1 8
# f grep 1 11
# f grep 3 2
# f grep 3 12
# f grep 4 10
# f grep 4 12

# exit

# grep 1 3
# grep 1 7
# grep 1 8
# grep 1 11
# grep 3 12
# grep 3 2
# grep 4 10
# grep 4 12
# ## gzip
# f gzip 1 4
# f gzip 1 5
# f gzip 1 13
# f gzip 1 15
# f gzip 1 16
# f gzip 2 1
# f gzip 2 3
# f gzip 2 6
# f gzip 4 6
# f gzip 5 13
# f gzip 5 1
# f gzip 5 6
# f gzip 5 7

# sed 2 1
# sed 3 1
# sed 3 2
# sed 3 5

# exit

run_ant='
	f apache-ant 8 2
	f apache-ant 8 3
	f apache-ant 8 4
	f apache-ant 8 1
'

run_grep='
	f grep 3 2
	f grep 3 12
	f grep 1 3
	f grep 1 8
	f grep 1 7
	f grep 1 11
	f grep 4 10
	f grep 4 12
'
run_space='
	f space 4 -
	f space 37 -
	f space 6 -
	f space 12 -
	f space 33 -
	f space 11 -
	f space 5 -
	f space 21 -
	f space 16 -
	f space 14 -
	f space 38 -
	f space 23 -
	f space 22 -
	f space 27 -
	f space 25 -
	f space 15 -
	f space 13 -
	f space 19 -
	f space 29 -
	f space 8 -
	f space 35 -
	f space 17 -
	f space 28 -
	f space 36 -
	f space 26 -
	f space 20 -
	f space 30 -
	f space 31 -
	f space 7 -
	f space 10 -
	f space 3 -
	f space 24 -
	f space 9 -
	f space 18 -
'

run_sed='
	f sed 3 5
	f sed 3 2
	f sed 3 1
	f sed 2 1
'
run_bash='
	f bash 1 5
	f bash 1 3
	f bash 1 2
	f bash 1 4
	f bash 2 2
	f bash 2 3
	f bash 2 1
	f bash 1 1
	f bash 1 6
'
run_gzip='
	f gzip 2 6
	f gzip 1 5
	f gzip 1 13
	f gzip 5 7
	f gzip 5 6
	f gzip 1 4
	f gzip 1 16
	f gzip 4 6
	f gzip 2 3
	f gzip 5 13
	f gzip 2 1
	f gzip 1 15
	f gzip 5 1
'
run_derby='
	f derby 5 30
	f derby 5 61
	f derby 5 8
'
run_nanoxml='
	f nanoxml 2 6
	f nanoxml 2 5
	f nanoxml 3 5
	f nanoxml 3 2
	f nanoxml 4 7
	f nanoxml 3 1
	f nanoxml 3 7
	f nanoxml 1 2
	f nanoxml 1 4
	f nanoxml 4 1
	f nanoxml 1 7
	f nanoxml 3 10
	f nanoxml 2 2
	f nanoxml 4 6
	f nanoxml 2 3
	f nanoxml 4 3
	f nanoxml 4 2
	f nanoxml 1 1
	f nanoxml 2 7
	f nanoxml 4 4
	f nanoxml 1 6
	f nanoxml 3 3
'
run_siena='
	f siena 1 2
	f siena 2 1
	f siena 5 1
'

if true; then
	sudo echo 'net.ipv4.tcp_tw_reuse=1' | sudo tee -a '/etc/sysctl.conf'
	sudo echo 'net.ipv4.tcp_tw_recycle=1' | sudo tee -a '/etc/sysctl.conf'
	sudo sysctl -p /etc/sysctl.conf
fi
# 'export -f run_sed
# export -f run_ant
# export -f run_derby
# export -f run_grep
# export -f run_gzip
# export -f run_nanoxml
# export -f run_siena
# export -f run_space
# export -f run_bash
bash -c "$run_sed"
bash -c "$run_ant"
bash -c "$run_derby"
bash -c "$run_grep"
bash -c "$run_gzip"
bash -c "$run_nanoxml"
bash -c "$run_siena"
bash -c "$run_space"
bash -c "$run_bash"
wait
exit
#run_derby &
run_grep &
run_gzip &
run_nanoxml &
run_siena &
run_space &
run_bash &
#
# sed mv s3060_0.wout
