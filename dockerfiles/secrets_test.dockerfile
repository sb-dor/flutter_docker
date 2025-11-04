FROM ubuntu:25.04

#test
ARG ANY_TEST

RUN echo $ANY_TEST

# docker build -t ubuntu_test --file secrets_test.dockerfile --build-arg ANY_TEST=hello_world .


# but it's not good to get your secrets on build time - like writing down the secrets right inside the command line
#
# running the command:
#           docker history <image_name>
# will show what you wrote in command line
