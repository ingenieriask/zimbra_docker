# vi:ft=dockerfile
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Basic Packages
RUN apt-get update
RUN apt-get -qq dist-upgrade -y
RUN apt-get -qq autoremove -y
RUN apt-get -qq install apt-utils -y
RUN apt-get -qq install -y ant
RUN apt-get -qq install -y ant-contrib
RUN apt-get -qq install -y build-essential
RUN apt-get -qq install -y curl
RUN apt-get -qq install -y debhelper
RUN apt-get -qq install -y dnsmasq
RUN apt-get -qq install -y dnsutils
RUN apt-get -qq install -y gettext
RUN apt-get -qq install -y maven
RUN apt-get -qq install -y net-tools
RUN apt-get -qq install -y npm
RUN apt-get -qq install -y openssh-server
RUN apt-get -qq install -y python3
RUN apt-get -qq install -y python3-pip
RUN apt-get -qq install -y rsyslog
RUN apt-get -qq install -y software-properties-common
RUN apt-get -qq install -y vim
RUN apt-get -qq install -y wget
RUN apt-get -qq install -y perl
RUN apt-get -qq install -y apt-transport-https
RUN apt-get -qq install -y openssl
RUN apt-get -qq install -y make
RUN apt-get -qq install -y tar
RUN apt-get -qq install -y git perl ruby
RUN apt-get -qq install -y build-essential
RUN apt-get -qq install -y openjdk-8-jdk
RUN apt-get -qq install -y debhelper
RUN apt-get -qq install -y iproute2
RUN apt-get -qq install -y tzdata
# Trick build into skipping resolvconf as docker overrides for DNS
# This is currently required by our installer script. Hopefully be
# fixed soon.  The `zimbra-os-requirements` packages depends
# on the `resolvconf` package, and configuration of that is what
# is breaking install.sh
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections
RUN mkdir -p /tmp/release
RUN mkdir -p /zimbra
RUN wget https://files.zimbra.com/downloads/8.8.15_GA/zcs-8.8.15_GA_3869.UBUNTU18_64.20190918004220.tgz -O /tmp/zcs.tgz
RUN     tar xzvf /tmp/zcs.tgz -C /tmp/release --strip-components=1
RUN rm /tmp/zcs.tgz
RUN git clone https://github.com/ingenieriask/zimbra_docker.git /tmp/git
RUN cp -R /tmp/git/slash-zimbra-base/* /zimbra
WORKDIR /tmp/release
RUN chmod +x /zimbra/init && \
        groupadd -r -g 1000 zimbra && \
    useradd -r -g zimbra -u 1000 -b /opt -s /bin/bash zimbra && \
    sed -i.bak 's/checkRequired/# checkRequired/' install.sh && \
    ./install.sh -s -x --skip-upgrade-check --platform-override < /zimbra/software-install-responses && \
        rm -rf /tmp/release && \
        apt-get clean && \
        chmod +x /zimbra/init
WORKDIR /zimbra
CMD /zimbra/init
EXPOSE 22 25 80 110 143 443 465 587 993 995 7071 8443 9998 9999
