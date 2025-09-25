from ubuntu:24.04@sha256:b59d21599a2b151e23eea5f6602f4af4d7d31c4e236d22bf0b62b86d2e386b8f AS one

from ubuntu:24.04@sha256:89ef6e43e57cb94a23e4b28715a34444de91f45bd410fce3ce00819f86940a9c AS two

FROM ubuntu:24.04@sha256:6015f66923d7afbc53558d7ccffd325d43b4e249f41a6e93eef074c9505d2233 AS three

FROM ubuntu:23.04@sha256:5a828e28de105c3d7821c4442f0f5d1c52dc16acf4999d5f31a3bc0f03f06edd

# renovate: datasource=repology depName=ubuntu_24_04/openjdk-8 versioning=loose
ARG JAVA_JRE_VER="8u452-ga~us1-0ubuntu1~24.04"
#ARG JAVA_JRE_VER="8u452-ga~us1-0ubuntu1~24.04"
