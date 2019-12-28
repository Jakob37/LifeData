FROM rocker/tidyverse:3.6.2

ARG port 
ARG uid 
ARG gid 
ARG user 
ARG group

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --yes \
	mini-httpd

RUN R -e "install.packages('argparser', dependencies=TRUE, repos='http://cran.rstudio.com')"
RUN R -e "install.packages('lubridate', dependencies=TRUE, repos='http://cran.rstudio.com')"
RUN R -e "install.packages('scales', dependencies=TRUE, repos='http://cran.rstudio.com')"
RUN R -e "install.packages('ggpubr', dependencies=TRUE, repos='http://cran.rstudio.com')"

RUN mkdir -p /srv/www/lifedata-visualizer

COPY config/mini_httpd.conf /etc/mini_httpd/mini_httpd.conf

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT /usr/local/bin/entrypoint.sh

RUN useradd --home-dir /var/lib/lifedata-visualizer \
		--shell /bin/sh \
		--uid "$uid" \
		--system \
		--user-group \
		--create-home \
		"$user"

EXPOSE $port
