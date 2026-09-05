{
  config,
  lib,
  pkgs,
  aiAgentsSystemInstruction,
  llm-agents,
  ...
}: let
  llmAgentsPkgs = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  maki = pkgs.stdenvNoCC.mkDerivation {
    pname = "maki";
    version = "0.5.1";

    src = pkgs.fetchurl {
      url = "https://github.com/tontinton/maki/releases/download/v0.5.1/maki-v0.5.1-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-H00/EvkCnKbMw3ONFb3w+JouDeDHZNNgiX5QgQLktb4=";
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

  astGrepMcp = pkgs.writeShellApplication {
    name = "maki-ast-grep-mcp";
    runtimeInputs = [pkgs.ast-grep pkgs.jq];
    text = ''
      send_response() {
        printf '%s\n' "$1"
      }

      while IFS= read -r line; do
        line="''${line%%$'\r'}"
        [ -n "$line" ] || continue

        method=$(printf '%s' "$line" | jq -r '.method // empty')
        id=$(printf '%s' "$line" | jq -r '.id // empty')

        case "$method" in
          initialize)
            send_response "{\"jsonrpc\":\"2.0\",\"id\":$id,\"result\":{\"protocolVersion\":\"2024-11-05\",\"capabilities\":{\"tools\":{}},\"serverInfo\":{\"name\":\"ast-grep\",\"version\":\"1.0.0\"}}}"
            ;;
          tools/list)
            jq -cn --argjson id "$id" '{jsonrpc:"2.0",id:$id,result:{tools:[
              {name:"search",description:"Find code by AST pattern. $NAME metavariables match one AST node and $$$NAME match multiple nodes. Use for precise structural code searches.",inputSchema:{type:"object",properties:{pattern:{type:"string",description:"AST pattern"},language:{type:"string",description:"Source language"},paths:{type:"array",items:{type:"string"},description:"Files or directories; defaults to the working directory."},globs:{type:"array",items:{type:"string"},description:"Include or exclude globs."}},required:["pattern","language"]}},
              {name:"search_and_replace",description:"Replace code by AST pattern. Always use search first to verify the matches.",inputSchema:{type:"object",properties:{pattern:{type:"string",description:"AST pattern"},rewrite:{type:"string",description:"Replacement using metavariables from pattern"},language:{type:"string",description:"Source language"},paths:{type:"array",items:{type:"string"},description:"Files or directories; defaults to the working directory."},globs:{type:"array",items:{type:"string"},description:"Include or exclude globs."}},required:["pattern","rewrite","language"]}}
            ]}}'
            ;;
          tools/call)
            tool=$(printf '%s' "$line" | jq -r '.params.name // empty')
            args=$(printf '%s' "$line" | jq -c '.params.arguments // {}')
            pattern=$(printf '%s' "$args" | jq -r '.pattern // empty')
            language=$(printf '%s' "$args" | jq -r '.language // empty')
            rewrite=$(printf '%s' "$args" | jq -r '.rewrite // empty')

            if [ -z "$pattern" ] || [ -z "$language" ]; then
              jq -cn --argjson id "$id" '{jsonrpc:"2.0",id:$id,result:{content:[{type:"text",text:"Error: pattern and language are required."}],isError:true}}'
              continue
            fi

            cmd=(ast-grep run --pattern "$pattern" --lang "$language" --json=compact)
            while IFS= read -r glob; do
              cmd+=(--globs "$glob")
            done < <(printf '%s' "$args" | jq -r '.globs[]?')
            while IFS= read -r path; do
              cmd+=("$path")
            done < <(printf '%s' "$args" | jq -r '.paths[]?')

            if [ "$tool" = "search_and_replace" ]; then
              if [ -z "$rewrite" ]; then
                jq -cn --argjson id "$id" '{jsonrpc:"2.0",id:$id,result:{content:[{type:"text",text:"Error: rewrite is required."}],isError:true}}'
                continue
              fi
              "''${cmd[@]}" --rewrite "$rewrite" --update-all >/dev/null
              output="Replaced matching AST nodes."
            else
              output=$("''${cmd[@]}" 2>&1) || output="[]"
              output=$(printf '%s' "$output" | jq -r 'if length == 0 then "No matches found." else .[] | "\(.file):\(.range.start.line + 1):\(.range.start.column + 1)\n  \(.lines | gsub("^\\s+"; "") | gsub("\\n$"; ""))" end')
            fi

            jq -cn --argjson id "$id" --arg text "$output" '{jsonrpc:"2.0",id:$id,result:{content:[{type:"text",text:$text}]}}'
            ;;
        esac
      done
    '';
  };
in {
  home.packages = [maki llmAgentsPkgs.semble pkgs.ast-grep];

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
        {
          ast-grep = {
            command = ["${astGrepMcp}/bin/maki-ast-grep-mcp"];
          };
        }
        // lib.mapAttrs (
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
