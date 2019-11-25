FROM rocker/shiny-verse:3.6.0

ARG LDV_PORT

COPY ./config/shiny-server.conf /etc/shiny-server/shiny-server.conf

EXPOSE $LDV_PORT
