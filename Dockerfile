FROM jenkins/inbound-agent:3309.v27b_9314fd1a_4-3@sha256:193c6ca7ea13b8ab05635e04aae32529fc8cfb58ec795efc2705dd08fd09d1ed

# systems versions
# renovate: datasource=repology depName=debian_12/jq versioning=loose
ENV JQ_VERSION="1.6-2.1"
ENV SONAR_VERSION="6.2.1.4610"
# renovate: datasource=repology depName=debian_12/nodejs versioning=loose
ENV NODEJS_VERSION="20.18.0-1nodesource1"
ENV NG_VERSION="12.2.15"
ENV AWS_VERSION="2.19.5"
ENV COMPOSER_VERSION="2.8.2"
ENV NC_VERSION="1.10-47"
# renovate: datasource=repology depName=debian_12/postgresql-15 versioning=loose
ENV PSQL_CLIENT_VERSION="15.13-0+deb12u1"
# renovate: datasource=repology depName=debian_12/curl versioning=loose
ENV CURL_VERSION="7.88.1-10+deb12u8"
# renovate: datasource=repology depName=debian_12/zip versioning=loose
ENV ZIP_VERSION="3.0-13"
# renovate: datasource=repology depName=debian_12/unzip versioning=loose
ENV UNZIP_VERSION="6.0-28"
# renovate: datasource=repology depName=debian_12/python3.11 versioning=loose
ENV PYTHON_VERSION="3.11.2-1+b1"

# use root user to install packages
USER root
RUN \
  apt-get update -y && \
  apt-get install -y --no-install-recommends \
      curl=${CURL_VERSION} \
      zip=${ZIP_VERSION} \
      unzip=${UNZIP_VERSION} \
      jq=${JQ_VERSION} \
      python3=${PYTHON_VERSION} \
      python3-venv=${PYTHON_VERSION} && \
  ln -s /usr/bin/python3 /usr/bin/python && \
	# install sonar-scanner
	curl -fsSLO "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_VERSION}-linux-x64.zip" && \
	unzip sonar-scanner-cli-${SONAR_VERSION}-linux-x64.zip && \
	mv sonar-scanner-${SONAR_VERSION}-linux-x64/ /opt/ && \
	rm sonar-scanner-cli-${SONAR_VERSION}-linux-x64.zip && \
	ln -s /opt/sonar-scanner-${SONAR_VERSION}-linux-x64/bin/sonar-scanner /usr/local/bin/sonar-scanner && \
	# # install nodejs
	curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh && \
	bash nodesource_setup.sh && \
    apt-get update && \
	apt-get install --no-install-recommends -y nodejs=${NODEJS_VERSION} && \
	rm -rf /var/lib/apt/lists/* && \
	rm nodesource_setup.sh && \
	# install aws cli
	curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && \
	unzip awscli-bundle.zip && \
	./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

RUN npm install -g npm

# install php composer, netcat and psql
RUN apt-get update && apt-get install -y --no-install-recommends \
	php-cli=2:8.2+93 \
	php-mbstring=2:8.2+93 \
	build-essential=12.9 \
	sshpass=1.09-1+b1 \
	libglu1-mesa=9.0.2-1.1 \
	libxi6=2:1.8-1+b1 \
	netcat-traditional=${NC_VERSION} \
	php-xml=2:8.2+93 \
	postgresql-client=${PSQL_CLIENT_VERSION} && \
	rm -rf /var/lib/apt/lists/* && \
	# install ng cli
	npm install -g @angular/cli@${NG_VERSION}
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
	php composer-setup.php --install-dir=/usr/local/bin --version=${COMPOSER_VERSION} --filename=composer && \
	php -r "unlink('composer-setup.php');"

# clean packages cache
RUN apt-get clean

# restore jenkins user
USER jenkins

