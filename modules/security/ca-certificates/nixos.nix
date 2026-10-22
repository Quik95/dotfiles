{
  lib,
  pkgs,
  ...
}: let
  # eMudhra generated eight intermediates under this root with P-384 private keys
  # below 256 (one was 4), so anyone can sign certificates that chain to it.
  # Mozilla dropped the root in NSS 3.131.1; distrust it until cacert ships that
  # release, then warn that the override can go.
  # https://bugzilla.mozilla.org/show_bug.cgi?id=2083449
  emudhraFixed = lib.versionAtLeast pkgs.cacert.version "3.131.1";
in {
  security.pki.caCertificateBlacklist =
    lib.warnIf emudhraFixed ''
      cacert ${pkgs.cacert.version} no longer trusts emSign ECC Root CA - G3: remove
      modules/security/ca-certificates/nixos.nix.
    ''
    (lib.optional (!emudhraFixed) "emSign ECC Root CA - G3");
}
