{
  inputs,
  basePath ? null,
}: let
  typst-author = "${inputs.typst-skills}/typst-author";

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
