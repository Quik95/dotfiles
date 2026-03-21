{pkgs, ...}: {
  home.packages = [
    (pkgs.writeScriptBin "link-coding-agents-context" ''
      #!${pkgs.powershell}/bin/pwsh
      ${builtins.readFile ./link-agents.ps1}
    '')
  ];
}
