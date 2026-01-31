apply_layout() {
	gnome-monitor-config set \
		-LpM HDMI-1 -x 0 -y 0 \
		-LM eDP-1 -x 0 -y 1200
}

both_active() {
	local current="" hdmi_enabled=0 edp_enabled=0 line line_lc
	while IFS= read -r line; do
		line_lc=$(printf "%s" "$line" | tr "[:upper:]" "[:lower:]")
		case "$line_lc" in
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

maybe_apply_layout() {
	if both_active; then
		sleep 1
		apply_layout
	fi
}

sleep 2
maybe_apply_layout

last_apply=0
gdbus monitor --session \
	--dest org.gnome.Mutter.DisplayConfig \
	--object-path /org/gnome/Mutter/DisplayConfig |
	while IFS= read -r line; do
		case "$line" in
		*MonitorsChanged*)
			if ! both_active; then
				continue
			fi
			now=$(date +%s)
			if [ $((now - last_apply)) -lt 2 ]; then
				continue
			fi
			last_apply=$now
			sleep 1
			apply_layout
			;;
		esac
	done
