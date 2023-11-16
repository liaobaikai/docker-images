#!/bin/bash

source ~/.bash_profile

YASDB_DATA=${YASDB_DATA:-/home/yashan/yashandb/yasdb_data}
YASDB_HOME=/home/yashan/yashandb/yasdb_home


if [ ! -d $YASDB_DATA -o $(ls $YASDB_DATA | wc -l) -eq 0 ]; then
        ### create directory
        mkdir -p "$YASDB_DATA"/{config,data,dbfiles,instance,archive,local_fs,log/{run,audit,trace,alarm,alert,listener},diag/{metadata,hm,blackbox}}

        ### create database
        $YASDB_HOME/scripts/initDB.sh

        rm $YASDB_DATA/instance/yasdb.pwd 2>/dev/null
        $YASDB_HOME/bin/yaspwd file=$YASDB_DATA/instance/yasdb.pwd password=${YASDB_SYS_PASSWORD:-yasdb_123}

fi


$YASDB_HOME/bin/yasdb open &

tail -9999f $YASDB_DATA/log/run/run.log
