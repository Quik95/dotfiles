{lib, ...}: {
  imports = lib.pipe ./. [
    lib.filesystem.listFilesRecursive
    (lib.lists.filter (lib.strings.hasSuffix "common.nix"))
    (lib.lists.filter (path: path != ./common.nix))
  ];

  options.nixfiles.enable = lib.mkEnableOption "unified Nixfiles module tree";
}
