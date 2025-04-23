FROM python:3.11-alpine

# renovate: datasource=github-releases depName=maxmind/geoipupdate versioning=loose
ARG GEOIPUPDATE_VER="6.0.0"

# Install system dependencies
RUN apk add --update --no-cache \
    build-base \
    libxml2-dev \
    libxslt-dev \
    libffi-dev \
    wget

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Set up geoipupdate for automatic updates
RUN wget -O /tmp/geoipupdate.tar.gz \
    https://github.com/maxmind/geoipupdate/releases/download/v${GEOIPUPDATE_VER}/geoipupdate_${GEOIPUPDATE_VER}_linux_amd64.tar.gz \
    && tar -zxf /tmp/geoipupdate.tar.gz -C /tmp \
    && mv /tmp/geoipupdate_${GEOIPUPDATE_VER}_linux_amd64/geoipupdate /usr/local/bin/ \
    && rm -rf /tmp/geoipupdate_${GEOIPUPDATE_VER}_linux_amd64/ /tmp/geoipupdate.tar.gz

# Copy configuration files
COPY entrypoint.sh /usr/local/bin/
COPY GeoIP.conf parsedmarc.ini /usr/local/etc/
COPY geoip_update_cron /etc/cron.d/

# Set permissions
RUN chmod +x /usr/local/bin/entrypoint.sh \
    && chmod 644 /etc/cron.d/geoip_update_cron

# Run geoipupdate
RUN geoipupdate

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
