{
  config,
  lib,
  ...
}:
lib.mkIf config.nixfiles.passwordless-sudo.enable {
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
}
