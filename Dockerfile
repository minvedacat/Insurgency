FROM centos:7

ENV APPID=237410
ENV APPDIR=/home/steamsrv/Insurgency
ENV APP_GAME_NAME insurgency
ENV APP_SERVER_PORT 27018
ENV APP_SERVER_MAXPLAYERS 24
ENV APP_SERVER_MAP market_coop
ENV APP_SERVER_NAME [CN]VEDACAT
ENV APP_SERVER_CONFI server.config

expose ${APP_SERVER_PORT}/udp
expose ${APP_SERVER_PORT}

## Packge Install CentOS 7:
RUN yum -y update && yum install -y \
    wget            \
    glibc.i686      \
    libgcc_s.so.1

## Create user for Steam server hosting
RUN useradd \
    -d /home/steamsrv   \   
    -m                  \
    -s /bin/bash        \
    steamsrv

## Install SteamCMD Centos 7
USER steamsrv
WORKDIR /home/steamsrv
RUN wget -O /home/steamsrv/steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz  &&\
    tar -xvzf /home/steamsrv/steamcmd_linux.tar.gz    &&\
    mkdir /home/steamsrv/insurgency
RUN /home/steamsrv/steamcmd.sh +login anonymous +force_install_dir "/home/steamsrv/insurgency" +app_update 237410 +quit

## Open Ports on server
USER root
# RUN firewall-cmd --zone=public --add-port=$APP_SERVER_PORT/tcp --permanent  &&\
#     firewall-cmd --zone=public --add-port=$APP_SERVER_PORT/tcp --permanent  &&\
#     firewall-cmd --reload

EXPOSE ${APP_SERVER_PORT}/udp
EXPOSE ${APP_SERVER_PORT}

USER steamsrv

COPY $APP_SERVER_CONFIG /home/steamsrv/insurgency/insurgency/cfg/server.cfg
# COPY /home/steamsrv/insurgency/insurgency/cfg/server.cfg.example /home/steamsrv/insurgency/insurgency/cfg/server.cfg
# RUN if ($APP_SERVER_CONFIG);                                \
#    then echo 'copy from your config file';  \
#    else cp /home/steamsrv/insurgency/insurgency/cfg/server.cfg.example /home/steamsrv/insurgency/insurgency/cfg/server.cfg

RUN echo export LD_LIBRARY_PATH=/home/steamsrv/insurgency:/home/steamsrv/insurgency/bin > /home/steamsrv/insurgency/insurgency_start.sh &&\
    echo /home/steamsrv/insurgency/srcds_linux -console -port $APP_SERVER_PORT +map market_coop +maxplayers 8 >> /home/steamsrv/insurgency/insurgency_start.sh &&\
    sh /home/steamsrv/insurgency/insurgency_start.sh