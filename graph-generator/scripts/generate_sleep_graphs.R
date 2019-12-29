library(argparser)
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(scales))
suppressPackageStartupMessages(library(ggpubr))
theme_set(theme_classic())

# Usage example
# Rscript generate_sleep_graphs.R --in_csv sleep.csv --out_strips strips.png --out_histograms hist.png

main <- function() {
    argv <- parse_input_params()
    my_df <- setup_input_data(argv$in_csv)
    all_times_df <- generate_all_times_df(my_df)
    if (argv$out_histograms != "") {
        print(sprintf("Writing plot to %s", argv$out_histograms))
        histogram_plt <- make_histogram_plots(my_df)
        ggsave(histogram_plt, filename = argv$out_histograms)
    }
    
    if (argv$out_strips != "") {
        print(sprintf("Writing plot to %s", argv$out_strips))
        sleep_strip_plt <- generate_sleep_strip_plot(all_times_df)
        ggsave(sleep_strip_plt, filename = argv$out_strips, width=10, height=5)
    }
    
}

setup_input_data <- function(in_path) {
    my_df <- read_csv(in_path)
    colnames(my_df) <- make.names(colnames(my_df))
    my_df <- my_df %>% mutate(
        sleep_time=as.numeric(Fell.asleep - trunc(Fell.asleep, "days")) / 60 / 60,
        wake_time=as.numeric(Woke.up - trunc(Woke.up, "days")) / 60 / 60
    )
    my_df$hours <- (my_df$Woke.up - my_df$Fell.asleep)
    my_df
}

make_histogram_plots <- function(my_df) {
    to_bed_plt <- ggplot(my_df, aes(x=sleep_time)) + geom_histogram(bins=24) + ggtitle("Going to bed time")
    from_bed_plt <- ggplot(my_df, aes(x=wake_time)) + geom_histogram(bins=24) + ggtitle("Waking up time")
    duration_plt <- ggplot(my_df, aes(x=hours)) + geom_histogram(bins=24) + ggtitle("Sleeping duration")
    
    ggarrange(
        to_bed_plt,
        from_bed_plt,
        duration_plt,
        nrow=3
    )
}

generate_all_times_df <- function(my_df) {
    extract_sleep_times <- function(start, finish) {
        hour_sec <- 3600 / 4
        sleep_times_raw <- seq(
            as.POSIXct(start), 
            as.POSIXct(finish), 
            by = hour_sec
        )
        as.POSIXct(sleep_times_raw + 3600, origin='1970-01-01 00:00:00', tz="UTC")
    }
    
    sleep_times_list <- apply(my_df, 1, function(row) { 
        extract_sleep_times(row[[2]], row[[3]])
    })
    
    all_sleep_times <- unlist(sleep_times_list)
    
    all_times <- seq(min(my_df$Fell.asleep), max(my_df$Fell.asleep), by = 3600 / 4)
    all_times_df <- data.frame(all_times)
    all_times_df$time <- as.numeric(all_times - trunc(all_times, "days")) / 3600
    all_times_df$date <- as.Date(ymd_hms(all_times_df$all_times))
    all_times_df$is_sleeping <- all_times_df$all_times %in% all_sleep_times
    all_times_df
}

generate_sleep_strip_plot <- function(all_times_df, start=NULL, end=NULL) {
    get_range <- function(raw_df, start="2019-12-01", end="2019-12-31") {
        raw_df %>%
            filter(date >= as.Date(start, origin='1970-01-01 00:00:00', tz="UTC")) %>% 
            filter(date <= as.Date(end, origin='1970-01-01 00:00:00', tz="UTC"))
    }
    
    if (!is.null(start) && !is.null(end)) {
        all_times_df <- get_range("2019-10-01", "2019-10-31")
    }
    
    ggplot(all_times_df, aes(x=date, y=time, fill=is_sleeping)) + 
        geom_tile(width=0.5) + 
        scale_fill_manual(values=c("#cccccc", "#007700")) + 
        ggtitle("Sleeping pattern") +
        scale_x_date(date_breaks = "1 day") +
        theme(axis.text.x = element_text(angle=90, vjust=0.5))
}

parse_input_params <- function() {
    parser <- arg_parser("Visualizing sleep data")
    parser <- add_argument(parser, "--in_csv", help="Input CSV", type="character", default="")
    
    parser <- add_argument(parser, "--out_strips", help="Strip plot illustrating sleeping times", type="character", default="")
    parser <- add_argument(parser, "--out_histograms", help="Histogram plots", type="character", default="")
    argv <- parse_args(parser)
    
    if (argv$in_csv == "") {
        stop("The argument --in_csv is required")
    }
    
    argv
}

if (!interactive()) {
    main()
}
