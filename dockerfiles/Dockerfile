# https://www.youtube.com/live/ODcHcctHr2A?si=EESBgZo-OTr7xrHs

FROM ubuntu:25.10

ENV PATH="$PATH:/flutter/bin"

# for goint inside ubuntu:
# docker run -it my_test_ubuntu /bin/bash

# when the system ask permission "yes/no" - you have to put either "-y" or "-n"
RUN apt-get update -y && apt-get upgrade -y \
    && apt-get install -y git curl unzip \
    && git clone https://github.com/flutter/flutter.git -b stable /flutter


RUN flutter precache
RUN flutter doctor
