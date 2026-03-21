{lib, ...}: {
  imports =
    [
      ./common.nix
    ]
    ++ lib.pipe ./. [
      lib.filesystem.listFilesRecursive
      (lib.lists.filter (lib.strings.hasSuffix "nixos.nix"))
      (lib.lists.filter (path: path != ./nixos.nix))
    ];
}
