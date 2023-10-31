{ config, pkgs, lib, ... }:

{
  # Imports
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader Configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Blacklist the "nouveau" kernel module to avoid conflicts with NVIDIA.
  boot.blacklistedKernelModules = [ "nouveau" ];
  # Set kernel parameters for NVIDIA graphics.
  # boot.kernelParams = [ "nvidia-drm.modeset=1" "initcall_blacklist=simpledrm_platform_driver_init" ];

  # Kernel Configuration
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtl88xxau-aircrack ];

  # Networking Configuration
  networking.hostName = "Berry";
  networking.networkmanager.enable = true;
  # Configure network proxy if necessary.
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Time Zone and Internationalization Settings
  time.timeZone = "Africa/Kampala";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "lg_UG.UTF-8";
    LC_IDENTIFICATION = "lg_UG.UTF-8";
    LC_MEASUREMENT = "lg_UG.UTF-8";
    LC_MONETARY = "lg_UG.UTF-8";
    LC_NAME = "lg_UG.UTF-8";
    LC_NUMERIC = "lg_UG.UTF-8";
    LC_PAPER = "lg_UG.UTF-8";
    LC_TELEPHONE = "lg_UG.UTF-8";
    LC_TIME = "lg_UG.UTF-8";
  };

  # Drives Configuration
  fileSystems."/home/moon/1TB" = {
    device = "/dev/disk/by-uuid/7dc58477-2386-4853-8588-fdc1cfde9f24";
    fsType = "ext4";
  };

  # Environment Configuration
  environment.variables.DIRENV_LOG_FORMAT = "";

  # Nix Settings
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Hardware Configuration
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ nvidia-vaapi-driver ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ nvidia-vaapi-driver ];
    };
    nvidia = {
      forceFullCompositionPipeline = true;
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  # Power Management Configuration
  powerManagement.enable = true;
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };

  # Xorg and Display Settings
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.windowManager.bspwm.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "";

  # Extra Services
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  # Programs
  programs.adb.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    # "steam"
    # "steam-original"
    # "steam-run"
  ];

  # Services Configuration
  services.flatpak.enable = true;
  services.printing.enable = true;
  hardware.pulseaudio.enable = false;
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
    # use the example session manager (no others are packaged yet, so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  # Touchpad Support
  services.xserver.libinput.enable = true;

  # User Account
  users.users.moon = {
    isNormalUser = true;
    description = "moon";
    extraGroups = [ "networkmanager" "wheel" "wireshark" "adbusers" ];
    packages = with pkgs; [
      # Uncomment packages you want to install for the user.
      # firefox
    ];
  };

  # Allow Unfree Packages
  nixpkgs.config.allowUnfree = true;

  # System Packages
  environment.systemPackages = with pkgs; [
    (picom.overrideAttrs (o: {
      src = pkgs.fetchFromGitHub {
        repo = "picom";
        owner = "pijulius";
        rev = "982bb43e5d4116f1a37a0bde01c9bda0b88705b9";
        sha256 = "YiuLScDV9UfgI1MiYRtjgRkJ0VuA1TExATA2nJSJMhM=";
      };
    }))
    direnv
    nitrogen
    picom
    i3lock-fancy
    git
    bspwm
    polybar
    sxhkd
    brightnessctl
    flameshot
    dunst
    neovim
    obs-studio
    openh264
    librewolf
    pavucontrol
    xfce.thunar
    redshift
    discord
    spotify
    zathura
    ranger
    cmus
    vscode
    ueberzug
    alacritty
    brave
    mpv
  ];
  # Firewall Configuration
  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # State Version
  system.stateVersion = "23.05";
}
