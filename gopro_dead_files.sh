#!/bin/sh
#
# Shell script to remove extra hidden gopro files after deleting gopro videos w/out app
# 2017 08.30.2017 LDRIV https://www.linkedin.com/in/ldriv/

# Get list of files in current dir
filenames=`ls|tr '.' ' '|awk '{print $1}'`

# Get base filename counts and only print ones that have 2 occurrences
# Gopro stores 3 files total for each video, MP4 THM LRV
basenames=`echo "$filesnames"|sort -n -k2,2|uniq -c|sort -rk 1|grep "2 "|awk '{print $2}'`

# Delete files
for file in ${basenames[@]}; do 
  rm $file.LRV
  rm $file.THM 
done
