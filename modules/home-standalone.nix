{lib, ...}: {
  imports = lib.pipe ./. [
    lib.filesystem.listFilesRecursive
    (lib.lists.filter (lib.strings.hasSuffix "home.nix"))
  ];
}
