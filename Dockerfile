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

# fetch dnsmasq and webproc binary
RUN apk update \
	&& apk --no-cache add dnsmasq-dnssec \
	&& apk add --no-cache --virtual .build-deps curl \
	&& curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/webproc \
	&& apk del .build-deps
#configure dnsmasq
RUN mkdir -p /etc/default/
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf
#run!
ENTRYPOINT ["webproc","-c","/etc/dnsmasq.conf","--","dnsmasq","--keep-in-foreground", "--log-facility=-", "--log-async"]
