FROM alpine:edge
MAINTAINER Julian Xhokaxhiu <info at julianxhokaxhiu dot com>

# Environment variables
#######################

ENV DATA_DIR /srv/data
ENV APP_DIR /opt
ENV ANDROID_SDK_VERSION 24.4.1
ENV ANDROID_HOME $APP_DIR/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Configurable environment variables
####################################

# Your GMAIL Username of the account you want to use to download APKs
ENV GMAIL_ADDRESS "foobar@gmail.com"

# Your GMAIL Password of the account you want to use to download APKs
# It is highly suggested to use App Passwords. See https://support.google.com/accounts/answer/185833?hl=en
ENV GMAIL_PASSWORD "my-awesome-password"

# To get your androidID, use *#*#8255#*#* on your phone to start Gtalk Monitor. The hex string listed after aid is your androidID.
ENV ANDROID_ID "abcd123456789"

# The Market language you want to target to download APKs
ENV GPLAYWEB_LANGUAGE "en-us"

# Create Volume entry points
############################

VOLUME $DATA_DIR

# Copy required files and fix permissions
#########################################

COPY src/* /root/

# Create missing directories
############################

RUN mkdir -p $DATA_DIR \
    && mkdir -p $APP_DIR

# Set the work directory
########################

WORKDIR /root

# Fix permissions
#################

RUN chmod 0644 * \
    && chmod 0755 *.sh

# Install required packages
##############################

RUN apk --update add --no-cache \
    supervisor \
    bash \
    python \
    python3 \
    libstdc++ \
    libgcc \
    zlib \
    ncurses5 \
    libffi \
    openssl \
    libjpeg-turbo \
    openjdk8 \
    caddy

# Required by GPlayWeb and FDroid Server
RUN apk --update add --no-cache --virtual .build-deps \
    git \
    wget \
    gcc \
    musl-dev \
    python-dev \
    py-pip \
    python3-dev \
    libffi-dev \
    libjpeg-turbo-dev \
    zlib-dev \
    openssl-dev

# Install Android SDK
#####################
RUN cd $APP_DIR \
    && wget https://dl.google.com/android/android-sdk_r${ANDROID_SDK_VERSION}-linux.tgz \
    && echo "725bb360f0f7d04eaccff5a2d57abdd49061326d  android-sdk_r${ANDROID_SDK_VERSION}-linux.tgz" | sha1sum -c \
    && tar xzf android-sdk_r${ANDROID_SDK_VERSION}-linux.tgz \
    && rm android-sdk_r${ANDROID_SDK_VERSION}-linux.tgz \
    && echo 'y' | android update sdk --no-ui --filter platform-tools,build-tools-22.0.1

# Install FDroid Server
#######################

RUN pip3 install fdroidserver

# Install GPlayWeb
##################

RUN cd $APP_DIR \
    && git clone https://github.com/fxaguessy/gplayweb.git gplayweb \
    && cd $APP_DIR/gplayweb \
    && pip install --no-cache-dir -r requirements.txt

# Cleanup
#########

RUN find /usr/local \
      \( -type d -a -name test -o -name tests \) \
      -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
      -exec rm -rf '{}' + \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

# Replace default configurations
################################
RUN rm /etc/supervisord.conf \
    && mv /root/supervisord.conf /etc \
    && mv /root/gplayweb.conf /etc \
    && mv /root/Caddyfile /etc

# Allow redirection of stdout to docker logs
############################################
RUN ln -sf /proc/1/fd/1 /var/log/docker.log

# Expose required ports
#######################

EXPOSE 8080
EXPOSE 8888

# Change Shell
##############
SHELL ["/bin/bash", "-c"]

# Set the entry point to init.sh
###########################################

ENTRYPOINT /root/init.sh
