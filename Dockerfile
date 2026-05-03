FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Pasul 1: Instalăm tot ce este necesar pentru ca sistemul să funcționeze
RUN apt update -y && apt install --no-install-recommends -y \
    gnupg ca-certificates software-properties-common \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    sudo xterm vim net-tools curl wget git tzdata dbus-x11 \
    x11-utils x11-xserver-utils x11-apps openssh-server \
    && apt clean && rm -rf /var/lib/apt/lists/*

# 2. Instalare Firefox (Metoda Manuală - Fără interogare API Launchpad)
RUN apt install -y gnupg && \
    # Adăugăm cheia GPG manual
    curl -fsSL https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x738BEB9321D1AAEC13EA9391AEBDF4819BE21867 | gpg --dearmor -o /usr/share/keyrings/mozilla-ppa.gpg && \
    # Adăugăm sursa PPA manual
    echo "deb [signed-by=/usr/share/keyrings/mozilla-ppa.gpg] https://ppa.launchpadcontent.net/mozillateam/ppa/ubuntu jammy main" > /etc/apt/sources.list.d/mozillateam.list && \
    # Setări priorități
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
