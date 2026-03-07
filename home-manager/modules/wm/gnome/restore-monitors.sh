apply_layout() {
	gnome-monitor-config set \
		-LpM HDMI-1 -x 1920 -y 0 \
		-LM eDP-1 -x 0 -y 120
}

both_active() {
	local current="" hdmi_enabled=0 edp_enabled=0 line line_lc
	while IFS= read -r line; do
		line_lc=$(printf "%s" "$line" | tr "[:upper:]" "[:lower:]")
		case "$line_lc" in
		*"monitor [ hdmi-1 ] on"*)
			hdmi_enabled=1
			current="hdmi-1"
			;;
		*"monitor [ hdmi-1 ] off"*)
			hdmi_enabled=0
			current="hdmi-1"
			;;
		*"monitor [ edp-1 ] on"*)
			edp_enabled=1
			current="edp-1"
			;;
		*"monitor [ edp-1 ] off"*)
			edp_enabled=0
			current="edp-1"
			;;
		*"hdmi-1"*)
			current="hdmi-1"
			;;
		*"edp-1"*)
			current="edp-1"
			;;
		*"enabled:"*"yes"* | *"enabled:"*"true"* | *"active:"*"yes"* | *"active:"*"true"*)
			if [ "$current" = "hdmi-1" ]; then
				hdmi_enabled=1
			elif [ "$current" = "edp-1" ]; then
				edp_enabled=1
			fi
			;;
		*"enabled:"*"no"* | *"enabled:"*"false"* | *"disabled"* | *"active:"*"no"* | *"active:"*"false"*)
			if [ "$current" = "hdmi-1" ]; then
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
	if wait_until_both_active 10; then
		# Add a small settle delay so Mutter completes mode transitions.
		sleep 1
		apply_layout
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
