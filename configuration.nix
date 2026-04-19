# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;


  # This tells NixOS to use the latest kernel version available in your current channel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  # use grub bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;

  #plymouth splash screen
  boot.plymouth.enable = true;
  boot.plymouth.theme = "breeze";
  boot.kernelParams = [ "quiet" "splash" ];


  # Configure network connections interactively with nmcli or nmtui.
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles.profiles = {
    
    # 1. The Bridge Virtual Interface
    "bridge-br0" = {
      connection = {
        id = "bridge-br0";
        type = "bridge";
        interface-name = "br0";
      };
      bridge = {
        stp = "false"; 
      };
      ipv4 = {
        method = "manual";
        # Format: "IP/Prefix,Gateway"
        address1 = "192.168.1.100/24,192.168.1.1";
        # Format: "DNS1;DNS2;DNS3;" (Semicolons are required for lists)
        dns = "192.168.1.1;1.1.1.1;8.8.8.8;";
      };
    };

    # 2. The Physical Port (Slave)
    "bridge-slave-enp6s0" = {
      connection = {
        id = "bridge-slave-enp6s0";
        type = "ethernet";
        interface-name = "enp6s0";
        master = "br0";
        slave-type = "bridge";
      };
    };
  };

  # Disable global DHCP to let NetworkManager handle the bridge manually
  networking.useDHCP = false;
  networking.interfaces.enp6s0.useDHCP = false;
  networking.interfaces.br0.useDHCP = false;

  # Set your time zone.
  time.timeZone = "Asia/Hebron";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable wayland windowing system.
  services.xserver.enable = false;
  services.displayManager.ly = {
    enable = true;
    package = pkgs.ly;
    x11Support = true;
    settings = {
      bg = "0x021e1e2e";
      fg = "0x01d8dee9";
      border_fg = "0x0188c0e0";
      animation =  "none";#"colormix" "doom" "matrix" 
      clock = "%B, %A %d @ %H:%M:%S";
      hide_borders = false;
      hide_version_string = true;
    };
  };
  
  #console.colors = [
  #  "1e1e2e" "bf616a" "a3be8c" "ebcb8b"
  #  "81a1c1" "b48ead" "88c0d0" "d8dee9"
  #  "4c566a" "bf616a" "a3be8c" "ebcb8b"
  #  "81a1c1" "b48ead" "8fbcbb" "eceff4"
  #];
  console.colors = [
    "383c4a" "e14245" "5ca75b" "f6ab32"
    "4877b1" "a660c3" "5294e2" "d3dae3"
    "4b5164" "e16f7e" "add488" "fdc35f"
    "8ca9bf" "e2afec" "73c5e2" "fcfcfc"
  ];   
  programs.hyprland.enable = true;
  
  services.logind.settings.Login.HandlePowerKey = "hibernate";
  systemd.services.disable-wakeup = {
    description = "Disable USB wakeup devices";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      echo XHCI > /proc/acpi/wakeup
    '';
  };


  # Enable the Desktop Environment.
  #services.displayManager.gdm.enable = true;
  #services.desktopManager.gnome.enable = true;
  #services.desktopManager.plasma6.enable = true ;
  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.zsh.enable = true;
  programs.bash.enable = true;
  users.users.firas = {
    isNormalUser = true;
    shell = pkgs.zsh;  # 👈 change to your shell
    extraGroups = [ "wheel"  "networkmanager" "video" "input" "libvirtd"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
      discord
      vesktop
      zed-editor
      bun
      github-cli
      #wineWow64Packages.staging
      #winetricks
      #font-manager
    ];
    initialPassword = "123";
   };

  fileSystems."/home/firas/Data" = {
    device = "/dev/disk/by-label/Data";
    fsType = "ext4"; # or ntfs, vfat, etc.
    options = [ "nofail" ]; # "nofail" prevents boot hang if drive is missing
  };
  systemd.tmpfiles.rules = [
    "d /home/firas/Data 0755 firas users"
  ];   

  # Useful packages for Hyprland

  programs.steam.enable = true;
  programs.gamemode.enable = true;

  powerManagement.cpuFreqGovernor = "performance";
  #services.mpd.enable = true;

  environment.systemPackages = with pkgs; [ 
    stow
    arc-theme
    qogir-icon-theme
    cava
    pipes
    polychromatic 
    neovim 
    brave
    #firefox
    steam 
    mangohud
    protonup-qt
    gamemode
    goverlay 
    playerctl 
    git 
    hyprpaper 
    hyprlock 
    hypridle 
    hyprpolkitagent 
    waypaper 
    waybar 
    rofi
    nwg-look
    rofimoji 
    swaynotificationcenter 
    dex 
    atril
    eza
    jq
    fastfetch 
    zip 
    ffmpeg 
    libimobiledevice 
    ifuse 
    thunar 
    thunar-archive-plugin 
    xarchiver 
    kitty 
    geany 
    grim 
    slurp 
    imv 
    mpd 
    mpc 
    ncmpcpp 
    mpv 
    gparted 
    qdirstat 
    #virt-manager 
    #qemu 
    libsForQt5.qt5ct 
    kdePackages.qt6ct 
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    pastel 
    wl-clipboard 
    cliphist 
    blueman
    pavucontrol 
    networkmanagerapplet
    libnotify
    pulsemixer

    
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
    dejavu_fonts
    liberation_ttf
    noto-fonts
  ] ;
  
  # Set GTK theme via manual config files
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Arc-Dark
    gtk-icon-theme-name=Qogir
    gtk-application-prefer-dark-theme=1
  '';

  environment.etc."xdg/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Arc-Dark
    gtk-icon-theme-name=Qogir
    gtk-application-prefer-dark-theme=1
  '';

  # Apply cursor hyprland)
  # Set environment variables for cursor
  environment.sessionVariables = {
    XCURSOR_THEME = "Qogir Cursors";
    XCURSOR_SIZE = "24";
  };

  # Run hyprctl setcursor on session start
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.hyprland}/bin/hyprctl setcursor "breeze_cursors" 24
  '';

  

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  
  hardware.openrazer = {
    enable = true;
    users = [ "firas" ]; # 👈 replace with your username
  };

  #libvirt
  #virtualisation.libvirtd.enable = true;

  # programs.firefox.enable = true;


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
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;  # or false if you use SSH keys
      PermitRootLogin = "no";
    };
  };
  services.dbus.enable = true;

  hardware.bluetooth.enable= true;
  services.blueman.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };

 
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

