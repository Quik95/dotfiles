{
  pkgs,
  config,
  ...
}: let
  skillsDirectory = "${config.home.homeDirectory}/.claude/skills";

  typst-author = pkgs.fetchFromGitHub {
    owner = "apcamargo";
    repo = "typst-author";
    rev = "9e4ace023b255ffbd9dacd26fe27665eef9c6d4b";
    hash = "sha256-FCr+Cgi+mI9H2dtEgtrH93aj3hfolKhoP71EYiFOglo=";
  };
in {
  home.file."${skillsDirectory}/bash-expert/SKILL.md".source = ./skills/bash.md;
  home.file."${skillsDirectory}/dotnet-core-expert/SKILL.md".source = ./skills/dotnet.md;
  home.file."${skillsDirectory}/powershell-expert/SKILL.md".source = ./skills/powershell.md;
  home.file."${skillsDirectory}/typst-author/SKILL.md".source = "${typst-author}/SKILL.md";
  home.file."${skillsDirectory}/typst-author/docs" = {
    source = "${typst-author}/docs";
    recursive = true;
  };

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
  };
}