from ubuntu:25.10@sha256:a61c057b4f69200ecf031519a20db79b8683837ba1dc2a59458d333eb75b174d AS one

from ubuntu:25.10@sha256:a61c057b4f69200ecf031519a20db79b8683837ba1dc2a59458d333eb75b174d AS two

FROM ubuntu:25.10@sha256:a61c057b4f69200ecf031519a20db79b8683837ba1dc2a59458d333eb75b174d AS three

FROM ubuntu:25.10@sha256:a61c057b4f69200ecf031519a20db79b8683837ba1dc2a59458d333eb75b174d

# renovate: datasource=repology depName=ubuntu_24_04/openjdk-8 versioning=loose
ARG JAVA_JRE_VER="8u462-ga~us1-0ubuntu2~24.04.2"
#ARG JAVA_JRE_VER="8u452-ga~us1-0ubuntu1~24.04"
