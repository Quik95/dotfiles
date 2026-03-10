{
  pkgs,
  lib,
}: {
  pkg,
  binary,
  vars,
}: let
  exportCmd =
    lib.concatStringsSep "; "
    (lib.mapAttrsToList (
        name: path: "export ${name}=\"$(cat ${lib.escapeShellArg (toString path)})\""
      )
      vars);
in
  pkgs.symlinkJoin (
    {
      name = "${pkg.pname or pkg.name}-wrapped";
      paths = [pkg];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/${binary} --run ${lib.escapeShellArg exportCmd}
      '';
    }
    // lib.optionalAttrs (pkg ? version) {
      inherit (pkg) version;
    }
  )
