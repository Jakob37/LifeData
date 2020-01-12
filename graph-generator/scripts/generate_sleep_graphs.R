library(argparser)

quiet <- suppressPackageStartupMessages
quiet(library(tidyverse))
quiet(library(lubridate))
quiet(library(scales))
quiet(library(ggpubr))
quiet(library(janitor))

theme_set(theme_classic())

# Usage example
# Rscript generate_sleep_graphs.R \
#  --in_sleep sleep.csv \
#  --in_computer turn-off.csv \
#  --in_study study-sessions.csv \
#  --out_strips strips.png \
#  --out_histograms hist.png

main <- function() {
    
    argv <- parse_input_params()
    
    sleep_df <- read_csv(argv$in_sleep) %>%
        janitor::clean_names() %>%
        setup_time_diff_cols("fell_asleep", "woke_up")

    computer_df <- read_csv(argv$in_computer, na="-") %>%
        janitor::clean_names() %>%
        filter(!is.na(turned_on)) %>%
        setup_time_diff_cols("turned_off_computers_at", "turned_on")
    
    study_df <- read_csv(argv$in_study) %>%
        janitor::clean_names() %>%
        setup_time_diff_cols("start", "end")
    
    all_times_df <- generate_all_times_df(sleep_df, computer_df, study_df)
    
    if (argv$out_histograms != "") {
        print(sprintf("Writing plot to %s", argv$out_histograms))
        histogram_plt <- make_histogram_plots(sleep_df)
        ggsave(histogram_plt, filename = argv$out_histograms)
    }
    
    if (argv$out_strips != "") {
        print(sprintf("Writing plot to %s", argv$out_strips))
        sleep_strip_plt <- generate_sleep_strip_plot(all_times_df)
        ggsave(sleep_strip_plt, filename = argv$out_strips, width=10, height=5)
    }
    
}

get_hour <- function(posix_col, div_hour=TRUE) {
    base <- as.numeric(posix_col - trunc(posix_col, "days"))
    if (div_hour) {
        base / 60 / 60
    }
    else {
        base
    }
}

setup_time_diff_cols <- function(time_df, start_date_col, end_date_col) {
    
    time_df$start_date <- time_df[[start_date_col]]
    time_df$end_date <- time_df[[end_date_col]]
    
    time_df$start_time <- get_hour(time_df$start_date)
    time_df$end_time <- get_hour(time_df$end_date)
    time_df$hours <- (time_df$end_date - time_df$start_date)
    time_df
}

make_histogram_plots <- function(my_df) {
    to_bed_plt <- ggplot(my_df, aes(x=start_time)) + 
        xlab("Start time") + ylab("Count") +
        geom_histogram(bins=24) + 
        ggtitle("Going to bed time")
    from_bed_plt <- ggplot(my_df, aes(x=end_time)) + 
        xlab("Start time") + ylab("Count") +
        geom_histogram(bins=24) + 
        ggtitle("Waking up time")
    duration_plt <- ggplot(my_df, aes(x=hours)) + 
        xlab("Start time") + ylab("Count") +
        geom_histogram(bins=24) + 
        ggtitle("Sleeping duration")
    
    ggarrange(
        to_bed_plt,
        from_bed_plt,
        duration_plt,
        nrow=3
    )
}

generate_all_times_df <- function(sleep_df, computer_df, study_df) {
    extract_active_quarters_per_day <- function(start, finish) {
        hour_sec <- 3600 / 4
        active_times_raw <- seq(
            as.POSIXct(start), 
            as.POSIXct(finish), 
            by = hour_sec
        )
        as.POSIXct(active_times_raw + 3600, origin='1970-01-01 00:00:00', tz="UTC")
    }
    
    setup_all_times_in_range <- function(start_date, end_date, interval) {
        all_times <- seq(start_date, end_date, by = interval)
        all_times_df <- data.frame(all_times)
        all_times_df$time <- as.numeric(all_times - trunc(all_times, "days")) / 3600
        all_times_df$date <- as.Date(ymd_hms(all_times_df$all_times))
        all_times_df
    }
    
    all_sleep_times <- apply(sleep_df, 1, function(row) { 
        extract_active_quarters_per_day(row[['start_date']], row[['end_date']])
    }) %>% unlist()
    
    all_computer_times <- apply(computer_df, 1, function(row) {
        extract_active_quarters_per_day(row[['start_date']], row[['end_date']])
    }) %>% unlist()
    
    all_study_times <- apply(study_df, 1, function(row) {
        extract_active_quarters_per_day(row['start_date'], row['end_date'])
    }) %>% unlist()
    
    
    quarter <- 3600 / 4
    all_times_df <- setup_all_times_in_range(min(sleep_df$start_date), max(sleep_df$end_date), interval = quarter)
    all_times_df$is_sleeping <- all_times_df$all_times %in% all_sleep_times
    all_times_df$computer_off <- all_times_df$all_times %in% all_computer_times
    all_times_df$is_studying <- all_times_df$all_times %in% all_study_times
    all_times_df$combined <- paste(all_times_df$is_sleeping, all_times_df$computer_off)
    
    all_times_df$status <- apply(all_times_df, 1, function(row) {
        if (row['is_sleeping']) {
            "sleeping"
        }
        else if (row['is_studying']) {
            "studying"
        }
        else if (row['computer_off']) {
            "computer_off"
        }
        else {
            "idle"
        }
    })
    
    all_times_df
}

generate_sleep_strip_plot <- function(all_times_df, start=NULL, end=NULL) {
    get_range <- function(raw_df, start="2019-12-01", end="2019-12-31") {
        raw_df %>%
            filter(date >= as.Date(start, origin='1970-01-01 00:00:00', tz="UTC")) %>% 
            filter(date <= as.Date(end, origin='1970-01-01 00:00:00', tz="UTC"))
    }
    
    ggplot(all_times_df, aes(x=date, y=time, fill=status)) +
        geom_tile(width=0.5) +
        scale_fill_manual(values=c("#4d99e6", "#dddddd", "#66B266", "#ff6600")) +
        ggtitle("Life pattern") +
        scale_x_date(date_breaks = "1 day") +
        theme(axis.text.x = element_text(angle=90, vjust=0.5, size=8))
}

parse_input_params <- function() {
    parser <- arg_parser("Visualizing sleep data")
    parser <- add_argument(parser, "--in_sleep", help="Input CSV", type="character", default="")
    parser <- add_argument(parser, "--in_computer", help="Input CSV", type="character", default="")
    parser <- add_argument(parser, "--in_study", help="Input CSV", type="character", default="")
    
    parser <- add_argument(parser, "--out_strips", help="Strip plot illustrating sleeping times", type="character", default="")
    parser <- add_argument(parser, "--out_histograms", help="Histogram plots", type="character", default="")
    argv <- parse_args(parser)
    
    if (argv$in_sleep == "" || argv$in_computer == "" || argv$in_study == "") {
        stop("The arguments --in_sleep, --in_computer and --in_study is required")
    }
    
    argv
}

if (!interactive()) {
    main()
}
