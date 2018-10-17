#!/bin/bash
# Jboss status check V2.3 May 1 2010 - Luis Del Rio IV
cd /tmp/
wget --timeout=5 http://127.0.0.1:8080/status?XML=true > /dev/null 2> /dev/null
data=
errorcount=null
if [ -f "status?XML=true" ] ; then {
data=`cat status\?XML\=true|grep -i -o 'currentthreadcount="[0-9]\{1,3\}"'|grep -o '[0-9]\{1,3\}'|sed '1!d'`
}
fi
date=`date '+%b %e %H'`
grepdate=`date '+%m/%d %H:%m'|sed 's/^0//'|grep -o "[0-9]/[0-9]\{2\} [0-9]\{2\}:[0-9]"`
filename=`ls -lat /opt/jboss/jboss-4.0.4.GA/|grep "${date}"|awk '{print $9}'`
errorcount=`tail -n 50000 /opt/jboss/jboss-4.0.4.GA/${filename}|grep "${grepdate}"|grep "SQL exception"|wc -l`
 
case "$data" in
        [0-9][0-9][0-9]|[0-9][0-9]|[0-9])jboss=0;;
        *)jboss=1;;
esac
 
case "$errorcount" in
    "0")errors=0;;
    *)errors=1;;
esac
 
if [[ "$errors" -eq 1 && "$jboss" -eq 1 ]] ; then {
  echo "CRITICAL - ${errorcount} Jboss errors and web unresponsive"
  state=2
}
fi
 
if [[ "$errors" -eq 0 && "$jboss" -eq 0 ]] ; then {
  echo "JBOSS OK: Web Service running and 0 errors found"
  state=0
}
fi
 
if [[ "$errors" -eq 1 && "$jboss" -eq 0 ]] ; then {
  echo "CRITICAL - Jboss reporting ${errorcount} errors found"
  state=2
}
fi
 
if [[ "$errors" -eq 0 && "$jboss" -eq 1 ]] ; then {
  echo "CRITICAL - Web Service did not return a vaild response"
  state=2
}
fi
 
if [ -f "status?XML=true" ] ; then {
rm status\?XML\=true
}
fi
exit ${state}
