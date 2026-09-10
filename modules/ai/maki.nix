{
  config,
  lib,
  pkgs,
  aiAgentsSystemInstruction,
  ...
}: let
  makiVersion = "0.5.3";

  maki = pkgs.stdenvNoCC.mkDerivation {
    pname = "maki";
    version = makiVersion;

    src = pkgs.fetchurl {
      url = "https://github.com/tontinton/maki/releases/download/v${makiVersion}/maki-v${makiVersion}-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-OHeUAqJP92nm9tFoTURkPrWqfbmCToPxy7zjjg4vC64=";
    };

    nativeBuildInputs = [pkgs.gnutar];
    unpackPhase = "tar -xzf $src";
    installPhase = "install -Dm755 maki $out/bin/maki";
  };

  makiconf = pkgs.fetchFromGitHub {
    owner = "tontinton";
    repo = "makiconf";
    rev = "b4fde8c27c1f88cd1e5ccf19c34e8629a669b1fa";
    hash = "sha256-UJ7dNJpqL1+ZWYTr+HgHImBZ88NaMWGjVVTZw/E81F4=";
  };
in {
  home.packages = [maki];

  xdg.configFile = {
    "maki/AGENTS.md".text = ''
      ${aiAgentsSystemInstruction}

      ## Efficient code search

      - Use `semble` for semantic questions such as "How does X work?" or when the relevant symbols are unknown. It returns focused snippets and avoids broad grep/read output.
      - Use `grep` for known symbols and exhaustive reference searches.
      - Use `ast-grep` for precise structural search or AST-safe repetitive replacements; search before replacing.
    '';
    "maki/lua/semble.lua".source = "${makiconf}/lua/semble.lua";
    "maki/plugin.toml".source = (pkgs.formats.toml {}).generate "maki-plugin.toml" {
      permissions = {
        env = true;
        run = true;
      };
    };
    "maki/init.lua".text = ''
      maki.setup({
          always_yolo = true,
          ui = {
              theme = "tokyonight",
              tool_output_lines = {
                  bash = 8,
                  read = 5,
              },
          },
          agent = {
              rtk = true,
          },
          provider = {
              default_model = "openai/gpt-5.6-terra",
          },
          storage = {
              max_log_files = 5,
          },
      })
    '';
    "maki/mcp.toml".source = (pkgs.formats.toml {}).generate "maki-mcp.toml" {
      mcp =
        lib.mapAttrs (
          _: server:
            (
              if server.command != null
              then {
                command = [server.command] ++ server.args;
                environment = server.env;
              }
              else {
                inherit (server) headers url;
              }
            )
            // lib.optionalAttrs (server.enabled != null) {
              inherit (server) enabled;
            }
        )
        config.programs.mcp.servers;
    };
  };
}
