{
  pkgs,
  basePath,
}: let
  typst-author = pkgs.fetchFromGitHub {
    owner = "apcamargo";
    repo = "typst-author";
    rev = "9e4ace023b255ffbd9dacd26fe27665eef9c6d4b";
    hash = "sha256-FCr+Cgi+mI9H2dtEgtrH93aj3hfolKhoP71EYiFOglo=";
  };
in {
  "${basePath}/bash-expert/SKILL.md".source = ./bash.md;
  "${basePath}/dotnet-core-expert/SKILL.md".source = ./dotnet.md;
  "${basePath}/powershell-expert/SKILL.md".source = ./powershell.md;
  "${basePath}/typst-author/SKILL.md".source = "${typst-author}/SKILL.md";
  "${basePath}/typst-author/docs" = {
    source = "${typst-author}/docs";
    recursive = true;
  };
}
