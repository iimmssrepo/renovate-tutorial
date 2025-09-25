from ubuntu:24.10@sha256:cdf755952ed117f6126ff4e65810bf93767d4c38f5c7185b50ec1f1078b464cc AS one

from ubuntu:24.10@sha256:cdf755952ed117f6126ff4e65810bf93767d4c38f5c7185b50ec1f1078b464cc AS two

FROM ubuntu:24.10@sha256:cdf755952ed117f6126ff4e65810bf93767d4c38f5c7185b50ec1f1078b464cc AS three

FROM ubuntu:23.04@sha256:5a828e28de105c3d7821c4442f0f5d1c52dc16acf4999d5f31a3bc0f03f06edd

# renovate: datasource=repology depName=ubuntu_24_04/openjdk-8 versioning=loose
ARG JAVA_JRE_VER="8u452-ga~us1-0ubuntu1~24.04"
#ARG JAVA_JRE_VER="8u452-ga~us1-0ubuntu1~24.04"
