#!/bin/bash

getent passwd ubuntu > /dev/null
if [ $? -eq 2 ]; then
    useradd -d /config -s /usr/bin/zsh -U -G adm,sudo ubuntu
    echo "ubuntu:PASSWORD" | chpasswd
    mkdir -p /config/.config/pcmanfm/LXDE/
    cp -n /usr/share/doro-lxde-wallpapers/desktop-items-0.conf /config/.config/pcmanfm/LXDE/
fi
chown -R ubuntu:ubuntu /config

if [ -n "$VNC_PASSWORD" ]; then
    echo -n "$VNC_PASSWORD" > /.password1
    x11vnc -storepasswd $(cat /.password1) /.password2
    chmod 400 /.password*
    sed -i 's/^command=x11vnc.*/& -rfbauth \/.password2/' /etc/supervisor/conf.d/supervisord.conf
    export VNC_PASSWORD=
fi

exec /bin/tini -- /usr/bin/supervisord -n
