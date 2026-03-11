{
  config,
  lib,
  ...
}: {
  options.dotfiles.passwordless-sudo.enable = lib.mkEnableOption "passwordless sudo for sebastian";

  config = lib.mkIf config.dotfiles.passwordless-sudo.enable {
    security.sudo.extraRules = [
      {
        users = ["sebastian"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
}
