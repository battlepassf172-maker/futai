FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Pasul 1: Instalăm tot ce este necesar pentru ca sistemul să funcționeze
RUN apt update -y && apt install --no-install-recommends -y \
    gnupg ca-certificates software-properties-common \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    sudo xterm vim net-tools curl wget git tzdata dbus-x11 \
    x11-utils x11-xserver-utils x11-apps openssh-server \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Pasul 2: Acum că avem gnupg și ca-certificates, adăugarea PPA-ului va funcționa
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox && \
    apt update -y && apt install -y firefox xubuntu-icon-theme && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Pasul 3: Configurații finale
RUN touch /root/.Xauthority && \
    mkdir -p /var/run/sshd && \
    echo 'root:rudyMaFut4123' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 5901 6080 22

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
