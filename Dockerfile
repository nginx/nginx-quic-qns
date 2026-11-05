FROM martenseemann/quic-network-simulator-endpoint:latest AS builder

ARG DEBIAN_FRONTEND=noninteractive
ARG OPENSSL_VERSION=3.5.9
RUN apt-get update
RUN apt-get install -qy build-essential libpcre2-dev zlib1g zlib1g-dev curl git perl gnutls-bin iptables

RUN useradd nginx

RUN curl -fsSL https://github.com/openssl/openssl/releases/download/openssl-$OPENSSL_VERSION/openssl-$OPENSSL_VERSION.tar.gz \
    | tar -xz

RUN git clone https://github.com/nginx/nginx

RUN cd nginx && \
    ./auto/configure --prefix=/etc/nginx \
    --build=$(git rev-parse HEAD) \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/run/nginx.pid \
    --lock-path=/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-debug \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-openssl=/openssl-$OPENSSL_VERSION \
    --with-cc-opt='-O0 -fno-common -fno-omit-frame-pointer'

RUN cd nginx && make -j$(nproc)
RUN cd nginx && make install


FROM martenseemann/quic-network-simulator-endpoint:latest

COPY --from=builder /usr/sbin/nginx /usr/sbin/
COPY --from=builder /etc/nginx /etc/nginx

RUN useradd nginx
RUN mkdir -p /var/cache/nginx /var/log/nginx/

COPY nginx.conf nginx.conf.retry nginx.conf.http3 nginx.conf.nodebug /etc/nginx/

COPY run_endpoint.sh .
RUN chmod +x run_endpoint.sh

EXPOSE 443/udp
EXPOSE 443/tcp

ENTRYPOINT [ "./run_endpoint.sh" ]
