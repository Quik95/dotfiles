{
  config,
  ...
}: let
  skillsDirectory = "${config.home.homeDirectory}/.claude/skills";
in {
  home.file."${skillsDirectory}/bash-expert/SKILL.md".source = ./skills/bash.md;
  home.file."${skillsDirectory}/dotnet-core-expert/SKILL.md".source = ./skills/dotnet.md;
  home.file."${skillsDirectory}/powershell-expert/SKILL.md".source = ./skills/powershell.md;

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
  };
}
