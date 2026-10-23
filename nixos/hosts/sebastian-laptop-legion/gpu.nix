{
  config,
  lib,
  pkgs,
  ...
}: let
  nvidiaUpstream = config.boot.kernelPackages.nvidiaPackages.latest;

  # patchelf 0.19.2 breaks non-PIE binaries when --interpreter and --set-rpath run in one
  # invocation: .dynamic lands in a read-only LOAD segment and ld.so segfaults in dl_main
  # (nvidia-smi, nvidia-powerd). Split the call as upstream does in nixpkgs#576397.
  # Self-expiring: once the pinned builder no longer contains the combined call, the override
  # is a no-op and evaluation warns to delete it.
  # https://github.com/NixOS/nixpkgs/issues/576412
  brokenPatchelfCall = ''
    patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                        --set-rpath $out/lib:$libPath $bin/bin/$i'';
  splitPatchelfCall = ''
    patchelf --set-rpath "$out/lib:$libPath" "$bin/bin/$i"
                    patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$bin/bin/$i"'';

  nvidiaPackage = nvidiaUpstream.overrideAttrs (old: let
    # `old.builder` is the pre-mkDerivation ./builder.sh path; the final drv's `builder` is bash.
    upstreamBuilder = builtins.readFile old.builder;
  in
    if lib.hasInfix brokenPatchelfCall upstreamBuilder
    then {
      builder = pkgs.writeText "nvidia-x11-builder.sh" (
        builtins.replaceStrings [brokenPatchelfCall] [splitPatchelfCall] upstreamBuilder
      );
    }
    else
      lib.warn
      "gpu.nix: nixpkgs now splits the nvidia-x11 patchelf call (nixpkgs#576412); remove the nvidiaPackage override"
      {});
in {
  # RTX 5050 Mobile (Blackwell) + AMD Ryzen 7 hybrid graphics

  services.xserver.videoDrivers = ["nvidia"];

  hardware.graphics.enable = true;

  boot.kernelParams = [
    # GPIO 4 on AMDI0030:00 is an ACPI event for the dGPU (`_EVT` case 4:
    # Notify \_SB.PCI0.GPP0.PEGP 0x81). With HDMI driven by the dGPU it fires
    # right after entering s2idle and wakes the system immediately. Keep the
    # runtime interrupt, drop only its wake capability.
    "gpiolib_acpi.ignore_wake=AMDI0030:00@4"
  ];

  hardware.nvidia = {
    # Required for Blackwell (GB***) and newer architectures
    open = true;

    package = nvidiaPackage;
    modesetting.enable = true;

    nvidiaSettings = false;

    # Save and restore VRAM across suspend/resume to prevent Xid 13
    # (shader corruption / missing textures after wake).
    powerManagement.enable = true;
    # RTD3: power the dGPU off (D3cold) while idle.
    powerManagement.finegrained = true;

    # Enable NVIDIA Dynamic Boost through nvidia-powerd.
    dynamicBoost.enable = true;

    nvidiaPersistenced = false;

    # PRIME offload: AMD iGPU composites, dGPU renders on demand
    # (`nvidia-offload <cmd>`). HDMI on the dGPU works via display offload.
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;

      # AMD iGPU: 65:00.0 (0x65 = 101 decimal)
      amdgpuBusId = "PCI:101:0:0";
      # NVIDIA: 01:00.0
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
