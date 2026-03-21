{lib, ...}: {
  options.nixfiles.eduroam.interfaceName = lib.mkOption {
    type = lib.types.str;
    description = "Wi-Fi interface name used by the eduroam NetworkManager profile.";
    example = "wlp9s0";
  };
}
