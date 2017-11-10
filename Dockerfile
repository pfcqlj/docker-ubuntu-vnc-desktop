FROM ubuntu:16.04
MAINTAINER Doro Wu <fcwu.tw@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's#http://archive.ubuntu.com/#http://tw.archive.ubuntu.com/#' /etc/apt/sources.list

# built-in packages
RUN apt-get update
RUN apt-get install -y --no-install-recommends software-properties-common curl wget
RUN sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list" \
    && curl -SL http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key | apt-key add - \
    && add-apt-repository ppa:fcwu-tw/ppa
RUN apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        supervisor \
        openssh-server pwgen sudo vim-tiny nano \
        net-tools iputils-ping traceroute dnsutils \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        libreoffice firefox \
        fonts-wqy-microhei \
        language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant libreoffice-l10n-zh-tw \
        nginx \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine pinta arc-theme \
        dbus-x11 x11-utils

# tini for subreap                                   
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

ADD image /
RUN pip install setuptools wheel && pip install -r /usr/lib/web/requirements.txt

# install vscode
ENV VSCODE_VERSION v1.18.0
RUN apt-get -y install libnotify4 libgconf-2-4 libsecret-1-0
RUN wget -O vscode-amd64.deb  https://go.microsoft.com/fwlink/?LinkID=760868 \
    && dpkg -i vscode-amd64.deb \
    && rm vscode-amd64.deb

# cleanup
RUN apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/\/root/\/config/g' /etc/passwd && \
    sed -i 's/\/root/\/config/g' /etc/passwd-

RUN mkdir -p /documents
VOLUME ["/config"]
VOLUME ["documents"]

EXPOSE 5900
EXPOSE 80
WORKDIR /config
ENV HOME=/home/ubuntu \
    SHELL=/bin/bash
ENTRYPOINT ["/startup.sh"]
