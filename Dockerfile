FROM alpine:edge as builder

ENV ZAPROXY_VERSION="w2019-07-01"

RUN apk update && apk --no-cache add \
    unzip \
    curl \
    wget \
    xmlstarlet \
    git

WORKDIR /zap

RUN curl -s https://raw.githubusercontent.com/zaproxy/zap-admin/master/ZapVersions.xml | xmlstarlet sel -t -v //url |grep -i weekly | wget --content-disposition -i - && \
    unzip *.zip && \
    rm *.zip && \
    cp -R ZAP*/* . &&  \
    rm -R ZAP*
    
RUN curl -s -L https://bitbucket.org/meszarv/webswing/downloads/webswing-2.5.10.zip > webswing.zip && \
    unzip webswing.zip && \
    rm webswing.zip && \
    mv webswing-* webswing && \
    # Remove Webswing demos
    rm -R webswing/demo/ && \
    # Accept ZAP license
    touch AcceptedLicense
    
RUN git clone --depth 1 --branch "${ZAPROXY_VERSION}" https://github.com/zaproxy/zaproxy.git /src 

FROM westonsteimel/alpine-glibc:edge

RUN apk update && apk --no-cache add \
	net-tools \
	python3 \
    openjdk8 \
	xvfb-run \
	x11vnc \
    libxext-dev \
    libxi-dev \
    libxtst-dev \
    libxrender-dev \
    && pip3 install --upgrade pip zapcli python-owasp-zap-v2.4 \
    && addgroup zap \
    && adduser -G zap -s /bin/sh -D zap \
    && mkdir /zap \
    && chown zap:zap /zap \
    && mkdir /home/zap/.vnc \
    && ln -s /usr/glibc-compat/sbin/ldconfig /zap/ldconfig

WORKDIR /zap

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/
ENV PATH /zap/ldconfig:$JAVA_HOME/bin:/zap/:$PATH
ENV ZAP_PATH /zap/zap.sh

# Default port for use with zapcli
ENV ZAP_PORT 8080
ENV HOME /home/zap/

COPY --from=builder /zap /zap
COPY --from=builder /src/docker/zap* /zap/
COPY --from=builder /src/docker/webswing.config /zap/webswing/
COPY --from=builder /src/docker/policies /home/zap/.ZAP_D/policies/
COPY --from=builder /src/docker/scripts /home/zap/.ZAP_D/scripts/
COPY --from=builder /src/docker/.xinitrc /home/zap/

RUN chown -R zap:zap /zap

USER zap

HEALTHCHECK --retries=5 --interval=5s CMD zap-cli status
