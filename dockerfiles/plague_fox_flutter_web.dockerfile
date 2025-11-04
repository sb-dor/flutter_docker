ARG VERSION="3.35.5"

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
FROM plugfox/flutter:${VERSION} AS web-build

USER root
WORKDIR /app

# Copy the minify binary from the builder stage
#COPY --from=minifier-builder /out/ /bin/

# Copy Flutter project into container
COPY . /app

# Setup flutter tools for web developement
RUN set -eux; flutter config --enable-web \
&& flutter precache --web

RUN flutter

#RUN flutter clean && flutter pub get && flutter build web --release
#
#RUN find build/web -type f -name "*.js" -o -name "*.css" -o -name "*.html" \
#    -exec minify {} -o {} \;
#
#FROM nginx:alpine
#
#WORKDIR /usr/share/nginx/html
#
## Copy built and minified web app
#COPY --from=web-build /app/build/web .
#
#EXPOSE 80
#CMD ["nginx", "-g", "daemon off;"]