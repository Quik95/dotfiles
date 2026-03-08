apply_layout() {
	local hdmi_connector="$1"
	[ -n "$hdmi_connector" ] || return 1
	connector_exists "$hdmi_connector" || return 0

	if ! gnome-monitor-config set \
		-LpM "$hdmi_connector" -x 1920 -y 0 \
		-LM eDP-1 -x 0 -y 120; then
		printf "restore-monitors: failed to apply layout for %s\n" "$hdmi_connector" >&2
	fi
}

parse_connector_from_monitor_line() {
	local line="$1" rest
	case "$line" in
	*" [ "*)
		rest=${line#*" [ "}
		printf "%s\n" "${rest%% ]*}"
		return 0
		;;
	esac
	return 1
}

connector_exists() {
	local wanted="$1" line line_lc connector
	while IFS= read -r line; do
		line_lc=$(printf "%s" "$line" | tr "[:upper:]" "[:lower:]")
		case "$line_lc" in
		*"monitor [ "*"]"*)
			connector=$(parse_connector_from_monitor_line "$line") || continue
			[ "$connector" = "$wanted" ] && return 0
			;;
		esac
	done < <(gnome-monitor-config list 2>/dev/null)

	return 1
}

detect_active_hdmi_connector() {
	local line line_lc connector
	while IFS= read -r line; do
		line_lc=$(printf "%s" "$line" | tr "[:upper:]" "[:lower:]")
		case "$line_lc" in
		*"monitor [ hdmi-"*"] on"*)
			connector=$(parse_connector_from_monitor_line "$line") || continue
			printf "%s\n" "$connector"
			return 0
			;;
		esac
	done < <(gnome-monitor-config list 2>/dev/null)

	return 1
}

both_active() {
	local current="" hdmi_enabled=0 edp_enabled=0 line line_lc
	while IFS= read -r line; do
		line_lc=$(printf "%s" "$line" | tr "[:upper:]" "[:lower:]")
		case "$line_lc" in
		*"monitor [ hdmi-"*"] on"*)
			hdmi_enabled=1
			current="hdmi"
			;;
		*"monitor [ hdmi-"*"] off"*)
			hdmi_enabled=0
			current="hdmi"
			;;
		*"monitor [ edp-1 ] on"*)
			edp_enabled=1
			current="edp-1"
			;;
		*"monitor [ edp-1 ] off"*)
			edp_enabled=0
			current="edp-1"
			;;
		*"hdmi-"*)
			current="hdmi"
			;;
		*"edp-1"*)
			current="edp-1"
			;;
		*"enabled:"*"yes"* | *"enabled:"*"true"* | *"active:"*"yes"* | *"active:"*"true"*)
			if [ "$current" = "hdmi" ]; then
				hdmi_enabled=1
			elif [ "$current" = "edp-1" ]; then
				edp_enabled=1
			fi
			;;
		*"enabled:"*"no"* | *"enabled:"*"false"* | *"disabled"* | *"active:"*"no"* | *"active:"*"false"*)
			if [ "$current" = "hdmi" ]; then
				hdmi_enabled=0
			elif [ "$current" = "edp-1" ]; then
				edp_enabled=0
			fi
			;;
		esac
	done < <(gnome-monitor-config list 2>/dev/null)

	[ "$hdmi_enabled" -eq 1 ] && [ "$edp_enabled" -eq 1 ]
}

wait_until_both_active() {
	local timeout_secs="${1:-10}"
	local elapsed=0

	while [ "$elapsed" -lt "$timeout_secs" ]; do
		if both_active; then
			return 0
		fi
		sleep 1
		elapsed=$((elapsed + 1))
	done

	return 1
}

apply_when_ready() {
	local hdmi_connector
	if wait_until_both_active 10; then
		# Add a small settle delay so Mutter completes mode transitions.
		sleep 1
		hdmi_connector=$(detect_active_hdmi_connector) || return 0
		apply_layout "$hdmi_connector"
	fi
}

sleep 2
apply_when_ready

last_apply=0
gdbus monitor --session \
	--dest org.gnome.Mutter.DisplayConfig \
	--object-path /org/gnome/Mutter/DisplayConfig |
	while IFS= read -r line; do
		case "$line" in
		*MonitorsChanged*)
			now=$(date +%s)
			if [ $((now - last_apply)) -lt 2 ]; then
				continue
			fi
			last_apply=$now
			apply_when_ready
			;;
		esac
	done
