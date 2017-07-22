FROM centos:7

ENV APPID=237410
ENV APPDIR=/home/steamsrv/Insurgency
ENV APP_GAME_NAME insurgency
ENV APP_SERVER_PORT 27018
ENV APP_SERVER_MAXPLAYERS 24
ENV APP_SERVER_MAP market_coop
ENV APP_SERVER_NAME [CN]VEDACAT

expose ${APP_SERVER_PORT}/udp
expose ${APP_SERVER_PORT}

## Packge Install CentOS 7:
RUN yum -y update && yum install -y \
    wget        \
    glibc.i686  \
    libgcc_s.so.1

## Create user for Steam server hosting
RUN useradd \
    -d /home/steamsrv   \   
    -m                  \
    -s /bin/bash        \
    steamsrv            &&\
    chown steamsrv:user /home/steamsrv

## Install SteamCMD Centos 7
USER steamsrv
RUN wget -O /home/steamsrv/steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz  &&\
    tar -xvzf /home/steamsrv/steamcmd_linux.tar.gz    &&\
    mkdir /home/steamsrc/insurgency

WORKDIR /home/steamsrv
RUN /home/steamsrv/steamcmd.sh +login anonymous +force_install_dir "/home/steamsrc/insurgency" +app_update 237410 +quit

## Open Ports on server firewall
USER root
RUN firewall-cmd --zone=public --add-port=$APP_SERVER_PORT/tcp --permanent  &&\
    firewall-cmd --zone=public --add-port=$APP_SERVER_PORT/tcp --permanent  &&\
    firewall-cmd --reload

expose ${APP_SERVER_PORT}/udp
expose ${APP_SERVER_PORT}

USER steamsrv

RUN if ($APP_SERVER_CONFIG);                                \
    then server.cfg /home/steamsrc/insurgency/insurgency/cfg/server.cfg;  \
    else cp /home/steamsrc/insurgency/insurgency/cfg/server.cfg.example /home/steamsrc/insurgency/insurgency/cfg/server.cfg

RUN echo export LD_LIBRARY_PATH=/home/steamsrc/insurgency:/home/steamsrc/insurgency/bin > /home/steamsrc/insurgency/insurgency_start.sh &&\
    echo /home/steamsrc/insurgency/srcds_linux -console -port $APP_SERVER_PORT +map market_coop +maxplayers 8 >> /home/steamsrc/insurgency/insurgency_start.sh &&\
    sh /home/steamsrc/insurgency/insurgency_start.sh