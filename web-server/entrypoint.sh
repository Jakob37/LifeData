#!/bin/sh

echo "SERVE_DIR=$SERVE_DIR"

exec mini_httpd -C /etc/mini_httpd/mini_httpd.conf -D 
