#!/bin/bash

threads=8
outer_size=100000000
selectivity=0.9
load_factor=0.5

echo "Threads:" $threads
echo "Outer Table Size:" $outer_size
echo "Selectivity:" $selectivity
echo "Load Factor:" $load_factor

make > /dev/null

probe_test() {
  echo ""
  echo "CPU Intrinsics Probe"
  rm -f cpu-intrinsics-probe-results.csv cpu-intrinsics-probe-log.txt
  echo "table_size; scalar; scalar_time_ns; vertical; vertical_time_ns" > cpu-intrinsics-probe-results.csv

  for table_size in "4KB" "8KB" "16KB" "32KB" "64KB" "128KB" "256KB" "512KB" "1MB" "2MB" "4MB" "8MB" "16MB" "32MB" "64MB"
  do
    echo "--> Hash Table Size:" $table_size
    echo -n "    repetition:"
    for i in $(seq 20)
    do
      echo -n " "$i
      ./cpu_probe $table_size $outer_size $selectivity $load_factor >> cpu-intrinsics-probe-results.csv 2> cpu-intrinsics-probe-log.txt
    done
    echo ""
  done
}

build_test() {
  echo ""
  echo "Hashing Instrinsics Xeon Build"
  rm -f cpu-intrinsics-build-results.csv cpu-intrinsics-build-log.txt
  echo "table_size; scalar; scalar_time_ns" > cpu-intrinsics-build-results.csv

  for inner_size in 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304
  do
    echo "--> Inner Size:" $inner_size
    echo -n "    repetition:"
    for i in $(seq 20)
    do
      echo -n " "$i
      ./cpu_build $threads 16 $inner_size $inner_size $selectivity $load_factor >> cpu-intrinsics-build-results.csv 2> cpu-intrinsics-build-log.txt
    done
    echo ""
  done
}

build_test
probe_test

make clean > /dev/null
