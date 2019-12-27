FROM rocker/tidy-verse:3.6.1

ARG LDV_PORT

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --no-cache --yes \
	mini-httpd

# ADD PACKAGES

RUN mkdir -p /srv/www/lifedata-visualizer

COPY config/mini_httpd.conf /etc/mini_httpd/mini_httpd.conf

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT /usr/local/bin/entrypoint.sh

RUN addgroup -g "$gid" "$group"
RUN adduser -h /var/lib/ssh-key-manager -s /bin/nologin -G "$group" -D -u "$uid" "$user"

EXPOSE $LDV_PORT
