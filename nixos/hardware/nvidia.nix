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

  # Environment variables for NVIDIA Wayland support (from CachyOS config)
  # These enable GBM backend, hardware acceleration, and VRR
  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    __GL_GSYNC_ALLOWED = "1";
  };
}
