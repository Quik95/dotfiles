# dotfiles

NixOS + Home Manager flake for Sebastian's laptops.

Available configurations: `sebastian-laptop-hp`, `sebastian-laptop-loq`, `sebastian-laptop-legion`.

## Unified modules (nixfiles)

Repo korzysta teraz z układu modułów inspirowanego "Unified Modules":

- `modules/common.nix` - opcje wspólne (`nixfiles.*`) + automatyczny import `common.nix` i `home.nix`.
- `modules/nixos.nix` - główny moduł NixOS, automatycznie importuje wszystkie `nixos.nix`.
- `modules/home-standalone.nix` - automatyczny import `home.nix` dla `homeConfigurations` (bez `core/home.nix`).
- `modules/<kategoria>/<modul>/common.nix` - deklaracje opcji.
- `modules/<kategoria>/<modul>/nixos.nix` - konfiguracja systemowa.
- `modules/<kategoria>/<modul>/home.nix` - konfiguracja Home Manager (opcjonalna).

W hostach NixOS aktywujesz to przez:

```nix
nixfiles.enable = true;
```

## Bootstrap na świeżej instalacji

### 1) Sklonuj repo

```bash
git clone <repo-url> ~/Documents/dotfiles
cd ~/Documents/dotfiles
```

### 2) Skopiuj klucze SOPS

```bash
sudo install -Dm600 "<sciezka-z-backupu>/key.txt" "/var/lib/sops-nix/key.txt"
install -Dm600 "<sciezka-z-backupu>/keys.txt" "$HOME/.config/sops/age/keys.txt"
```

### 3) Wygeneruj `hardware-configuration.nix` dla nowej maszyny

```bash
sudo nixos-generate-config --show-hardware-config > /tmp/hardware-configuration.nix
cp /tmp/hardware-configuration.nix ./nixos/hosts/<hostname>/hardware-configuration.nix
```

Upewnij się, że `nixos/hosts/<hostname>/configuration.nix` importuje ten plik.

### 4) Walidacja i aktywacja

Zastąp `<hostname>` odpowiednią nazwą konfiguracji (np. `sebastian-laptop-legion`):

```bash
nix flake show --no-write-lock-file
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel --dry-run --quiet
nix build .#homeConfigurations."sebastian@<hostname>".activationPackage --dry-run --quiet
sudo nixos-rebuild switch --flake .#<hostname> --quiet
home-manager switch --flake .#"sebastian@<hostname>"
```

## Flatpaki (ręcznie, jeśli automatyczna instalacja jest wyłączona)

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub \
  be.alexandervanhee.gradia \
  com.github.flxzt.rnote \
  com.github.marhkb.Pods \
  com.github.rafostar.Clapper \
  com.github.tchx84.Flatseal \
  com.google.Chrome \
  com.mattjakeman.ExtensionManager \
  com.spotify.Client \
  com.valvesoftware.Steam \
  dev.vencord.Vesktop \
  garden.jamie.Morphosis \
  org.gnome.Fractal \
  org.gnome.Papers \
  org.gnome.gitlab.somas.Apostrophe \
  org.libreoffice.LibreOffice \
  org.nickvision.money \
  page.tesk.Refine
```
