#!/bin/bash

source ~/.profile

DM_DATADIR=${DM_DATADIR:-/opt/dmdbms/data}
DM_CASE_SENSITIVE=${CASE_SENSITIVE:-y}
DM_CHARSET=${DM_CHARSET:-1}


if [ ! -d $DM_DATADIR ]; then
        mkdir -p $DM_DATADIR
        chown -R dmdba:dinstall $DM_DATADIR

        export LD_LIBRARY_PATH=/opt/dmdbms/bin

        # init database...
        dminit PATH=$DM_DATADIR CASE_SENSITIVE=$DM_CASE_SENSITIVE CHARSET=$DM_CHARSET

        cp $DM_HOME/bin/service_template/DmService $DM_HOME/bin/DmService 
        sed -i 's#INI_PATH=%INI_PATH%#INI_PATH=$DM_DATADIR/DAMENG/dm.ini#' $DM_HOME/bin/DmService
fi


$DM_HOME/bin/DmService start

tail -9999f $DM_HOME/log/DmService.log
