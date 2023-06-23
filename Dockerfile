ARG KONG_VERSION

FROM kong:${KONG_VERSION}
USER root

RUN apk add \
	--virtual build-dependencies \
	build-base \
	gcc \
	wget \
	git \
	ruby \
	openssl-dev \
	libuuid \
	yaml-dev

RUN luarocks list --outdated | ruby -ne '`luarocks install #{$_}` if $_ =~ /^\w+$/'
RUN bash -c 'luarocks install kong-request-allow;'
RUN luarocks list | ruby -ne '`luarocks install #{$_}` if $_ =~ /^\w+$/'

USER kong
