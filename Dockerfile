FROM rocker/tidyverse:3.6.2

ARG port 
ARG uid 
ARG gid 
ARG user 
ARG group
ARG graph_dir

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --yes \
	mini-httpd \
	inotify-tools

RUN R -e "install.packages('argparser', dependencies=TRUE, repos='http://cran.rstudio.com')"
RUN R -e "install.packages('lubridate', dependencies=TRUE, repos='http://cran.rstudio.com')"
RUN R -e "install.packages('scales', dependencies=TRUE, repos='http://cran.rstudio.com')"
RUN R -e "install.packages('ggpubr', dependencies=TRUE, repos='http://cran.rstudio.com')"

RUN mkdir -p /usr/local/libexec/lifedata-visualizer

COPY config/mini_httpd.conf /etc/mini_httpd/mini_httpd.conf

COPY scripts/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

COPY scripts/*.R /usr/local/libexec/

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

RUN mkdir -p "$graph_dir"
RUN chown "$user:$group" "$graph_dir"

EXPOSE $port
