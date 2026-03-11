{
  config,
  pkgs,
  ...
}: let
  ns = "tryhackme";
  # Interface names must be <=15 chars (Linux IFNAMSIZ limit).
  veth-host = "veth-thm";
  veth-ns = "veth-thm-ns";
  subnet = "10.200.200";

  script = pkgs.writeShellScript "tryhackme-vpn-script" ''
    set -euo pipefail

    OVPN_CONFIG="${config.sops.secrets.tryhackme-openvpn.path}"
    CALLING_USER="''${SUDO_USER:-$(logname)}"

    cleanup() {
      echo "Cleaning up namespace '${ns}'..."
      ip netns pids "${ns}" 2>/dev/null | xargs -r kill 2>/dev/null || true
      sleep 1
      ip netns del "${ns}" 2>/dev/null || true
      ip link del "${veth-host}" 2>/dev/null || true
      rm -rf /etc/netns/${ns}
    }
    trap cleanup EXIT

    # Create an isolated network namespace for VPN traffic
    ip netns add "${ns}"
    ip netns exec "${ns}" ip link set lo up

    # Create a veth pair bridging the host and namespace
    ip link add "${veth-host}" type veth peer name "${veth-ns}"
    ip link set "${veth-ns}" netns "${ns}"

    ip addr add ${subnet}.1/24 dev "${veth-host}"
    ip link set "${veth-host}" up

    ip netns exec "${ns}" ip addr add ${subnet}.2/24 dev "${veth-ns}"
    ip netns exec "${ns}" ip link set "${veth-ns}" up
    ip netns exec "${ns}" ip route add default via ${subnet}.1

    # DNS: copy host resolv.conf so the namespace can resolve names
    mkdir -p /etc/netns/${ns}
    cp /etc/resolv.conf /etc/netns/${ns}/resolv.conf

    # Start OpenVPN inside the namespace
    ip netns exec "${ns}" ${pkgs.openvpn}/bin/openvpn \
      --config "$OVPN_CONFIG" \
      --auth-nocache \
      --daemon --log /tmp/openvpn-${ns}.log

    echo "Waiting for VPN to connect..."
    for _ in $(seq 1 30); do
      if ip netns exec "${ns}" ip link show tun0 &>/dev/null; then
        echo "VPN connected."
        break
      fi
      sleep 1
    done

    if ! ip netns exec "${ns}" ip link show tun0 &>/dev/null; then
      echo "Warning: tun0 not detected after 30s. Check /tmp/openvpn-${ns}.log"
    fi

    # Drop into an interactive shell inside the VPN namespace
    echo "Entering VPN shell. Type 'exit' to disconnect."
    ip netns exec "${ns}" sudo -u "$CALLING_USER" "${pkgs.fish}/bin/fish" || true
  '';

  wrapper = pkgs.writeShellScriptBin "tryhackme-vpn" ''
    exec sudo ${script}
  '';
in {
  environment.systemPackages = [wrapper];

  # NAT: masquerade traffic from the VPN namespace so it can reach the internet
  networking.nat = {
    enable = true;
    internalInterfaces = [veth-host];
  };

  # Allow forwarding traffic to/from the VPN namespace through the firewall
  networking.firewall.extraForwardRules = ''
    iifname "${veth-host}" accept
    oifname "${veth-host}" accept
  '';

  # TTL workaround: some networks (e.g. university) deliver packets with TTL=1.
  # The kernel checks TTL *before* the FORWARD chain (in ip_forward()), so
  # packets with TTL=1 are dropped with "time exceeded" before reaching the
  # namespace. We increment TTL in mangle PREROUTING for reply packets belonging
  # to connections originating from the namespace (matched via conntrack).
  networking.firewall.extraCommands = ''
    iptables -t mangle -A PREROUTING -m conntrack --ctorigsrc ${subnet}.0/24 -j TTL --ttl-inc 1
  '';
  networking.firewall.extraStopCommands = ''
    iptables -t mangle -D PREROUTING -m conntrack --ctorigsrc ${subnet}.0/24 -j TTL --ttl-inc 1 || true
  '';
}
