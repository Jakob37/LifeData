FROM rocker/tidyverse:3.6.2

ARG uid 
ARG gid 
ARG user 
ARG group

RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update && \
	apt-get install --yes \
	inotify-tools

RUN R -q -e "install.packages('argparser', dependencies=TRUE, repos='http://cran.rstudio.com', quiet=TRUE)"
RUN R -q -e "install.packages('lubridate', dependencies=TRUE, repos='http://cran.rstudio.com', quiet=TRUE)"
RUN R -q -e "install.packages('scales', dependencies=TRUE, repos='http://cran.rstudio.com', quiet=TRUE)"
RUN R -q -e "install.packages('ggpubr', dependencies=TRUE, repos='http://cran.rstudio.com', quiet=TRUE)"

COPY scripts/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

RUN mkdir -p /usr/local/libexec/
COPY scripts/*.R /usr/local/libexec/

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
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
