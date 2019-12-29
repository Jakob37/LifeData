FROM rocker/tidyverse:3.6.2

ARG uid 
ARG gid 
ARG user 
ARG group

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --yes \
	inotify-tools \
	wget

RUN R -e "install.packages('argparser', dependencies=TRUE, repos='http://cran.rstudio.com')"
RUN R -e "install.packages('lubridate', dependencies=TRUE, repos='http://cran.rstudio.com')"
RUN R -e "install.packages('scales', dependencies=TRUE, repos='http://cran.rstudio.com')"
RUN R -e "install.packages('ggpubr', dependencies=TRUE, repos='http://cran.rstudio.com')"

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64
RUN chmod +x /usr/local/bin/dumb-init

COPY scripts/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

RUN mkdir -p /usr/local/libexec/lifedata-visualizer
COPY scripts/*.R /usr/local/libexec/

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/dumb-init", "--" ]
CMD [ "/usr/local/bin/entrypoint.sh" ]

RUN groupadd --gid "$gid" --system "$group"
RUN useradd --home-dir /var/lib/lifedata-visualizer \
		--shell /bin/sh \
		--uid "$uid" \
		--gid "$gid" \
		--system \
		--no-user-group \
		--create-home \
		"$user"
