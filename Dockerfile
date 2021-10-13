ARG GO_VERSION="1.14.12"
ARG SINGULARITY_VERSION="3.8.2"
ARG TOMCAT_REL="9"
ARG TOMCAT_VERSION="9.0.52"
ARG GUACAMOLE_VERSION="1.3.0"

FROM jupyter/base-notebook:python-3.7.6

USER root

# Install base image dependancies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        locales \
        sudo \
        wget \
        ca-certificates \
        make \
        gcc \
        g++ \
        openjdk-11-jre \
        libpng-dev \
        libjpeg-turbo8-dev \
        libcairo2-dev \
        libtool-bin \
        libossp-uuid-dev \
        libwebp-dev \
        lxde \
        openssh-server \
        libpango1.0-dev \
        libssh2-1-dev \
        libssl-dev \
        openssh-server \
        libvncserver-dev \
        libxt6 \
        xauth \
        xorg \
        freerdp2-dev \
        xrdp \
        xauth \
        xorg \
        xorgxrdp \
        tigervnc-standalone-server \
        tigervnc-common \
        lxterminal \
        lxrandr \
        curl \
        gpg \
        software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Apache Tomcat
ARG TOMCAT_REL
ARG TOMCAT_VERSION
RUN wget https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_REL}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -P /tmp \
    && tar -xf /tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /tmp \
    && mv /tmp/apache-tomcat-${TOMCAT_VERSION} /usr/local/tomcat \
    && mv /usr/local/tomcat/webapps /usr/local/tomcat/webapps.dist \
    && mkdir /usr/local/tomcat/webapps \
    && sh -c 'chmod +x /usr/local/tomcat/bin/*.sh'

# Install Apache Guacamole
ARG GUACAMOLE_VERSION
WORKDIR /etc/guacamole
RUN wget "https://apache.mirror.digitalpacific.com.au/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-1.3.0.war" -O /usr/local/tomcat/webapps/ROOT.war \
    && wget "https://apache.mirror.digitalpacific.com.au/guacamole/${GUACAMOLE_VERSION}/source/guacamole-server-1.3.0.tar.gz" -O /etc/guacamole/guacamole-server-${GUACAMOLE_VERSION}.tar.gz \
    && tar xvf /etc/guacamole/guacamole-server-${GUACAMOLE_VERSION}.tar.gz \
    && cd /etc/guacamole/guacamole-server-${GUACAMOLE_VERSION} \
    && ./configure --with-init-dir=/etc/init.d \
    && make \
    && make install \
    && ldconfig \
    && rm -r /etc/guacamole/guacamole-server-${GUACAMOLE_VERSION}*

# Create Guacamole configurations
RUN echo "user-mapping: /etc/guacamole/user-mapping.xml" > /etc/guacamole/guacamole.properties \
    && touch /etc/guacamole/user-mapping.xml
COPY --chown=root:root user-mapping.xml /etc/guacamole/user-mapping.xml

# Set tomcat to port 8888
RUN sed -i 's/8080/8888/g' /usr/local/tomcat/conf/server.xml

# Create user account with password-less sudo abilities and vnc user
RUN addgroup jovyan \
    && /usr/bin/printf '%s\n%s\n' 'password' 'password'| passwd jovyan \
    && echo "jovyan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && mkdir /home/jovyan/.vnc \
    && chown jovyan /home/jovyan/.vnc \
    && /usr/bin/printf '%s\n%s\n%s\n' 'password' 'password' 'n' | su jovyan -c vncpasswd

# create a user, since we don't want to run as root
# RUN useradd -m jovyan
ENV HOME=/home/jovyan
WORKDIR $HOME

USER root
COPY simpleserver8080 /opt/simpleserver8080
RUN chmod +x /opt/simpleserver8080
COPY simpleserver8888 /opt/simpleserver8888
RUN chmod +x /opt/simpleserver8888

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh
RUN chown -R jovyan:root /usr/local/tomcat

# RUN mv /usr/local/tomcat/webapps /usr/local/tomcat/webapps.new
# RUN mv /usr/local/tomcat/webapps.dist /usr/local/tomcat/webapps

USER jovyan
EXPOSE 8888

ENTRYPOINT ["/opt/entrypoint.sh"]
