#!/usr/bin/bash

PROCESS_NUM=8
[ -z "$1" ] || PROCESS_NUM="$1"
echo "$PROCESS_NUM"
bids=(0 65 26 106 38 27 176)

ff() {
  local pid=$1
  local bid=$2
  bash experiment1.sh "$pid" "$bid" "10"
  bash experiment1.sh "$pid" "$bid" "5"
  bash experiment1.sh "$pid" "$bid" "1"
}

export -f ff

# for pid in {1..6}; do
#   ff "$pid" "1" &
# done
# wait
for pid in {1..6}; do
  for bid in $(seq "${bids[$pid]}"); do
    echo "$pid" "$bid"
  done
done
for pid in {1..6}; do
  for bid in $(seq "${bids[$pid]}"); do
    echo "$pid" "$bid"
  done
done | xargs -L1 -n2 -P "$PROCESS_NUM" bash -c 'ff "$@"' _

exit



















for pid in {1..6}; do
  for bid in $(seq "${bids[$pid]}"); do
    echo "$pid" "$bid"
    bash experiment1.sh "$pid" "$bid" "5"
    #   read
    #exit
  done
  #exit
done

for pid in {1..6}; do
  for bid in $(seq "${bids[$pid]}"); do
    echo "$pid" "$bid"
    bash experiment1.sh "$pid" "$bid" "10"
    #   read
    #exit
  done
  #exit
done
