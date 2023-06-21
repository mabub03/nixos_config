# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  boot.kernel.sysctl = { "vm.max_map_count" = 2147483642; };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Make sure opengl is enabled
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # NVIDIA drivers are unfree.
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
    ];

  # Tell Xorg to use the nvidia driver
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is needed for most wayland compositors
    modesetting.enable = true;

    # Use the open source version of the kernel module
    # Only available on driver 515.43.04+
    open = false;

    # Enable the nvidia settings menu
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  security.polkit.enable = true;
  security.pam.services.kwallet.enableKwallet = true;
  programs.dconf.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.settings = {
    Theme = {
      CursorTheme = "breeze_cursors";
    };
  };
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";

  # qt theming set to kde and breeze cause for some reason it isn't by default
  # qt.platformTheme= "kde";
  # qt.style = "breeze";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable fstrim and set intervale to weekly
  services.fstrim.enable = true;
  services.fstrim.interval = "weekly";

  services.power-profiles-daemon.enable = true;
  services.packagekit.enable = true;

  # enable flatpak support
  services.flatpak.enable = true;
  services.dbus.enable = true;

  services.hardware.bolt.enable = false;

  services.openssh = {
    enable = true;
    # Forbid root login through SSH.
    settings = {
      PermitRootLogin = "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      PasswordAuthentication = false;
    };
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
        xdg-desktop-portal-kde
      ];
    };
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  programs.zsh.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.toasty = {
    isNormalUser = true;
     # TODO: You can set an initial password for your user.
     # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
     # Be sure to change it (using passwd) after rebooting!
    #initialPassword = "password";
    description = "toasty";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "gamemode"];
    openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    ];
    packages = with pkgs; [
      firefox
    #  thunderbird
    ];
  };

  #users.mutableUsers = false;

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
  with libsForQt5; [
  # install kde apps (maybe move some to user specific packages if can)
    kdeconnect-kde
    discover
    kaccounts-providers
    kaccounts-integration
    kio-gdrive
    colord-kde
    polkit-kde-agent
    partition-manager
    plasma-thunderbolt
    kirigami-addons
    kate
    qttools
  # install everything else
    #starship
    #gamemode
    #exa
    flatpak
    git
    qemu
    virt-manager
    vulkan-tools
    wayland-utils
    wl-clipboard
    unzip
    zip
    wget
    curl
    xdg-utils
    btop
    bolt # manages thunderbolt
  ];

  # needed in here for root level completion options with zsh
  environment.pathsToLink = [ "/share/zsh" ];

  environment.plasma5.excludePackages = with pkgs;
  with libsForQt5; [
    elisa
    gwenview
    xterm
  ];

  # add flathub
  #flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  virtualisation.libvirtd.enable = true;
  #programs.kdeconnect.enable = true;
  programs.gamemode.enable = true;
  programs.partition-manager.enable = true;

  hardware.bluetooth.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  powerManagement = {
    enable = true;
    powertop = {
      enable = false;
    };
  };

  # nix config TODO: search up what all this means before adding
#   nix = {
#     gc = {
#       automatic = true;
#       dates = "weekly";
#       options = "--max-freed 1G --delete-older-than 7d";
#     };
#     optimise = {
#       automatic = true;
#     };
#     settings = {
#       allowed-users = ["@wheel"];
#       auto-optimise-store = true;
#       sandbox = true;
#       trusted-users = ["root" "${name}"];
#     };
#   };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
