FROM us.gcr.io/scytale-registry/symbank-webapp@sha256:a1c9b1d14e14bd1a4e75698a4f153680d2a08e6f8d1f2d7110bff63d39228a75

# Symbank webapp config
COPY ./frontend/config /run/symbank-webapp/config

# Bootstrap trust
COPY ./certs/root_ca.crt /root/root_ca.crt
RUN cat /root/root_ca.crt >> /etc/ssl/certs/ca-certificates.crt
RUN apk --no-cache add ca-certificates \
    && rm -rf /var/cache/apk/*
COPY ./certs/root_ca.crt /usr/local/share/ca-certificates
RUN update-ca-certificates

CMD ["/opt/symbank-webapp/symbank-webapp", "-config", "/run/symbank-webapp/config/symbank-webapp.conf"]