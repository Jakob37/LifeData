FROM debian:bullseye-20191224

ARG port 
ARG uid 
ARG gid 
ARG user 
ARG group

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --yes \
	mini-httpd

COPY config/mini_httpd.conf /etc/mini_httpd/mini_httpd.conf

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT /usr/local/bin/entrypoint.sh

RUN groupadd --gid "$gid" --system "$group"
RUN useradd --home-dir /var/lib/lifedata-visualizer \
		--shell /bin/sh \
		--uid "$uid" \
		--gid "$gid" \
		--system \
		--no-user-group \
		--create-home \
		"$user"

EXPOSE $port
