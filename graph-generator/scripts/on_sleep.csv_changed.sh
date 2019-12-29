#!/bin/sh

: "${GRAPH_DIR:?Required variable GRAPH_DIR unset.}"

Rscript /usr/local/libexec/generate_sleep_graphs.R \
	--in_csv "$1" \
	--out_strips "$GRAPH_DIR/sleep_strips.png" \
	--out_histograms "$GRAPH_DIR/sleep_histogram.png"
