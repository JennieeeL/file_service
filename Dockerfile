FROM nginx:1.23 as nginx
ARG ROOT_PWD
RUN mkdir /var/www && \
  mkdir /var/www/html && \
  mkdir /etc/nginx/sites-available
RUN apt-get update && \
    apt-get install -y keyutils cifs-utils vim curl tar wget git libpcre3-dev libxslt-dev libgd-dev libgeoip-dev gcc libssl-dev make openssh-server
RUN wget https://nginx.org/download/nginx-1.23.4.tar.gz
RUN tar -xzvf nginx-1.23.4.tar.gz
RUN git clone https://github.com/aperezdc/ngx-fancyindex.git
WORKDIR "/nginx-1.23.4"
RUN ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx#/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-g -O2 -ffile-prefix-map=/data/builder/debuild/nginx-1.23.4/debian/debuild-base/nginx-1.23.4=. -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' --add-dynamic-module=../ngx-fancyindex
RUN make modules
RUN cp objs/ngx_http_fancyindex_module.so /usr/lib/nginx/modules
COPY ./file_web/html /var/www/html
COPY ./file_web/proxy_params /etc/nginx/proxy_params
COPY ./file_web/conf.d /etc/nginx/conf.d
COPY ./file_web/nginx.conf /etc/nginx/nginx.conf
COPY ./file_web/conf.d/default.conf.dist /etc/nginx/conf.d/default.conf
COPY ./file_web/sites-available/default /etc/nginx/sites-available/default
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config 
RUN echo "root:$ROOT_PWD" | /usr/sbin/chpasswd

EXPOSE 22 80

ENTRYPOINT /bin/bash -x /app/start.sh && nginx -g 'daemon off;'
