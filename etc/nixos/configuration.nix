# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Bluetooth
hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
  settings.General.Experimental = true;  # enables newer Bluetooth features
};

services.blueman.enable = true;  # optional GUI applet

  # Enable swap file
swapDevices = [ {
  device = "/swapfile";
  size = 32 * 1024; # 32768 MB (32 GB)
} ];
programs.wireshark.enable = true;  # Sets up the group + capabilities properly

# Hibernation boot settings
boot.resumeDevice = "/dev/disk/by-uuid/36d8ba78-c1a3-4ebd-86f9-41beda6cb56c";
boot.kernelParams = [ "resume_offset=86112256" ];

# Allow Noctalia / Niri power menu to hibernate without password prompts
security.polkit.extraConfig = ''
  polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.login1.hibernate" ||
         action.id == "org.freedesktop.login1.hibernate-multiple-sessions" ||
         action.id == "org.freedesktop.login1.power-off" ||
         action.id == "org.freedesktop.login1.reboot") &&
        subject.isInGroup("wheel")) {
      return polkit.Result.YES;
    }
  });
'';

  # Set your time zone.
  time.timeZone = "Africa/Lagos";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_NG";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_NG";
    LC_IDENTIFICATION = "en_NG";
    LC_MEASUREMENT = "en_NG";
    LC_MONETARY = "en_NG";
    LC_NAME = "en_NG";
    LC_NUMERIC = "en_NG";
    LC_PAPER = "en_NG";
    LC_TELEPHONE = "en_NG";
    LC_TIME = "en_NG";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # SDDM only (removed GDM)
  services.displayManager.sddm = {
  enable = true;
  wayland.enable = false;
  settings = {
    Theme = {
      Background = "/home/orion/Pictures/wallpapers/katana_bg.png";
    };
  };
};

  # Enable virtual filesystem service for trash, network, and USB mounting
  services.gvfs.enable = true;

  systemd.user.services.noctalia = {
   description = "Noctalia Shell";
   wantedBy = [ "graphical-session.target" ];
   partOf = [ "graphical-session.target" ];
   serviceConfig = {
    ExecStart = "${pkgs.bash}/bin/bash -c 'noctalia'";
    Restart = "on-failure";
  };
 };

  # GNOME Desktop Environment
  #services.desktopManager.gnome.enable = true;


  # Configure keymap in X11 — KEEP THIS
  services.xserver.xkb = {
    layout = "ng";
    variant = "";
  };
  # Enable the X11 windowing system.
  #services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  #services.xserver.xkb = {
   # layout = "ng";
   # variant = "";
  #};

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."orion" = {
    isNormalUser = true;
    description = "orion";
    extraGroups = [ "networkmanager" "wheel" "video" "wireshark" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts = {
  fontconfig.enable = true;
  packages = with pkgs; [
    corefonts
    vista-fonts
  ];
};

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
	
  services.displayManager.defaultSession = "niri";
  services.displayManager.autoLogin = {
  	enable = true;
  	user = "orion";
  };
  
  #programs.hyprland = {
   #enable = true;
    #xwayland.enable = true;
  #};

# Enable PostgreSQL
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            md5
      host    all             all             ::1/128                 md5
    '';
  };

  # Enable Redis
  services.redis.servers."redis" = {
    enable = true;
    port = 6379;
  };
  
  programs.xwayland.enable = true;

  hardware.brillo.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
	kitty
	ghostty
	amberol
	corefonts
	vista-fonts
	python3
	bun
	noctalia
	xwayland
  	xwayland-satellite
	nautilus
	tumbler
	hyprlock
	ffmpeg
	vlc
	wl-clipboard
	cliphist
	wofi
	git
	dunst
	brightnessctl
    	pavucontrol
    	playerctl
	inotify-tools
	nwg-look
	spotify
	vscode
	obsidian
	nodejs
	pkgs.nerd-fonts.jetbrains-mono
	oh-my-posh
	jdk
	wpsoffice
	discord
	telegram-desktop
	google-chrome
	onlyoffice-desktopeditors
	unzip
	localsend
	kdePackages.okular
	vim
	fuzzel
	mako
	wireshark
	gthumb
	opencode	
	# Required for Quickshell / QtMultimedia video playback
	qt6.qtmultimedia
    	ffmpeg
    	gst_all_1.gstreamer
    	gst_all_1.gst-plugins-base
    	gst_all_1.gst-plugins-good
    	gst_all_1.gst-plugins-bad
    	gst_all_1.gst-plugins-ugly
    	gst_all_1.gst-libav
	networkmanagerapplet
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  environment.sessionVariables = { 
    PATH = "/run/wrappers/bin:/run/current-system/sw/bin";
    DISPLAY = ":0";
    # Directs Qt 6 applications to system multimedia backend plugins
    QT_PLUGIN_PATH = [
      "/run/current-system/sw/lib/qt-6/plugins"
    ];
  };

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
  services.flatpak.enable = true;
  #programs.waybar.enable = true;

  programs.niri.enable = true;  

  # Enable nix-ld to run unpatched dynamic binaries (like node_modules executables)
  programs.nix-ld = {
  enable = true;
  libraries = with pkgs; [
    glib
    zlib
    stdenv.cc.cc.lib
  ];
};

# Enable Hyprlock PAM service with GNOME Keyring automatic unlock
security.pam.services.hyprlock = {
  enableGnomeKeyring = true;
};

systemd.user.services.hyprlock-before-sleep = {
  description = "Lock screen before sleep and hibernate";
  wantedBy = [ "sleep.target" "hibernate.target" ];
  before = [ "sleep.target" "hibernate.target" ];
  serviceConfig = {
    Type = "simple";
    ExecStart = "${pkgs.hyprlock}/bin/hyprlock";
  };
};
 
  # Qylock SDDM theme configuration
 # programs.qylock = {
  #  enable = true;
 #   theme = "sword";
  #  sddm.enable = true;       # Installs theme and sets it as active for SDDM
   # quickshell.enable = true; # Adds qylock-lock utility to PATH
 # };

  # Open LocalSend ports for local network discovery and file transfer
networking.firewall = {
  allowedTCPPorts = [ 8081 53317 ];
  allowedUDPPorts = [ 53317 ];
};
  	
  #services.greetd = {
   #enable = true;
   #settings = {
    # default_session = {
     #  command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd \"${config.programs.niri.package}/bin/niri-session\"";
      # user = "orion";
    # };
   #}; 
 # };	
# NixOS otherwise injects a stripped PATH via Environment= on the niri.service
# unit which shadows the imported user-manager PATH. Disabling the default
# lets niri inherit the full PATH set up by niri-session.
systemd.user.services.niri.enableDefaultPath = false;

security.polkit.enable = true; # polkit
services.gnome.gnome-keyring.enable = true; # secret service

}
