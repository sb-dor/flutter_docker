ARG VERSION="stable"

# ------------------------------
# Build minifier binary
# ------------------------------
FROM golang:alpine AS minifier-builder

WORKDIR /build

# Compile minify as a static binary
RUN apk add --no-cache git && \
    git clone -b master --depth 1 https://github.com/tdewolff/minify.git && \
    cd /build/minify/cmd/minify && \
    CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o /out/minify . && \
    chmod +x /out/minify

# ------------------------------
# Flutter web development image
# ------------------------------
FROM plugfox/flutter:${VERSION}

# https://hub.docker.com/r/plugfox/flutter
ARG MAIN_FOLDER=/main_folder
ARG APP=/app

USER root

# Создать корневую папку
RUN mkdir -p $MAIN_FOLDER

WORKDIR $MAIN_FOLDER

# Copy minify binary
COPY --from=minifier-builder /out/ /bin/

# Создать папку приложения
RUN mkdir -p $APP

# Перейти в папку приложения
WORKDIR $APP

# Скопировать проект внутрь
COPY . .

# CMD для проверки
CMD ["bash", "-c", "\
    echo PWD=$(pwd); \
    ls -la; \
    echo 'Directories:'; \
    ls -d */ 2>/dev/null || echo 'No dirs found'; \
    flutter clean && \
    flutter pub get && \
    flutter run -d web-server --release \
      --dart-define=FAKE=true \
      --device-id=web-server \
      --web-port=4000 \
      --web-hostname=192.168.100.70 \
"]