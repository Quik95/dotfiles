{pkgs, config, ...}: {
  systemd.user.tmpfiles.rules = [
    "f ${config.home.homeDirectory}/.config/monitors.xml 0644 - - - ${pkgs.writeText "monitors.xml" ''
      <monitors version="2">
        <configuration>
          <layoutmode>physical</layoutmode>
          <logicalmonitor>
            <x>1920</x>
            <y>0</y>
            <scale>1</scale>
            <primary>yes</primary>
            <monitor>
              <monitorspec>
                <connector>HDMI-1</connector>
                <vendor>HPN</vendor>
                <product>HP E243i</product>
                <serial>6CM9240TQ1</serial>
              </monitorspec>
              <mode>
                <width>1920</width>
                <height>1200</height>
                <rate>59.950</rate>
              </mode>
            </monitor>
          </logicalmonitor>
          <logicalmonitor>
            <x>0</x>
            <y>120</y>
            <scale>1</scale>
            <monitor>
              <monitorspec>
                <connector>eDP-1</connector>
                <vendor>LGD</vendor>
                <product>0x06e8</product>
                <serial>0x00000000</serial>
              </monitorspec>
              <mode>
                <width>1920</width>
                <height>1080</height>
                <rate>60.020</rate>
              </mode>
            </monitor>
          </logicalmonitor>
        </configuration>
      </monitors>
    ''}"
  ];
}
