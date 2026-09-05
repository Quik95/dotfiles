{
  pkgs,
  basePath ? null,
}: let
  typst-author = pkgs.fetchFromGitHub {
    owner = "apcamargo";
    repo = "typst-author";
    rev = "9e4ace023b255ffbd9dacd26fe27665eef9c6d4b";
    hash = "sha256-FCr+Cgi+mI9H2dtEgtrH93aj3hfolKhoP71EYiFOglo=";
  };

  skills = {
    ast-grep = ./ast-grep.md;
    bash-expert = ./bash.md;
    nix-best-practices = ./nix-best-practices.md;
    powershell-expert = ./powershell.md;
    semble = ./semble.md;
    typst-author = typst-author;
  };
in
  if basePath == null
  then skills
  else {
    "${basePath}/ast-grep/SKILL.md".source = skills.ast-grep;
    "${basePath}/bash-expert/SKILL.md".source = skills.bash-expert;
    "${basePath}/nix-best-practices/SKILL.md".source = skills.nix-best-practices;
    "${basePath}/powershell-expert/SKILL.md".source = skills.powershell-expert;
    "${basePath}/semble/SKILL.md".source = skills.semble;
    "${basePath}/typst-author" = {
      source = skills.typst-author;
      recursive = true;
    };
  }
