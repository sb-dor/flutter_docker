FROM ubuntu:25.04 as linux_flutter_git_clone

ARG FLUTTER_SDK=/opt/flutter
ARG FLUTTER_VERSION=3.35.5
ARG APP=/app/

ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

RUN apt-get update -y && apt-get upgrade -y && apt install git -y  \
    apt-get install -y curl git unzip xz-utils zip libglu1-mesa

RUN git clone https://github.com/flutter/flutter.git $FLUTTER_SDK

RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

RUN flutter doctor -v && cd ..

RUN mkdir $APP && git clone https://github.com/sb-dor/simple_pos.git $APP

# stup new folder as the working directory
WORKDIR $APP

RUN flutter clean && flutter pub get  \
    && dart run build_runner build --delete-conflicting-outputs --release \
    && flutter build web --release

# use nginx to deploy
FROM nginx:1.25.2-alpine

# copy the info of the builded web app to nginx
COPY --from=linux_flutter_git_clone /app/build/web /usr/share/nginx/html

# Expose and run nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

# stup new folder as the working directory