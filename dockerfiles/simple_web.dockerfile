# ============================
# 1. Flutter build stage
# ============================
FROM ubuntu:25.04 AS flutter-builder

ARG FLUTTER_VERSION="3.35.5"
ARG DEBIAN_FRONTEND=noninteractive

# Установим зависимости
RUN apt-get update && apt-get install -y \
    git curl unzip xz-utils zip libglu1-mesa ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/

# Клонируем Flutter SDK через Git
RUN git clone https://github.com/flutter/flutter.git -b $FLUTTER_VERSION --depth 1

# Добавляем Flutter и Dart в PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Включаем поддержку web и кешируем необходимые компоненты
RUN flutter config --enable-web && flutter precache --web

WORKDIR /app

# Копируем pubspec сначала для кэширования зависимостей
COPY pubspec.* ./
RUN flutter pub get

# Копируем весь проект
COPY . .

# Собираем Flutter web
RUN flutter build web --release

# ============================
# 2. NGINX runtime
# ============================
FROM nginx:alpine

# Очищаем дефолтный HTML
RUN rm -rf /usr/share/nginx/html/*

# Копируем собранный Flutter Web
COPY --from=flutter-builder /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]