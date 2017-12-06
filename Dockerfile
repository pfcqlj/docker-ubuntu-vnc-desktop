FROM ubuntu:16.04
MAINTAINER Doro Wu <fcwu.tw@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
ADD image /

RUN apt-get update \ 
    && apt-get install -y --no-install-recommends software-properties-common curl wget \
    && sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list" \
    && curl -SL http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key | apt-key add - \
    && curl -SL http://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        supervisor \
        openssh-server pwgen sudo vim-tiny nano zip unzip \
        net-tools iputils-ping traceroute dnsutils telnet \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        libreoffice google-chrome-stable \
        nginx \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine pinta arc-theme \
        dbus-x11 x11-utils pulseaudio \
        libnotify4 libgconf-2-4 libsecret-1-0 git \
    && chmod +x /bin/tini \
    && pip install --upgrade pip \
    && pip install setuptools wheel \
    && pip install -r /usr/lib/web/requirements.txt \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i 's/\/root/\/config/g' /etc/passwd \
    && sed -i 's/\/root/\/config/g' /etc/passwd- \
    && sed -i 's/\bgoogle-chrome-stable\b/& --no-sandbox/' /usr/share/applications/google-chrome.desktop \
    && mkdir -p /documents

ADD default.pa /etc/pulse/default.pa

ENV VSCODE_VERSION=v1.18.1
RUN wget -O vscode-amd64.deb  https://go.microsoft.com/fwlink/?LinkID=760868 \
    && dpkg -i vscode-amd64.deb \
    && rm vscode-amd64.deb

VOLUME ["/config"]
VOLUME ["/documents"]

EXPOSE 5900
EXPOSE 4713
EXPOSE 80
WORKDIR /config
ENV HOME=/home/ubuntu \
    SHELL=/bin/bash
ENTRYPOINT ["/startup.sh"]
