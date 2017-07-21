FROM centos:7

ENV APPID=237410
ENV APPDIR=/home/steamsrv/Insurgency
ENV APP_GAME_NAME insurgency
ENV APP_SERVER_PORT 27018
ENV APP_SERVER_MAXPLAYERS 24
ENV APP_SERVER_MAP market_coop
ENV APP_SERVER_NAME [CN]VEDACAT

ADD server.cfg /home/steamsrv/server.cfg

expose ${APP_SERVER_PORT}/udp
expose ${APP_SERVER_PORT}

## Packge Install CentOS 7:
RUN yum -y update && -y install -y \
    wget        \
    glibc.i686  \
    libgcc_s.so.1

## Create user for Steam server hosting
RUN useradd \
    -d /home/steamsrv   \
    -m                  \
    -s /bin/bash        \
    steamsrv

## Install SteamCMD Centos 7
USER streamsrv
RUN wget -O /home/steamsrv/steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz  &&\
    tar -xvzf /home/steamsrv/steamcmd_linux.tar.gz    &&\
    mkdir /insurgency

WORKDIR /home/steamsrv
RUN /home/steamsrv/steamcmd.sh +login anonymous +force_install_dir "/insurgency" +app_update 237410 +quit

## Open Ports on server firewall
USER root
RUN firewall-cmd --zone=public --add-port=$APP_SERVER_PORT/tcp --permanent  &&\
    firewall-cmd --zone=public --add-port=$APP_SERVER_PORT/tcp --permanent  &&\
    firewall-cmd --reload

expose ${APP_SERVER_PORT}/udp
expose ${APP_SERVER_PORT}

USER streamsrv

RUN if ($APP_SERVER_CONFIG);                                \
    then server.cfg /insurgency/insurgency/cfg/server.cfg;  \
    else cp /insurgency/insurgency/cfg/server.cfg.example /insurgency/insurgency/cfg/server.cfg

RUN echo export LD_LIBRARY_PATH=/insurgency:/insurgency/bin > /insurgency/insurgency_start.sh &&\
    echo /insurgency/srcds_linux -console -port $APP_SERVER_PORT +map market_coop +maxplayers 8 >> /insurgency/insurgency_start.sh &&\
    sh /insurgency/insurgency_start.sh