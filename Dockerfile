FROM node:8-alpine 

LABEL Author="MiGoller, mrproper, pschmitt & moeiscool"

ENV SHINOBI_SHA="24de55e45a688021aaede2872e1bc3cef660b1ca"

# Set environment variables to default values
# ADMIN_USER : the super user login name
# ADMIN_PASSWORD : the super user login password
# PLUGINKEY_MOTION : motion plugin connection key
# PLUGINKEY_OPENCV : opencv plugin connection key
# PLUGINKEY_OPENALPR : openalpr plugin connection key
ENV ADMIN_USER=admin@shinobi.video \
    ADMIN_PASSWORD=admin \
    CRON_KEY=fd6c7849-904d-47ea-922b-5143358ba0de \
    PLUGINKEY_MOTION=b7502fd9-506c-4dda-9b56-8e699a6bc41c \
    PLUGINKEY_OPENCV=f078bcfe-c39a-4eb5-bd52-9382ca828e8a \
    PLUGINKEY_OPENALPR=dbff574e-9d4a-44c1-b578-3dc0f1944a3c



RUN apk --update update && apk upgrade

# runtime dependencies
RUN apk add --update ffmpeg openrc gnutls x264 libssh2 tar xz bzip2 mysql-client

# Install ffmpeg static build version from cdn.shinobi.video
RUN wget https://cdn.shinobi.video/installers/ffmpeg-release-64bit-static.tar.xz \
 && tar xpvf ./ffmpeg-release-64bit-static.tar.xz -C ./ \
 && cp -f ./ffmpeg-3.3.4-64bit-static/ff* /usr/bin/ \
 && chmod +x /usr/bin/ff* \
 && rm -f ffmpeg-release-64bit-static.tar.xz \
 && rm -rf ./ffmpeg-3.3.4-64bit-static

RUN mkdir -p /config /tmp/shinobi

# Install build dependencies, fetch shinobi, and install
RUN apk add --virtual .build-dependencies \ 
  build-base \ 
  coreutils \ 
  nasm \
  python \
  make \
  pkgconfig \
  wget \
  freetype-dev \ 
  gnutls-dev \ 
  lame-dev \ 
  libass-dev \ 
  libogg-dev \ 
  libtheora-dev \ 
  libvorbis-dev \ 
  libvpx-dev \ 
  libwebp-dev \ 
  opus-dev \ 
  rtmpdump-dev \ 
  x264-dev \ 
  x265-dev \ 
  yasm-dev \
  && wget "https://gitlab.com/Shinobi-Systems/ShinobiCE/-/archive/master/ShinobiCE-master.tar.bz2?sha=$SHINOBI_SHA" -O /tmp/shinobi.tar.bz2 \
 && tar -xjpvf /tmp/shinobi.tar.bz2 -C /tmp/shinobi \
 && mv /tmp/shinobi/ShinobiCE-master /opt/shinobi \
 && rm -f /tmp/shinobi.tar.bz2 \
 && cd /opt/shinobi \
 && npm i npm@latest -g \
 && npm install pm2 -g \
 && npm install \
 && apk del --virtual .build-dependencies

# Copy code
COPY docker-entrypoint.sh pm2Shinobi.yml conf.sample.json super.sample.json /opt/shinobi/
RUN chmod +x /opt/shinobi/docker-entrypoint.sh

EXPOSE 8080

WORKDIR /opt/shinobi

ENTRYPOINT ["/opt/shinobi/docker-entrypoint.sh"]

CMD ["pm2-docker", "pm2Shinobi.yml"]
