FROM ubuntu

ENV GAMADV_XTD3=7.00.38
ENV GAM_URL=https://raw.githubusercontent.com/taers232c/GAMADV-XTD3/refs/tags/v${GAMADV_XTD3}/src/requirements.txt
ENV GAMADV_URL=https://github.com/taers232c/GAMADV-XTD3/releases/download/v${GAMADV_XTD3}/gamadv-xtd3-${GAMADV_XTD3}-linux-x86_64-glibc2.39.tar.xz

USER root

RUN apt-get update \
    && apt-get install -y bash curl python3 \
        python3-cryptography python3-openssl python3-pip \
        libpcsclite-dev swig bc \
    && curl -L -o /tmp/requirements.txt ${GAM_URL} \
    && apt-get install -y < /tmp/requirements.txt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
        /var/cache/debconf/templates.dat \
        /var/log/dpkg.log \
        /var/lib/dpkg/status \
        /var/log/apt/history.log \
        /var/cache/apk/* \
        /var/tmp/*

RUN mkdir -p /gam/config \
    && mkdir /gam/download \
    && mkdir /gam/cache \
    && chown -R sngular:sngular /gam

USER sngular

WORKDIR /gam

RUN curl -L -o /tmp/v${GAMADV_XTD3}.tar.xz ${GAMADV_URL} \
    && tar -C /gam/ -xf /tmp/v${GAMADV_XTD3}.tar.xz \
    && rm /tmp/v${GAMADV_XTD3}.tar.xz \
    && mv /gam/gamadv-xtd3 /gam/bin/

COPY gam-runner.sh /usr/bin/gam.sh

CMD [ "--help" ]

ARG VCS_REF
