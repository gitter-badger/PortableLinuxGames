#!/bin/sh

get_resolution() { xrandr | grep \* | cut -d' ' -f4; }
set_resolution() { xrandr -s $1; }

run_oss() { if [ $(which padspp 2>/dev/null) ]; then padsp $@; else $@; fi; }
run_shell() { if [[ $(tty) = "not a tty" ]]; then xterm -e "$@"; else $@; fi; }
run_keepResolution()
{
	resolution=$(get_resolution)
	restore_resolution() { set_resolution "$resolution"; }
	trap restore_resolution EXIT

	$@

	restore_resolution
}

overlay_setup()
{
	local ro_data_path="$1"; shift
	local app="$1"; shift

	local config_dir="$HOME/.$app"
	local rw_data_path="$config_dir/data"
	overlay_path="$config_dir/overlay"

	mkdir -p "$overlay_path" || return 1
	mkdir -p "$rw_data_path" || return 1

	overlay_cleanup() { fusermount -u "$overlay_path"; }

	unionfs -o cow "$rw_data_path"=RW:"$ro_data_path"=RO "$overlay_path" || return 1
	trap overlay_cleanup EXIT

	pushd "$overlay_path"
	./$app $@
	popd

	overlay_cleanup
}

build_report()
{
	logfile="$1"; shift
	bin="$1"; shift

	echo "<html><body>"
	echo "<p>Looks like the package has crashed, sorry about that!</p>"
	echo "<p>Please help us fix this error sending this log file to <a href='mailto:tux@portablelinuxgames.org'>tux@portablelinuxgames.org</a>, if possible commenting how the game crashed.</p>"
	echo "The binary returned $ret"

	echo "<h2>System information</h2>"
	echo "<pre>"
	echo "** Uname: $(uname -a)"
	for i in /etc/*-release; do
		echo "** $i:"
		cat "$i"
	done
	echo "</pre>"

	if [ -f "$logfile" ]; then
		echo "<h2>Game output</h2>"
		echo "<pre>"
		cat "$logfile"
		echo "</pre>"
	fi

	if [ -f "$bin" ]; then
		echo "<h2>ldd output</h2>"
		echo "<pre>"
		ldd "$BINARY"
		echo "</pre>"
	fi

	echo "</body></html>"
}