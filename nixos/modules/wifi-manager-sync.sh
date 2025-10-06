#!/usr/bin/env bash

# Declarative WiFi state synchronization
# Enforces: ethernet connected → WiFi off, ethernet disconnected → WiFi on

set -euo pipefail

# Check if any ethernet interface has carrier
has_ethernet_connection() {
  shopt -s nullglob
  for iface in /sys/class/net/en* /sys/class/net/eth*; do
    if [ -e "$iface/carrier" ]; then
      carrier=$(cat "$iface/carrier" 2>/dev/null || echo "0")
      if [ "$carrier" = "1" ]; then
        shopt -u nullglob
        return 0
      fi
    fi
  done
  shopt -u nullglob
  return 1
}

# Get current WiFi state (on/off)
get_wifi_state() {
  @nmcli@ radio wifi
}

# Determine desired WiFi state based on ethernet
desired_wifi_state() {
  if has_ethernet_connection; then
    echo "disabled"
  else
    echo "enabled"
  fi
}

# Sync WiFi to desired state
sync_wifi_state() {
  local desired=$(desired_wifi_state)
  local current=$(get_wifi_state)
  
  if [ "$desired" = "disabled" ] && [ "$current" = "enabled" ]; then
    logger -t wifi-manager "Ethernet connected → disabling WiFi"
    @nmcli@ radio wifi off
  elif [ "$desired" = "enabled" ] && [ "$current" = "disabled" ]; then
    logger -t wifi-manager "No ethernet → enabling WiFi"
    @nmcli@ radio wifi on
  else
    logger -t wifi-manager "WiFi state already correct ($([ "$current" = "enabled" ] && echo "on" || echo "off"))"
  fi
}

# Main execution
sync_wifi_state
