{config, ...}: {
  services.openvpn.servers.tryhackme = {
    autoStart = false;
    updateResolvConf = true;
    config = ''
      config ${config.sops.secrets.tryhackme-openvpn.path}
      auth-nocache
    '';
  };
}
