# dotfiles

NixOS + Home Manager flake for Sebastian's laptops.

## Tymczasowy bootstrap: `sebastian-laptop-legion`

Konfiguracja `sebastian-laptop-legion` jest obecnie oparta o tymczasowy import
`hardware-configuration.nix` z LOQ. Przed normalnym używaniem wygeneruj i podmień
własny plik hardware dla Legiona.

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

### 3) Wygeneruj docelowy `hardware-configuration.nix` dla Legiona

```bash
sudo nixos-generate-config --show-hardware-config > /tmp/hardware-configuration.nix
cp /tmp/hardware-configuration.nix ./nixos/hosts/sebastian-laptop-legion/hardware-configuration.nix
```

Następnie w `nixos/hosts/sebastian-laptop-legion/configuration.nix` podmień import:

- z `../sebastian-laptop-loq/hardware-configuration.nix`
- na `./hardware-configuration.nix`

### 4) Walidacja i aktywacja

```bash
nix flake show --no-write-lock-file
nix build .#nixosConfigurations.sebastian-laptop-legion.config.system.build.toplevel --dry-run --quiet
nix build .#homeConfigurations."sebastian@sebastian-laptop-legion".activationPackage --dry-run --quiet
sudo nixos-rebuild switch --flake .#sebastian-laptop-legion --quiet
home-manager switch --flake .#sebastian@sebastian-laptop-legion
```

## Flatpak na Legionie (ręcznie)

Automatyczna instalacja Flatpaków jest tymczasowo wyłączona dla
`sebastian-laptop-legion`, żeby uniknąć timeoutów podczas bootstrapu.

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
