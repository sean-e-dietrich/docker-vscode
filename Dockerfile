FROM consol/ubuntu-xfce-vnc

ENV DEBIAN_FRONTEND=noninteractive \
    VSC_DL_URL=https://go.microsoft.com/fwlink/?LinkID=760868

USER 0

RUN apt-get update && \
    apt-get install -y \
    openssl \
    nodejs \
    npm \
    git \
    wget \
    libgtk2.0 \
    libgconf-2-4 \
    libasound2 && \
    npm install -g typescript && \
    wget -O /tmp/vsc.deb $VSC_DL_URL && \
    apt install -y /tmp/vsc.deb && \
    rm -rf /tmp/vsc.deb

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY startup.sh /opt/startup.sh

USER 1000

RUN mkdir -p $HOME/.vscode/extensions $HOME/.config/Code/User && \
    touch $HOME/.config/Code/storage.json

# Starter script
ENTRYPOINT ["/opt/startup.sh"]

# By default, launch supervisord to keep the container running.
CMD ["supervisord"]
