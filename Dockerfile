FROM containers.intersystems.com/intersystems/iris-ml-community:2022.1.0.209.0

USER root

# Japanese language pack (optional)
RUN apt -y update \
 && DEBIAN_FRONTEND=noninteractive apt -y install language-pack-ja-base language-pack-ja ibus-mozc 

USER irisowner
# Need this to prevent "Descriptors cannot not be created directly" error. 
# see https://github.com/protocolbuffers/protobuf/issues/10051
ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
