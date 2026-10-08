# dotfiles

NixOS + Home Manager flake dla laptopa Sebastiana.

Available configurations: `sebastian-laptop-legion`.

## Dodawanie hosta

W `flake.nix` dodaj wpis w `hosts`, wskazując `nixosModule` na
`./nixos/hosts/<hostname>/configuration.nix` i `homeModule` na
`./home-manager/hosts/<hostname>.nix`. Utwórz te pliki, ustaw
`networking.hostName` na tę samą nazwę i zaimportuj wygenerowaną konfigurację
sprzętu w module NixOS. Flake automatycznie udostępni konfigurację NixOS,
profil `sebastian@<hostname>` i check Home Managera (obecnie dla `x86_64-linux`).

Wspólne ustawienia pozostają w `modules/`, a wyjątki dla maszyny w plikach
hosta. Nowe pliki dodaj do Git, aby flake je widział.

### Wybór środowiska graficznego

Środowisko graficzne wybiera `shared/desktop.nix` (`"plasma"` albo `"gnome"`).
Wszystkie moduły zależne od pulpitu — `modules/wm/plasma/*`, `modules/wm/gnome/*`
oraz miejsca, które instalują inne aplikacje per pulpit (`modules/default-apps`,
`modules/flatpak`, `modules/ssh`, `modules/multimedia/mpv.nix`) — sprawdzają tę
wartość zamiast `hostname`. Po zmianie potrzebny jest rebuild NixOS i Home
Managera oraz ponowne zalogowanie (nowa sesja wybierana w GDM/SDDM).

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

Po dodaniu katalogu nowego hosta (tu: `nowy-host`) wygeneruj jego konfigurację
sprzętową. Nie zastępuj ręcznie pliku istniejącego hosta.

```bash
sudo nixos-generate-config --show-hardware-config > nixos/hosts/nowy-host/hardware-configuration.nix
```

Upewnij się, że `nixos/hosts/nowy-host/configuration.nix` importuje ten plik.

### 4) Walidacja i aktywacja

Poniższe polecenia dotyczą istniejącego hosta `sebastian-laptop-legion`;
dla nowej maszyny zastąp tę nazwę identyfikatorem wpisu w `hosts` w `flake.nix`:

```bash
nix flake show --no-write-lock-file
nix build '.#nixosConfigurations.sebastian-laptop-legion.config.system.build.toplevel' --dry-run --quiet
nix build '.#homeConfigurations."sebastian@sebastian-laptop-legion".activationPackage' --dry-run --quiet
sudo nixos-rebuild switch --flake .#sebastian-laptop-legion --quiet
home-manager switch --flake '.#sebastian@sebastian-laptop-legion'
```

## Przeglądarka agentów AI

`agent-browser` (CLI i wspólny serwer MCP) używa CloakBrowser zamiast zwykłego
Chromium, w widocznym oknie. OMP również otrzymuje ten serwer MCP; jego
wbudowana przeglądarka jest wyłączona (`browser.enabled = false`).

Pakiet pochodzi z oficjalnego flake'a `github:CloakHQ/CloakBrowser`, przypiętego
w `flake.lock` i korzystającego ze wspólnego inputu `nixpkgs`. Obecny pakiet
udostępnia darmowy silnik Chromium 146; nowsze wydania wymagają klucza
CloakBrowser i nie są w tej konfiguracji aktywowane.

Konfiguracja jest w `modules/ai/mcp.nix`: `executablePath` dla CLI
(`~/.agent-browser/config.json`) oraz `AGENT_BROWSER_EXECUTABLE_PATH` dla MCP.
Wspólne globalne instrukcje w `modules/ai/home.nix` zawierają sekcję
`Browser Automation` i trafiają do Codexa, Claude Code, agy oraz OMP
(`~/.omp/agent/AGENTS.md`). Zmiany instrukcji i narzędzi wczytuje nowa sesja agenta.

Po zmianie zamknij dotychczasową sesję przeglądarki albo utwórz nową:

```bash
agent-browser --session cloakbrowser open https://example.com
agent-browser --session cloakbrowser snapshot
agent-browser --session cloakbrowser close
```

Aktualizacja przypiętego flake'a: `nix flake update cloakbrowser`, następnie
aktywacja Home Managera. Nie potrzeba `agent-browser install`.

## Flatpaki

Lista aplikacji jest w `modules/flatpak/home.nix`. Część pakietów zależy od
środowiska wybranego w `shared/desktop.nix`; Home Manager zarządza instalacją
przez `services.flatpak`. Przy ręcznej instalacji (gdy automatyczna jest
wyłączona) dodaj Flathub i zainstaluj potrzebny identyfikator z tego modułu,
np. `org.libreoffice.LibreOffice`:

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.libreoffice.LibreOffice
```
