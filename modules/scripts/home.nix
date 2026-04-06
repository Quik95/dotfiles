{pkgs, ...}: {
  home.packages = [
    (pkgs.writeScriptBin "link-coding-agents-context" ''
      #!${pkgs.powershell}/bin/pwsh
      ${builtins.readFile ./link-agents.ps1}
    '')
    (pkgs.writeScriptBin "toggle-passwordless-sudo" ''
      #!${pkgs.bash}/bin/bash
      ${builtins.readFile ./toggle-passwordless-sudo.sh}
    '')
  ];
}
