FROM docker.io/library/golang:1.15.0

RUN apt-get -y update && apt-get install -y \
      musl-tools

RUN go get github.com/chadnetzer/hardlinkable && \
    go get github.com/spf13/cobra

ENV CC=/usr/bin/musl-gcc
RUN go build -ldflags "-linkmode external -extldflags -static" -o hardlinkable github.com/chadnetzer/hardlinkable/cmd/hardlinkable

FROM docker.io/library/debian:buster-20200908
MAINTAINER Andrew Cole <andrew.cole@illallangi.com>

# Install packages
RUN apt-get -y update && apt-get install -y \
      apt-utils \
      curl \
      dnsutils \
      fio \
      git \
      iperf3 \
      jq \
      librsvg2-bin \
      libxml2-utils \
      mtr \
      nano \
      openssh-client \
      procps \
      rsync \
      traceroute \
      wget \
    && rm -rf /var/lib/apt/lists/*

# Copy hardlinkable
COPY --from=0 /go/hardlinkable /usr/local/bin/hardlinkable

# Configure entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

ARG VCS_REF
ARG VERSION
ARG BUILD_DATE
LABEL maintainer="Andrew Cole <andrew.cole@illallangi.com>" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.description="A collection of utilities installed onto a debian base image" \
      org.label-schema.name="Toolbx" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.url="http://github.com/illallangi/Toolbx" \
      org.label-schema.usage="https://github.com/illallangi/Toolbx/blob/master/README.md" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/illallangi/Toolbx" \
      org.label-schema.vendor="Illallangi Enterprises" \
      org.label-schema.version=$VERSION
