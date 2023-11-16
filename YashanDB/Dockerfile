# 
# Pull base image
# ---------------
FROM    oraclelinux:7.9 as base

MAINTAINER liaobaikai<baikai.liao@qq.com>
LABEL   org.opencontainers.image.authors="liaobaikai"

ENV     YASDB_HOME=/home/yashan/yashandb/yasdb_home \
        YASDB_DATA=/home/yashan/yashandb/yasdb_data \
        INSTALL_DIR=/home/yashan/install \
        INSTALL_FILE_1=yashandb-personal-23.1.1.100-linux-x86_64.tar.gz
        

# 
# create user .. and make directory
# ---------------
RUN     groupadd -g 12349 yashan \
        && useradd -u 12345 -g yashan -m -d /home/yashan -s /bin/bash yashan \
        && mkdir -p /home/yashan/yashandb \
        && chown -R yashan:yashan /home/yashan \
        && yum install -y net-tools


#USER   yashan
#WORKDIR /home/yashan

RUN     printf "YASDB_HOME=/home/yashan/yashandb/yasdb_home\n" >> /etc/profile.d/yashan.sh \
        && printf "YASDB_DATA=/home/yashan/yashandb/yasdb_data\n" >> /etc/profile.d/yashan.sh \
        && printf 'PATH=$PATH:$YASDB_HOME/bin\n' >> /etc/profile.d/yashan.sh \
        && printf 'LD_LIBRARY_PATH=$YASDB_HOME/lib\n' >> /etc/profile.d/yashan.sh \
        && printf 'export PATH YASDB_HOME YASDB_DATA LD_LIBRARY_PATH\n' >> /etc/profile.d/yashan.sh \
        && cat /etc/profile.d/yashan.sh >> /home/yashan/.bashrc



#############################################
# -------------------------------------------
# Start new stage for installing the database
# -------------------------------------------
#############################################
FROM    base as builder 

USER    root
COPY    $INSTALL_FILE_1 /


############################
# install database
############################
USER    yashan
WORKDIR /home/yashan
RUN     source /home/yashan/.bash_profile \
        && mkdir $INSTALL_DIR \
        && chown -R yashan:yashan /home/yashan \
        && cd $INSTALL_DIR \
        && tar -zvxf /$INSTALL_FILE_1 \
        && sh -x $INSTALL_DIR/scripts/install.sh

#############################################
# -------------------------------------------
# Start new layer for database runtime
# -------------------------------------------
#############################################
FROM    base

USER    yashan
WORKDIR /home/yashan
COPY    --chown=yashan:yashan --from=builder $YASDB_HOME $YASDB_HOME 
COPY    entrypoint.sh   /

HEALTHCHECK --interval=1m --start-period=5m \
        CMD netstat -anp | egrep "0.0.0.0:1688.*LISTEN" || exit 1


EXPOSE  1688
CMD     ["sh", "/entrypoint.sh"]
