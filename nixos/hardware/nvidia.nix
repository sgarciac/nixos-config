# NVIDIA GPU. Imported by aorus only — do not add this to the thinkpad.
{ ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement.enable = true;
    powerManagement.finegrained = false;

    open = true; # Recommended for newer RTX GPUs
    nvidiaSettings = true;
  };
}
