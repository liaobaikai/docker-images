# 
# Pull base image
# ---------------
FROM    ubuntu as base

MAINTAINER liaobaikai<baikai.liao@qq.com>
LABEL   org.opencontainers.image.authors="liaobaikai"

ENV     DM_HOME=/opt/dmdbms \
        DM_DATADIR=/opt/dmdbms/data \
        LD_LIBRARY_PATH=/lib64 \
        INSTALL_DIR=/opt/dm/install \
        INSTALL_FILE_1=DMInstall.bin \
        INI_PARAM_FILE=/home/dmdba/dm_auto_install.xml
        

# 
# create group and dmdba user .. and make directory
# ---------------
RUN     groupadd -g 12349 dinstall \
        && useradd -u 12345 -g dinstall -m -d /home/dmdba -s /bin/bash dmdba \
        && mkdir -p $DM_HOME \
        && chown -R dmdba:dinstall $DM_HOME


#############################################
# -------------------------------------------
# Start new stage for installing the database
# -------------------------------------------
#############################################
FROM    base as builder 

COPY    $INSTALL_FILE_1 /

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
        && /$INSTALL_FILE_1 -q $INI_PARAM_FILE \
        && rm -rf $DM_HOME/web \
        && rm -rf $DM_HOME/drivers \
        && rm -rf $DM_HOME/tool \
        && rm -rf $DM_HOME/uninstall* \
        && rm -rf $DM_HOME/jdk \
        && rm -rf $DM_HOME/jar \
        && rm -rf $DM_HOME/doc


#############################################
# -------------------------------------------
# Start new layer for database runtime
# -------------------------------------------
#############################################
FROM    base

USER    dmdba
WORKDIR /home/dmdba
COPY    --chown=dmdba:dinstall --from=builder $DM_HOME $DM_HOME
COPY    entrypoint.sh   /

RUN     cp $DM_HOME/bin/service_template/DmService $DM_HOME/bin/DmService \
        && sed -i 's#INI_PATH=%INI_PATH%#INI_PATH=$DM_DATADIR/dmdb/dm.ini#' $DM_HOME/bin/DmService

USER    root
WORKDIR /
RUN     ln -s $DM_HOME/bin/* /usr/bin && \
        ln -s $DM_HOME/bin/*.so /lib64

#HEALTHCHECK --interval=1m --start-period=5m \
#        CMD $DM_HOME/bin/DmService status | grep -E "DmService \(pid [0-9]*\) is running." || exit 1
#
#
USER    dmdba
WORKDIR /home/dmdba


EXPOSE  5236

CMD     ["sh", "/entrypoint.sh"]
