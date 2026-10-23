{lib, ...}: let
  isGnome = (import ../../shared/desktop.nix).desktop == "gnome";
in {
  services.flatpak = {
    enable = true;

    packages =
      [
        "com.github.flxzt.rnote"
        "com.github.marhkb.Pods"
        "com.github.rafostar.Clapper"
        "com.github.tchx84.Flatseal"
        "com.modrinth.ModrinthApp"
        "com.spotify.Client"
        "dev.vencord.Vesktop"
        "garden.jamie.Morphosis"
        "org.gnome.Fractal"
        "org.gnome.gitlab.somas.Apostrophe"
        "org.libreoffice.LibreOffice"
        "org.nickvision.money"
        "page.tesk.Refine"
      ]
      ++ lib.optionals isGnome [
        "be.alexandervanhee.gradia"
        "com.mattjakeman.ExtensionManager"
      ];
    uninstallUnmanaged = true;

    overrides = {
      "org.libreoffice.LibreOffice".Context = {
        filesystems = [
          "/tmp:rw"
        ];
      };
      # WebKitGTK's DMABUF renderer on the NVIDIA driver dies with Wayland
      # "Error 71" under explicit sync. Flathub's metadata works around it with
      # WEBKIT_DISABLE_DMABUF_RENDERER=1, which disables GPU rendering in the
      # web process and makes the UI lag. Re-enable it and fall back to
      # implicit sync instead. The environment is inherited by Minecraft, so it
      # must not restrict GL vendors or devices.
      "com.modrinth.ModrinthApp".Environment = {
        WEBKIT_DISABLE_DMABUF_RENDERER = "0";
        __NV_DISABLE_EXPLICIT_SYNC = "1";
      };
    };

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
