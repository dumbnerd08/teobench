# teobench
## Thermal benchmark and logging software
Dependencies: lm-sensors gnu coreutils

## Instructions
run the script with four parameters. the first parameter is thread count. you can use single for one thread, multi for as many threads as your system has, or an integer. the secord parameter is stress test length. this should be an integer in the form of seconds. the third parameter is the name of the csv file it outputs not including .csv at the end. the fourth is logging interval in seconds. this should be inthe form of na integer.

## How to use
take the csv file it outputs and use some sort of data analisys like a graph generator to parse the data to your liking. TeoBench records time elapsed, cpu core temps using lm-sensors including all of your cpu's sensors and the hotest core, frequency of all your threads from /proc/cpuinfo, and


# FAQ
## Q: Why is this README so crappy?
A: i didnt feel like putting effort into it
