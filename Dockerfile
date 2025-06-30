#
# TinyMediaManager Dockerfile
#
FROM jlesage/baseimage-gui:alpine-3.22-v4

# Define software versions.
ARG TMM_VERSION_MAJOR=5
ARG TMM_VERSION=5.1.7

# Define software download URLs.
#ARG TMM_URL=https://release.tinymediamanager.org/v3/dist/tmm_${TMM_VERSION}_linux.tar.gz
ARG TMM_URL=https://release.tinymediamanager.org/v${TMM_VERSION_MAJOR}/dist/tinyMediaManager-${TMM_VERSION}-linux-amd64.tar.xz
# Define working directory.
WORKDIR /tmp



# Download TinyMediaManager
RUN \
    mkdir -p /defaults && \
    wget ${TMM_URL} -O /defaults/tmm.tar.gz

# Download and install Oracle JRE.
# NOTE: This is needed only for the 7-Zip-JBinding workaround.
RUN \
    wget -O /etc/apk/keys/amazoncorretto.rsa.pub  https://apk.corretto.aws/amazoncorretto.rsa.pub && \
    echo "https://apk.corretto.aws/" >> /etc/apk/repositories && \
    apk update && \
    apk add amazon-corretto-21


# Install dependencies.
RUN \
    apk add --no-cache \
        # For the 7-Zip-JBinding workaround, Oracle JRE is needed instead of
        # the Alpine Linux's openjdk native package.
        # The libstdc++ package is also needed as part of the 7-Zip-JBinding
        # workaround.
        #openjdk8-jre \
        ffmpeg \
        gcompat \
        libstdc++ \
        libmediainfo \
        ttf-dejavu \
        bash

# Maximize only the main/initial window.
# It seems this is not needed for TMM 3.X version.
#RUN \
#    sed-patch 's/<application type="normal">/<application type="normal" title="tinyMediaManager \/ 3.0.2">/' \
#        /etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://gitlab.com/tinyMediaManager/tinyMediaManager/-/raw/devel/AppBundler/tmm.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY VERSION /

RUN \
    chmod +x /startapp.sh && \
    chmod +x /etc/cont-init.d/tmm.sh

# Set environment variables.
ENV APP_NAME="TinyMediaManager" \
    S6_KILL_GRACETIME=8000

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/media"]

# Metadata.
RUN set-cont-env APP_NAME "tinymediamanager"
#LABEL \
      #org.label-schema.name="tinymediamanager" \
      #org.label-schema.description="Docker container for TinyMediaManager" \
      #org.label-schema.version="unknown" \
      #org.label-schema.vcs-url="https://github.com/romancin/tmm-docker" \
      #org.label-schema.schema-version="1.0"
