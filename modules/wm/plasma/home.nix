{
  config,
  lib,
  pkgs,
  ...
}: let
  isPlasma = (import ../../../shared/desktop.nix).desktop == "plasma";
in {
  imports = [
    ./appearance.nix
    ./behavior.nix
    ./ai-usage.nix
    ./panel.nix
    ./syspeek.nix
  ];

  config = lib.mkIf isPlasma {
    programs.plasma = {
      enable = true;
      session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
    };

    home.packages = [pkgs.kdePackages.kcalc];

    # The NVIDIA driver's hardware cursor plane glitches for a frame or two on
    # every cursor shape change. KWin runs as plasma-kwin_wayland.service, so
    # the variable has to reach the systemd user manager (environment.d), not
    # just login shells as home.sessionVariables would.
    systemd.user.sessionVariables.KWIN_FORCE_SW_CURSOR = "1";

    home.file.".local/share/user-places.xbel" = {
      force = true;
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE xbel>
        <xbel xmlns:bookmark="http://www.freedesktop.org/standards/desktop-bookmarks" xmlns:kdepriv="http://www.kde.org/kdepriv" xmlns:mime="http://www.freedesktop.org/standards/shared-mime-info">
         <info>
          <metadata owner="http://www.kde.org">
           <kde_places_version>4</kde_places_version>
           <GroupState-Places-IsHidden>false</GroupState-Places-IsHidden>
           <GroupState-Remote-IsHidden>false</GroupState-Remote-IsHidden>
           <GroupState-Devices-IsHidden>false</GroupState-Devices-IsHidden>
           <GroupState-RemovableDevices-IsHidden>false</GroupState-RemovableDevices-IsHidden>
           <GroupState-Tags-IsHidden>false</GroupState-Tags-IsHidden>
           <withRecentlyUsed>true</withRecentlyUsed>
           <GroupState-RecentlySaved-IsHidden>false</GroupState-RecentlySaved-IsHidden>
           <withBaloo>true</withBaloo>
           <GroupState-SearchFor-IsHidden>false</GroupState-SearchFor-IsHidden>
          </metadata>
         </info>
         <bookmark href="file://${config.home.homeDirectory}">
          <title>Home</title>
          <info>
           <metadata owner="http://freedesktop.org">
            <bookmark:icon name="user-home"/>
           </metadata>
           <metadata owner="http://www.kde.org">
            <ID>1776506197/0</ID>
            <isSystemItem>true</isSystemItem>
           </metadata>
          </info>
         </bookmark>
         <bookmark href="file://${config.home.homeDirectory}/Desktop">
          <title>Desktop</title>
          <info>
           <metadata owner="http://freedesktop.org">
            <bookmark:icon name="user-desktop"/>
           </metadata>
           <metadata owner="http://www.kde.org">
            <ID>1776506197/1</ID>
            <isSystemItem>true</isSystemItem>
           </metadata>
          </info>
         </bookmark>
         <bookmark href="file://${config.home.homeDirectory}/Documents">
          <title>Documents</title>
          <info>
           <metadata owner="http://freedesktop.org">
            <bookmark:icon name="folder-documents"/>
           </metadata>
           <metadata owner="http://www.kde.org">
            <ID>1776506197/2</ID>
            <isSystemItem>true</isSystemItem>
           </metadata>
          </info>
         </bookmark>
         <bookmark href="file://${config.home.homeDirectory}/Downloads">
          <title>Downloads</title>
          <info>
           <metadata owner="http://freedesktop.org">
            <bookmark:icon name="folder-downloads"/>
           </metadata>
           <metadata owner="http://www.kde.org">
            <ID>1776506197/3</ID>
            <isSystemItem>true</isSystemItem>
           </metadata>
          </info>
         </bookmark>
         <bookmark href="file://${config.home.homeDirectory}/Music">
          <title>Music</title>
          <info>
           <metadata owner="http://freedesktop.org">
            <bookmark:icon name="folder-music"/>
           </metadata>
           <metadata owner="http://www.kde.org">
            <ID>1776506197/6</ID>
            <isSystemItem>true</isSystemItem>
           </metadata>
          </info>
         </bookmark>
         <bookmark href="file://${config.home.homeDirectory}/Pictures">
          <title>Pictures</title>
          <info>
           <metadata owner="http://freedesktop.org">
            <bookmark:icon name="folder-pictures"/>
           </metadata>
           <metadata owner="http://www.kde.org">
            <ID>1776506197/7</ID>
            <isSystemItem>true</isSystemItem>
           </metadata>
          </info>
         </bookmark>
         <bookmark href="file://${config.home.homeDirectory}/Videos">
          <title>Videos</title>
          <info>
           <metadata owner="http://freedesktop.org">
            <bookmark:icon name="folder-videos"/>
           </metadata>
           <metadata owner="http://www.kde.org">
            <ID>1776506197/8</ID>
            <isSystemItem>true</isSystemItem>
           </metadata>
          </info>
         </bookmark>
         <bookmark href="remote:/">
          <title>Network</title>
          <info>
           <metadata owner="http://freedesktop.org">
            <bookmark:icon name="folder-network"/>
           </metadata>
           <metadata owner="http://www.kde.org">
            <ID>1776506197/4</ID>
            <isSystemItem>true</isSystemItem>
           </metadata>
          </info>
         </bookmark>
         <bookmark href="trash:/">
          <title>Trash</title>
          <info>
           <metadata owner="http://freedesktop.org">
            <bookmark:icon name="user-trash"/>
           </metadata>
           <metadata owner="http://www.kde.org">
            <ID>1776506197/5</ID>
            <isSystemItem>true</isSystemItem>
           </metadata>
          </info>
         </bookmark>
         <bookmark href="recentlyused:/files">
          <title>Recent Files</title>
          <info>
           <metadata owner="http://freedesktop.org">
            <bookmark:icon name="document-open-recent"/>
           </metadata>
           <metadata owner="http://www.kde.org">
            <ID>1776506197/9</ID>
            <isSystemItem>true</isSystemItem>
           </metadata>
          </info>
         </bookmark>
         <bookmark href="recentlyused:/locations">
          <title>Recent Locations</title>
          <info>
           <metadata owner="http://freedesktop.org">
            <bookmark:icon name="folder-open-recent"/>
           </metadata>
           <metadata owner="http://www.kde.org">
            <ID>1776506197/10</ID>
            <isSystemItem>true</isSystemItem>
           </metadata>
          </info>
         </bookmark>
         <bookmark href="file:///tmp">
          <title>Temp Dir</title>
          <info>
           <metadata owner="http://freedesktop.org">
            <bookmark:icon name="folder-temp"/>
           </metadata>
          </info>
         </bookmark>
        </xbel>
      '';
    };
  };
}
