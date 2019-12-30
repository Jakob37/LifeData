FROM rocker/tidyverse:3.6.2

ARG uid 
ARG gid 
ARG user 
ARG group

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install --yes \
	inotify-tools \
	dumb-init \
	xz-utils \
	wget

# Install runit manually because debian breaks otherwise
RUN mkdir --parents /usr/local/src && \
	wget \
		--output-document=/usr/local/src/runit.tar.gz \
		'http://smarden.org/runit/runit-2.1.2.tar.gz' && \
	tar \
		--directory=/usr/local/src \
		--extract \
		--file=/usr/local/src/runit.tar.gz && \
	cd /usr/local/src/admin/runit-* && \
	./package/compile && \
	mv command/* /usr/local/bin && \
	cd / && \
	rm --recursive --force /usr/local/src/*

RUN R -q -e "install.packages('argparser', dependencies=TRUE, repos='http://cran.rstudio.com', quiet=TRUE)"
RUN R -q -e "install.packages('lubridate', dependencies=TRUE, repos='http://cran.rstudio.com', quiet=TRUE)"
RUN R -q -e "install.packages('scales', dependencies=TRUE, repos='http://cran.rstudio.com', quiet=TRUE)"
RUN R -q -e "install.packages('ggpubr', dependencies=TRUE, repos='http://cran.rstudio.com', quiet=TRUE)"

COPY scripts/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

RUN mkdir -p /usr/local/libexec/
COPY scripts/*.R /usr/local/libexec/

# Setup runit runsvdir
RUN mkdir -p /usr/local/etc /usr/local/var/service
COPY sv /usr/local/etc/sv
RUN ln -sf /usr/local/etc/sv/* /usr/local/var/service

# Rewrite SIGTERM to SIGHUP so runsvdir behaves as expected
ENTRYPOINT [ "/usr/bin/dumb-init", \
	"--rewrite", "15:1", \
	"--single-child", \
	"--" ]
CMD [ "/usr/local/bin/runsvdir", "/usr/local/var/service" ]

RUN groupadd --gid "$gid" --system "$group"
RUN useradd --home-dir /var/lib/lifedata-visualizer \
		--shell /bin/sh \
		--uid "$uid" \
		--gid "$gid" \
		--system \
		--no-user-group \
		--create-home \
		"$user"

# Make runsvdir able to run without root
RUN chown -R "$user:$group" /usr/local/etc/sv /usr/local/var/service
