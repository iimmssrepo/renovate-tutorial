from ubuntu:24.04@sha256:353675e2a41babd526e2b837d7ec780c2a05bca0164f7ea5dbbd433d21d166fc AS one

from ubuntu:24.04@sha256:353675e2a41babd526e2b837d7ec780c2a05bca0164f7ea5dbbd433d21d166fc AS two

FROM ubuntu:24.04@sha256:353675e2a41babd526e2b837d7ec780c2a05bca0164f7ea5dbbd433d21d166fc AS three

FROM ubuntu:23.10@sha256:fd7fe639db24c4e005643921beea92bc449aac4f4d40d60cd9ad9ab6456aec01

# renovate: datasource=repology depName=ubuntu_24_04/openjdk-8 versioning=loose
ARG JAVA_JRE_VER="8u462-ga~us1-0ubuntu2~24.04.2"
#ARG JAVA_JRE_VER="8u452-ga~us1-0ubuntu1~24.04"
