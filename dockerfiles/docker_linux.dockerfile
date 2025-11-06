ARG VERSION="stable"
ARG UBUNTU_VERSION=24.04

# ------------------------------
# Build stage: install Linux deps
# ------------------------------
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

# ------------------------------
# Final stage: Flutter SDK + Linux deps
# ------------------------------
FROM plugfox/flutter:${VERSION} AS production

# Copy Linux deps from build image
COPY --from=build /usr /usr
COPY --from=build /lib /lib
COPY --from=build /etc /etc

# Enable Linux desktop support
RUN set -eux; \
    flutter config --enable-linux-desktop && \
    flutter precache --linux

# Optional quick sanity check
# RUN set -eux; \
#     cd /tmp && \
#     flutter create --platforms=linux test_linux && \
#     cd test_linux && \
#     flutter build linux --release

ARG MAIN_FOLDER=/main_folder

ARG APP=/app

USER root

# Создать корневую папку
RUN mkdir -p $MAIN_FOLDER

WORKDIR $MAIN_FOLDER

# Создать папку приложения
RUN mkdir -p $APP

# Перейти в папку приложения
WORKDIR $APP

# Скопировать проект внутрь
COPY . .

CMD ["bash", "-c", "\
    echo PWD=$(pwd); \
    ls -la; \
    echo 'Directories:'; \
    ls -d */ 2>/dev/null || echo 'No dirs found'; \
    flutter clean && \
    flutter pub get && \
    flutter build linux --release \
"]