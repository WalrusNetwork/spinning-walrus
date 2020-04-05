FROM alpine:3.11 AS openrc
RUN mkdir -p /lib/apk/db /run
RUN apk add --no-cache --initdb openrc

FROM alpine:3.11 AS kernel
RUN mkdir -p /lib/apk/db /run
RUN apk add --no-cache --initdb linux-virt virtualbox-guest-modules-virt

# documentation: https://github.com/linuxkit/linuxkit/blob/master/docs/metadata.md
FROM linuxkit/metadata:2dade7485ac60c765b16a34a42afc6431da938cf AS metadata

FROM alpine:3.11 AS install

USER root

# secrets
ARG GITLAB_OAUTH_TOKEN
ARG MAVEN_AUTHORIZATION_TOKEN
ARG VULTR_API_KEY
ARG GRAPHQL_TOKEN

# default ENVs
ARG GITLAB_CLONE_BASE_URL=https://oauth2:${GITLAB_OAUTH_TOKEN}@gitlab.com/WalrusNetwork
ARG MAVEN_CURL_CMD="curl -s -L -XGET -H 'Authorization: Basic ${MAVEN_AUTHORIZATION_TOKEN}'"
ARG MAVEN_BASE_URL=https://maven.walrus.gg/service/rest/v1/search/assets/download
ARG MAVEN_EXTENDED_PRIVATE_URL=${MAVEN_BASE_URL}?sort=version&repository=walrus-private&maven.groupId=network.walrus&maven.artifactId=
ARG MAVEN_EXTENDED_PUBLIC_URL=${MAVEN_BASE_URL}?sort=version&repository=walrus-public&maven.groupId=network.walrus&maven.artifactId=
ARG VULTR_CLI_VERSION=0.2.1

# don't want all the /etc stuff from openrc -- only tools
# https://pkgs.alpinelinux.org/contents?repo=main&page=2&arch=x86_64&branch=v3.11&name=openrc
COPY --from=openrc /lib/ /lib/
COPY --from=openrc /bin /bin
COPY --from=openrc /sbin /sbin
COPY --from=openrc /etc/ /etc/

# Need virtio modules for networking
COPY --from=kernel /lib/modules /lib/modules

# Copy kernel for later use
COPY --from=kernel /boot/vmlinuz-virt /vmlinuz

# Copy metadata from linuxkit
COPY --from=metadata /usr/bin/metadata /usr/bin/metadata

RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.11/community" >> /etc/apk/repositories
RUN mkdir -p /lib/apk/db /run
RUN apk add --update --no-cache --initdb alpine-baselayout apk-tools busybox ca-certificates util-linux \
    rng-tools dhcpcd openjdk8-jre e2fsprogs curl jq moreutils findutils supervisor nano openssh \
    wget go git
RUN wget --quiet https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

RUN apk add netdata --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
# set netdata to listen to all interfaces
RUN sed -i 's/localhost/0.0.0.0/' /etc/netdata/netdata.conf

RUN echo "Welcome to Spinning Walrus!" > /etc/motd
RUN echo "tty0::respawn:/sbin/agetty -a root -L tty0 38400 vt100" > /etc/inittab
RUN echo "ttyS0::respawn:/sbin/agetty -a root -L ttyS0 115200 vt100" >> /etc/inittab

# create data and minecraft directories
RUN mkdir -p /data /minecraft

# get vultr CLI
RUN wget --quiet https://github.com/vultr/vultr-cli/releases/download/v${VULTR_CLI_VERSION}/vultr-cli_${VULTR_CLI_VERSION}_linux_64-bit.tar.gz -O vultr.tar.gz
RUN tar xzf vultr.tar.gz -C /usr/bin && rm vultr.tar.gz

WORKDIR /minecraft
RUN git clone -b private ${GITLAB_CLONE_BASE_URL}/maps/maps.git
RUN git clone https://github.com/WalrusNetwork/translations.git
RUN git clone ${GITLAB_CLONE_BASE_URL}/ux-ui/minecraft-ui.git
RUN git clone ${GITLAB_CLONE_BASE_URL}/infrastructure/config.git

WORKDIR /minecraft/config
RUN ash -c "${MAVEN_CURL_CMD} '${MAVEN_EXTENDED_PUBLIC_URL}sportpaper&maven.extension=jar' -o 'sportpaper.jar'"

WORKDIR /minecraft/config/plugins
RUN ash -c "${MAVEN_CURL_CMD} 'http://maven.walrus.gg/repository/walrus-private/network/walrus/ubiquitous-bukkit/1.0.0-SNAPSHOT/ubiquitous-bukkit-1.0.0-20200324.112751-10.jar' -o 'ubiq.jar'"
#RUN ash -c "${MAVEN_CURL_CMD} '${MAVEN_EXTENDED_PRIVATE_URL}ubiquitous-bukkit&maven.extension=jar' -o 'ubiq.jar'"
RUN ash -c "${MAVEN_CURL_CMD} '${MAVEN_EXTENDED_PRIVATE_URL}walrus-visor&maven.extension=jar' -o 'walrus-visor.jar'"
RUN ash -c "${MAVEN_CURL_CMD} '${MAVEN_EXTENDED_PRIVATE_URL}games-core&maven.extension=jar' -o 'games-core.jar'"
RUN ash -c "${MAVEN_CURL_CMD} '${MAVEN_EXTENDED_PRIVATE_URL}nerve-bukkit&maven.extension=jar' -o 'nerve-bukkit.jar'"

WORKDIR /minecraft/config/plugins/GameManager
RUN mkdir -p components
WORKDIR /minecraft/config/plugins/GameManager/components
RUN ash -c "${MAVEN_CURL_CMD} '${MAVEN_EXTENDED_PRIVATE_URL}games-octc&maven.extension=jar' -o 'games-octc.jar'"

# Copy local files
COPY files /

# harden SSH security and fix SSH
RUN sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
RUN sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
RUN chmod 0700 /root/.ssh
RUN sed -i 's/root:!/root:*/' /etc/shadow
RUN chmod 600 /root/.ssh/authorized_keys

# build minecraft checker
RUN go build -o /usr/bin/minecraft-checker /minecraft-checker.go
# delete not needed packages
RUN apk del --update --no-cache go git wget

# Deleted cached packages and minecraft checker source file
RUN rm -rf /var/cache/apk/* /minecraft-checker.go

RUN ash -c "echo 'VULTR_API_KEY="${VULTR_API_KEY}"' >> /etc/conf.d/minecraft-sleep.default"
RUN ash -c "echo 'GRAPHQL_TOKEN="${GRAPHQL_TOKEN}"' >> /etc/conf.d/status-reporter"