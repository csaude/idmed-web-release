#!/bin/bash -x  
######################################################################################                                                                                                                                                                                                                                                                                                                                                                          
# Script to start idMED backend
# Written by MChSS
# (C) 2023 - C-Saude
#
# 20230828: Initial release
# - Additional comments:
#
######################################################################################
#cd /usr/src/idmed && java -jar SIFMOZ-Backend.war
######################################################################################
# -- Environment Variables Settings
APP_NAME=IDMED
EXEC_DIR=/usr/src/idmed
EXEC_LOG=/var/log/idmed_logs/
EXEC_CPATH=./
EXEC_LIB=""
dashDparameters="-Djava.security.egd=file:///dev/urandom -XX:+UnlockExperimentalVMOptions \
-XX:+UseCGroupMemoryLimitForHeap"

# -- Sys Lang and TZ Settings
#export LANG=en_US.iso88591
#export LANGVAR=en_US.iso88591
#export LC_CTYPE=en_US.iso88591
export TZ="Africa/Maputo"

# -- java memory settings
export XMS=2048M
export XMX=2048M
export MaxRAM="-XX:MaxRAM=8g"
######################################################################################
# -- /etc/hosts and /etc/resolv.conf tunning.
#echo "192.168.1.1 idmedhost" >>/etc/hosts

#echo "# Emptied by startidmed.sh" >/etc/resolv.conf
#echo "options timeout:1 attempts:1 no-check-names rotate" >>/etc/resolv.conf
#echo "#nameserver 10.200.11.10" >>/etc/resolv.conf
#echo "#nameserver 10.200.11.11" >>/etc/resolv.conf
#echo "" >>/etc/resolv.conf
######################################################################################
cd $EXEC_DIR
# ----------------------------------------------------------------------
# Fire it up
# ----------------------------------------------------------------------
APP_LOG="$EXEC_LOG"/"`date +%Y%m%d%H%M%S`""`echo $APP_NAME |tr [:upper:] [:lower:]`"".log"

StartCommand="java -DAPPNAME=$APP_NAME -Xms$XMS -Xmx$XMX $MaxRAM $dashDparameters -classpath $EXEC_CPATH -jar  /usr/src/idmed/SIFMOZ-Backend.war &"
cd $EXEC_DIR
echo "Going to execute: $StartCommand" >>$APP_LOG
$StartCommand >>$APP_LOG 2>&1
sleep 120
#------------------------------------------------------
