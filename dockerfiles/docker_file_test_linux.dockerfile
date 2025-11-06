ARG VERSION="stable"
ARG UBUNTU_VERSION=24.04

#
# Build stage: install Linux deps
#
FROM ubuntu:${UBUNTU_VERSION} AS build

USER root
WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

# Install required deps for Flutter Linux build
RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        unzip \
        clang \
        cmake \
        ninja-build \
        pkg-config \
        libgtk-3-dev \
        liblzma-dev \
        xz-utils \
        libstdc++-12-dev \
        libglu1-mesa && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/apt/*

#
# Final stage: Flutter SDK + Linux deps
#
FROM plugfox/flutter:${VERSION} AS production

# Copy Linux deps from build image
COPY --from=build /usr /usr
COPY --from=build /lib /lib
COPY --from=build /etc /etc

# Enable Linux desktop support
RUN set -eux; \
    flutter config --enable-linux-desktop && \
    flutter precache --linux

# Optional: Validate the installation by building a test app
# Uncomment if you want to verify everything works during build
# RUN set -eux; \
#    cd /tmp && \
#    flutter create --pub --platforms=linux --project-name test_app -t app test_app && \
#    cd test_app && \
#    flutter pub get && \
#    flutter build linux --release && \
#    cd .. && \
#    rm -rf test_app

CMD [ "flutter", "doctor" ]

