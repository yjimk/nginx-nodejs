FROM alpine:3.4

MAINTAINER yjimk <mail@jimmycann.com>

RUN echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && apk update && \
    apk add --no-cache bash \
    openssh-client \
    wget \
    nginx \
    supervisor \
    curl \
    nodejs=6.2.0-r0 \
    bc \
    gcc \
    musl-dev \
    linux-headers \
    python \
    python-dev \
    py-pip \
    augeas-dev \
    openssl-dev \
    libffi-dev \
    ca-certificates \
    dialog \
    vim \
    git && \
    mkdir -p /etc/nginx && \
    mkdir -p /var/www/app && \
    mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor

RUN pip install -U letsencrypt && \
    mkdir -p /etc/letsencrypt/webrootauth

#RUN git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt

ADD conf/supervisord.conf /etc/supervisord.conf

# Copy our nginx config
RUN rm -Rf /etc/nginx/nginx.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf

# nginx site conf
RUN mkdir -p /etc/nginx/sites-available/ && \
mkdir -p /etc/nginx/sites-enabled/ && \
mkdir -p /etc/nginx/ssl/ && \
rm -Rf /var/www/* && \
mkdir /www/
ADD conf/nginx-site.conf /etc/nginx/sites-available/default.conf
ADD conf/nginx-site-ssl.conf /etc/nginx/sites-available/default-ssl.conf
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# Add Scripts
ADD scripts/start.sh /start.sh
ADD scripts/pull /usr/bin/pull
ADD scripts/push /usr/bin/push
ADD scripts/letsencrypt-setup /usr/bin/letsencrypt-setup
ADD scripts/letsencrypt-renew /usr/bin/letsencrypt-renew
RUN chmod 755 /usr/bin/pull && chmod 755 /usr/bin/push && chmod 755 /usr/bin/letsencrypt-renew && chmod 755 /usr/bin/letsencrypt-setup && chmod 755 /start.sh

# copy in code
ADD src/ /www/
ADD errors/ /var/www/errors/
RUN mkdir -p /var/log/node/

VOLUME /www/

EXPOSE 443 80

#CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]
CMD ["/start.sh"]
