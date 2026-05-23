{
  pkgs,
  config,
}:
pkgs.writeShellScript "unlock-gpg-keys" ''
  set -euo pipefail
  preset_key() {
    local key_file="$1" passphrase_file="$2" passphrase grip
    passphrase=$(cat "$passphrase_file")
    while IFS= read -r grip; do
      [[ -n "$grip" ]] || continue
      printf '%s' "$passphrase" | \
        ${pkgs.gnupg}/bin/gpg-preset-passphrase --preset "$grip"
    done < <(
      ${pkgs.gnupg}/bin/gpg --homedir ${config.programs.gpg.homedir} \
        --show-keys --with-keygrip --with-colons "$key_file" 2>/dev/null \
        | grep '^grp' | cut -d: -f10
    )
  }
  preset_key \
    ${config.sops.secrets.master-private-gpg-key.path} \
    ${config.sops.secrets.master-gpg-passphrase.path}
  preset_key \
    ${config.sops.secrets.gitlab-cs-put-gpg-private-key.path} \
    ${config.sops.secrets.gitlab-cs-put-gpg-passphrase.path}
''
