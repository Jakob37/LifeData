#!/bin/sh

usage() {
	echo "USAGE: ./run-when-changed.sh <watch=dir-to-watch> <files=file1,file2...> script=<script-to-run>"
	echo "Watch directory <watch> and run <script> with argument \"fileN\" when any file \"fileN\" in <files> is written to."
}

die() {
	test $# -gt 0 && echo "$@" >&2
	exit 1
}

get_real_path() {
	file="$1"
	path="$(cd "$(dirname "$file")" && pwd)"
	name="$(basename "$file")"
	echo "$path/$name"
}

test $# -eq 3 || { usage && die ;}

command -v inotifywait >/dev/null 2>&1 ||
	die "Required command inotifywait missing."

while test "$#" -gt 0; do
	case "$1" in
	watch=*)
		watch_dir="$(get_real_path "$(echo "$1" | cut -d '=' -f 2)")"
		shift
		;;

	script=*)
		script="$(get_real_path "$(echo "$1" | cut -d '=' -f 2)")"
		shift
		;;

	files=*)
		files="$(echo "$1" | cut -d '=' -f 2 | tr ',' ' ')"
		shift
		;;

	*)
		usage && die
		;;
	esac
done

{ test -n "$watch_dir" && test -n "$script" && test -n "$files" ;} ||
	{ usage && die ;}

test -r "$watch_dir" ||
	die "Please verify that you have permission to read '$watch_dir'."
{ test -f "$script" && test -x "$script" ;} ||
	die "Please verify that '$script' is a file and you have permission to execute it."

echo "Watching '$watch_dir' for changes to '$files'."
echo "Script to execute is '$script'."

inotifywait --quiet \
	--monitor  \
	--event close_write,moved_to \
	--format %f "$watch_dir" |
while read -r file; do
	if echo "$files" | grep -q "\b$file\b"; then
		echo "Running '$script $watch_dir/$file'"
		$script "$watch_dir/$file"
	fi
done
