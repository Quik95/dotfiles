{...}: {
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["*"];
      settings.main = {
        # Keep keyboard remaps compositor-agnostic.
        capslock = "esc";
        esc = "capslock";
        print = "compose";
        f23 = "rightcontrol";
        "leftmeta+leftshift+f23" = "rightcontrol";
      };
    };
  };
}
