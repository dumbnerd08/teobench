#!/bin/bash

# Parameters:
# Param 1: thread count (single for one thread, multi for all of the threads in your pc, or an integer)
# Param 2: how long to run benchmark (seconds)
# Param 3: name of csv file (not including .csv)
# Param 4: logging interval (seconds)

# Check for superuser and prompt if necessary
sudo -v

# Check if benchmark profile file exists in /tmp
if [ -e /tmp/teobench.teo ]
then
    echo "CRITICAL ERROR: Another instance of TeoBench is running. Please either stop it or reboot your computer."
    exit
fi

# Check if csv file exists
if [ -e $3 ]
then
    echo "CRITICAL ERROR: $3.csv already exists in the current directory."
    exit
fi

# Create both necessary files and add permissions (before sudo runs out)
sudo echo "" > $3.csv || (echo "CRITICAL ERROR: Could not create ./$3.csv"; exit)
echo "" > $3.csv || (echo "CRITICAL ERROR: Could not create ./$3.csv"; exit)
sudo chmod 666 $3.csv || (echo "CRITICAL ERROR: Could not add permission to ./$3.csv."; exit)
sudo echo "" > /tmp/teobench.teo || (echo "CRITICAL ERROR: Could not create /tmp/teobench.teo"; exit)
echo "" > /tmp/teobench.teo || (echo "CRITICAL ERROR: Could not create /tmp/teobench.teo"; exit)
sudo chmod 666 /tmp/teobench.teo || (echo "CRITICAL ERROR: Could not add permission to /tmp/teobench.teo."; exit)
sync

# Interpret thread count
if [ $1 == "single" ]
then
    threads=1
elif [ $1 == "multi" ]
then
    threads=$(nproc)
else
    threads=$1
fi
echo "Running $threads threads."

# Adding info to config file
# Runtime
(( runtime=$(date +%s) + $2 ))
echo $runtime > /tmp/teobench.teo

# Prepping CSV data
# Number of core temp sensors
coretemps=$((for (( i=1; i<=$(sensors | grep Core | wc -l); i++ )); do echo "core_$[i]_temp"; done) | tr '\n' ',' | rev | cut -c2- | rev)

# Number of cores with frequencies
corefreq=$((for (( i=1; i<=$(cat /proc/cpuinfo | grep MHz | wc -l); i++ )); do echo "core_$[i]_freq"; done) | tr '\n' ',' | rev | cut -c2- | rev)

# Adding data to CSV file
echo "time,$coretemps,hottest_core,$corefreq" > $3.csv

# Creating threads
for (( i=1; i<=$threads; i++ )); do
    while [ $(date +%s) -le $(cat /tmp/teobench.teo) ]
    do
        (( c++ ))
    done &
done
echo "Threads created! Please wait."

while [ $(date +%s) -le $(head -n 1 /tmp/teobench.teo) ]
do
    # Logging to CSV file
    # Prepping values
    # Prepping remaining time
    (( time=$(head -n 1 /tmp/teobench.teo) - $(date +%s) ))
    (( time=$2 - $time ))
    # Prepping core temperatures
    coretemps=$(sensors | grep Core | cut -c 17-18 | tr '\n' ',' | rev | cut -c2- | rev)
    # Prepping hottest core
    hottestcore=$(sensors | grep Package | cut -c 17-18)
    # Prepping CPU frequencies
    corefreq=$(cat /proc/cpuinfo | grep MHz | cut -c 12- | tr '\n' ',' | rev | cut -c2- | rev)
    # Add it to CSV file
    echo "$time,$coretemps,$hottestcore,$corefreq" >> $3.csv
    echo "Just logged some more data. $time seconds in."
    sleep $4
done
echo "Benchmark complete."
rm -f /tmp/teobench.teo
