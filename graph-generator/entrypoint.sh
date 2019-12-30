#!/bin/sh
echo "GRAPH_DIR=$GRAPH_DIR"
echo "DATA_DIR=$DATA_DIR"

exec /usr/local/bin/run_when_changed.sh \
	watch="$DATA_DIR" \
	files="sleep.csv" \
	script="/usr/local/bin/on_sleep.csv_changed.sh"

