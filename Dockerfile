FROM alpine:3.15
LABEL maintainer="pablo@pabl.eu"

# this shows us what various BuildKit arguments are based on the 
# docker buildx build --platform= option you give Docker.
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

# webproc release settings
ENV WEBPROC_VERSION 0.4.0
ENV WEBPROC_URL "https://github.com/jpillora/webproc/releases/download/v${WEBPROC_VERSION}/webproc_${WEBPROC_VERSION}_${TARGETOS}_${TARGETARCH}${TARGETVARIANT}.gz"

# dnsmasq exporter release settings
ENV DNSMASQ_EXPORTER_VERSION 1.0.0
ENV DNSMASQ_EXPORTER_URL "https://github.com/pblop/dnsmasq_exporter/releases/download/v${DNSMASQ_EXPORTER_VERSION}/dnsmasq_exporter_${DNSMASQ_EXPORTER_VERSION}_${TARGETOS}_${TARGETARCH}${TARGETVARIANT}.gz"

# fetch dnsmasq, the webproc binary, and the dnsmasq_exporter binary
RUN apk update \
	&& apk --no-cache add dnsmasq-dnssec \
	&& apk add --no-cache --virtual .build-deps curl \
	&& curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc \
	&& curl -sL $DNSMASQ_EXPORTER_URL | gzip -d - > /usr/local/bin/dnsmasq_exporter \
	&& chmod +x /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/dnsmasq_exporter \
	&& apk del .build-deps

#configure dnsmasq
RUN mkdir -p /etc/default/
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf


#run!
COPY start_script.sh ./start_script.sh
RUN chmod +x ./start_script.sh
ENTRYPOINT ["./start_script.sh"]
