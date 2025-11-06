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
FROM plugfox/flutter:${VERSION} AS build-flutter-web

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
RUN flutter clean && \
    flutter pub get && \
    flutter build web --release && \
    cd build/web && \
    mv index.html index.src.html && \
    minify --output index.html index.src.html

# ------------------------------
# Stage 3: Nginx to serve Flutter Web
# ------------------------------
FROM nginx:alpine

# Копируем готовый web из build-flutter-web
COPY --from=build-flutter-web /app/build/web /usr/share/nginx/html

# Expose порт
EXPOSE 80

# Запуск Nginx
CMD ["nginx", "-g", "daemon off;"]

