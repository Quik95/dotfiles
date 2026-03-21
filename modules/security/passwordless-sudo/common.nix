{lib, ...}: {
  options.nixfiles.passwordless-sudo.enable = lib.mkEnableOption "passwordless sudo for sebastian";
}
