#!/bin/sh
# 2010 LDR
# Shell script for nagios to verify files on data server
 
if [[ "$2" = "-x" ]] ; then
set -x
fi
 
# Script Variables
file=$1
date=`date -d tomorrow +%y%m%d` #Set date to tomorrows date with syntax 101229
login=user
password=password
server="dataserver.web.com"
 
eout(){
echo "${error}"
exit 2
}
 
 
# Check which file and append correct syntax
case $file in
OP)file=OP${date}.TXT;;
CK)file=CK${date}.TXT;;
esac
 
# If no file specified error out
if [[ "$file" == "" ]] ; then
echo "Parameters are incorrect..."
exit
fi
 
# Connect to server and check ${file}
output=`lftp << EOF
open -u ${login},${password} ftp://${server}/In/
ls -ltrh ${file}
bye
EOF`
 
# Check if file exists, file date, and file size
data=( `echo ${output}|awk '{print $5,$6,$7,$9}'` )
 
if [[ "${output}" == "" ]] ; then
error="CRITICAL: File ${file} was not found.."
eout
fi
 
if [[ "${data[0]}" == 0 ]] ; then
error="CRITICAL: File is empty!"
eout
fi
 
echo "OK - ${file} exists with ${data[0]} filesize."
exit 0
