# 
# Pull base image
# ---------------
FROM    ubuntu as base

MAINTAINER liaobaikai<baikai.liao@qq.com>
LABEL   org.opencontainers.image.authors="liaobaikai"

ENV     DM_BASE=/opt/dm \
        DM_HOME=/opt/dm/product/8/db_1 \
        DM_DATADIR=/opt/dm/dmdata/8 \
        INSTALL_DIR=/opt/dm/install \
        INSTALL_FILE_1=DMInstall.bin \
        INI_PARAM_FILE=/home/dmdba/dm_auto_install.xml
        

# 
# create group and dmdba user .. and make directory
# ---------------
RUN 	groupadd -g 12349 dinstall \
    	&& useradd -u 12345 -g dinstall -m -d /home/dmdba -s /bin/bash dmdba \
    	&& mkdir -p $DM_HOME $DM_DATADIR $INSTALL_DIR \
        && chown -R dmdba:dinstall $DM_BASE \
        && chmod 777 $DM_DATADIR


USER 	dmdba
WORKDIR /home/dmdba

RUN	printf "\n\n" >> .profile \
        && printf "DM_BASE=$DM_BASE\n" >> .profile \
        && printf "DM_HOME=$DM_HOME\n" >> .profile \
        && printf "DM_DATADIR=$DM_DATADIR\n" >> .profile \
        && printf 'PATH=$PATH:$DM_HOME/bin\n' >> .profile \
        && printf 'export PATH DM_BASE DM_HOME DM_DATADIR\n' >> .profile \
        && printf "\n" >> .profile 



#############################################
# -------------------------------------------
# Start new stage for installing the database
# -------------------------------------------
#############################################
FROM    base as builder 

COPY    $INSTALL_FILE_1 $INSTALL_DIR

USER    root
### init paramter file...
RUN     printf '<?xml version="1.0"?>\n' > $INI_PARAM_FILE \
        && printf '<DATABASE>\n' >> $INI_PARAM_FILE \
        && printf '    <!--安装数据库的语言配置，安装中文版配置 ZH，英文版配置 EN，不区分大小写。不允许为空。 -->\n' >> $INI_PARAM_FILE \
        && printf '    <LANGUAGE>en</LANGUAGE>\n' >> $INI_PARAM_FILE \
        && printf '    <!--安装程序的时区配置，默认值为+08:00，范围:-12:59 ~ +14:00 --> \n' >> $INI_PARAM_FILE \
        && printf '    <TIME_ZONE>+08:00</TIME_ZONE>\n' >> $INI_PARAM_FILE \
        && printf '    <!-- key 文件路径 --> \n' >> $INI_PARAM_FILE \
        && printf '    <KEY></KEY>\n' >> $INI_PARAM_FILE \
        && printf '    <!--安装程序组件类型，取值 0、1、2，0 表示安装全部，1 表示安装服务器，2 表示安装客户 端。默认为 0。 -->\n' >> $INI_PARAM_FILE \
        && printf '    <INSTALL_TYPE>0</INSTALL_TYPE>\n' >> $INI_PARAM_FILE \
        && printf '    <!--安装路径，不允许为空。 --> \n' >> $INI_PARAM_FILE \
        && printf "    <INSTALL_PATH>$DM_HOME</INSTALL_PATH>\n" >> $INI_PARAM_FILE \
        && printf '    <!--是否初始化库，取值 Y/N、y/n，不允许为空。 --> \n' >> $INI_PARAM_FILE \
        && printf '    <INIT_DB>N</INIT_DB>\n' >> $INI_PARAM_FILE \
        && printf '    <!--是否创建数据库实例的服务，值 Y/N y/n，不允许为空，不初始化数据库将忽略此节点。 非 root 用户不能创建数据库服务。 -->\n' >> $INI_PARAM_FILE \
        && printf '    <CREATE_DB_SERVICE>N</CREATE_DB_SERVICE>\n' >> $INI_PARAM_FILE \
        && printf '    <!--是否启动数据库，值 Y/N y/n，不允许为空，不创建数据库服务将忽略此节点。 -->\n' >> $INI_PARAM_FILE \
        && printf '    <STARTUP_DB_SERVICE>N</STARTUP_DB_SERVICE>\n' >> $INI_PARAM_FILE \
        && printf '</DATABASE>\n' >> $INI_PARAM_FILE \
        ############################
        # install database
        ############################
        && $INSTALL_DIR/$INSTALL_FILE_1 -q $INI_PARAM_FILE \
        && rm -rf $INSTALL_DIR \
        && echo "$DM_HOME/bin" >> /etc/ld.so.conf && ldconfig \
        && $DM_HOME/bin/dminit PATH=$DM_DATADIR DB_NAME=dmdb INSTANCE_NAME=baika CASE_SENSITIVE=y CHARSET=1

#############################################
# -------------------------------------------
# Start new layer for database runtime
# -------------------------------------------
#############################################
FROM    base

USER    dmdba
WORKDIR /home/dmdba
COPY    --chown=dmdba:dinstall --from=builder $DM_BASE $DM_BASE

RUN     cp $DM_HOME/bin/service_template/DmService $DM_HOME/bin/DmService \
        && sed -i 's#INI_PATH=%INI_PATH%#INI_PATH=$DM_DATADIR/dmdb/dm.ini#' $DM_HOME/bin/DmService

USER    root
WORKDIR /
RUN     printf "$DM_HOME/bin/DmService start\n/bin/bash\n" > /entrypoint.sh \
        && echo "$DM_HOME/bin" >> /etc/ld.so.conf && ldconfig

HEALTHCHECK --interval=1m --start-period=5m \
        CMD $DM_HOME/bin/DmService status | grep -E "DmService \(pid [0-9]*\) is running." || exit 1


EXPOSE  5236
CMD     ["sh", "/entrypoint.sh"]
