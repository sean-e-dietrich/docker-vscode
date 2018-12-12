FROM consol/ubuntu-xfce-vnc

ENV DEBIAN_FRONTEND=noninteractive \
    VSC_DL_URL=https://go.microsoft.com/fwlink/?LinkID=760868

USER root

RUN apt-get update && \
    apt-get install -y \
    openssl \
    nodejs \
    npm \
    git \
    wget \
    curl \
    openssh-client \
		openssh-serve \
    libgtk2.0 \
    libgconf-2-4 \
    libasound2 && \
    npm install -g typescript && \
    wget -O /tmp/vsc.deb $VSC_DL_URL && \
    apt install -y /tmp/vsc.deb && \
    rm -rf /tmp/vsc.deb

RUN set -xe; \
	# Create a regular user/group "docker" (uid = 1000, gid = 1000 ) with access to sudo
	groupadd docker -g 1000; \
	useradd -m -s /bin/bash -u 1000 -g 1000 -G sudo -p docker docker; \
	echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY --chown=docker:docker config/.ssh /home/docker/.ssh
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY startup.sh /opt/startup.sh

ENV GOSU_VERSION=1.10 \
    GOMPLATE_VERSION=3.0.0
RUN set -xe; \
	# Install gosu and give access to the docker user primary group to use it.
	# gosu is used instead of sudo to start the main container process (pid 1) in a docker friendly way.
	# https://github.com/tianon/gosu
	curl -fsSL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture)" -o /usr/local/bin/gosu; \
	chown root:"$(id -gn docker)" /usr/local/bin/gosu; \
	chmod +sx /usr/local/bin/gosu; \
	# gomplate (to process configuration templates in startup.sh)
	curl -fsSL https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_linux-amd64-slim -o /usr/local/bin/gomplate; \
	chmod +x /usr/local/bin/gomplate

# Configure sshd (for use PHPStorm's remote interpreters and tools integrations)
# http://docs.docker.com/examples/running_ssh_service/
RUN set -xe; \
	mkdir /var/run/sshd; \
	echo 'docker:docker' | chpasswd; \
	sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config; \
	# SSH login fix. Otherwise user is kicked off after login
	sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd; \
	echo "export VISIBLE=now" >> /etc/profile
ENV NOTVISIBLE "in users profile"

USER docker

RUN mkdir -p $HOME/.vscode/extensions $HOME/.config/Code/User && \
    touch $HOME/.config/Code/storage.json

# Starter script
ENTRYPOINT ["/opt/startup.sh"]

# By default, launch supervisord to keep the container running.
CMD ["supervisord"]
