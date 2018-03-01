FROM ubuntu:17.10
MAINTAINER Jason Bean <taddeusz@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini

RUN apt-get update \
    && apt-get install -y --no-install-recommends locales \
    && locale-gen en_US.UTF-8 \
    && apt-get install -y --no-install-recommends software-properties-common curl wget apt-transport-https \
    && curl -SL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add - \
    && sh -c 'echo "deb https://download.sublimetext.com/ apt/stable/" >> /etc/apt/sources.list.d/sublime-text.list' \
    # && add-apt-repository -y ppa:gnome-terminator/ppa/ubuntu/dists/artful/main \
    && add-apt-repository ppa:libreoffice/libreoffice-5-4 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        supervisor \
        zsh pwgen sudo vim-tiny nano zip unzip \
        net-tools iputils-ping traceroute dnsutils telnet ssh \
        lxde x11vnc xvfb terminator\
        gtk2-engines-murrine ttf-ubuntu-font-family \
        libreoffice mediainfo-gui vlc \
        default-jre libfaac0 \
        build-essential \
        mesa-utils libgl1-mesa-dri \
        gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine pinta \
        dbus-x11 x11-utils pulseaudio \
        libnotify4 libgconf-2-4 libsecret-1-0 git \
    && chmod +x /bin/tini \
    && apt-get autoclean \
    && apt-get autoremove \
    && mkdir -p /documents

ENV SUBLIME_VERSION 3143
RUN apt-get install -y --no-install-recommends sublime-text=${SUBLIME_VERSION}

ENV CHROME_VERSION 64.0.3282.140-1
RUN apt-get install -y --no-install-recommends google-chrome-stable=${CHROME_VERSION} \
    && sed -i 's/\bgoogle-chrome-stable\b/& --no-sandbox/' /usr/share/applications/google-chrome.desktop

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

ADD image /
ADD default.pa /etc/pulse/default.pa

ENV VSCODE_VERSION=v1.20
RUN wget -O vscode-amd64.deb  https://go.microsoft.com/fwlink/?LinkID=760868 \
    && dpkg -i vscode-amd64.deb \
    && rm vscode-amd64.deb

ENV SAGE_VERSION=9.1.7
ENV SAGE_BUILD=581
RUN wget -O sagetv-client.deb https://bintray.com/opensagetv/sagetv/download_file?file_path=sagetv%2F${SAGE_VERSION}.${SAGE_BUILD}%2Fsagetv-client_${SAGE_VERSION}_amd64.deb \
    && dpkg -i sagetv-client.deb \
    && rm sagetv-client.deb
ADD sageclient.sh /opt/sagetv/client/sageclient.sh
RUN chmod +x /opt/sagetv/client/sageclient.sh

VOLUME ["/config"]
VOLUME ["/documents"]

EXPOSE 5900
EXPOSE 4713
WORKDIR /config
ENV HOME=/config \
    SHELL=/usr/bin/zsh
ENTRYPOINT ["/startup.sh"]
