{pkgs, ...}: {
  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_macchiato";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
    };
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.alejandra}/bin/alejandra";
      }
    ];
  };
}
