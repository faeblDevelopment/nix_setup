# PARTITIONING
# parted /dev/sda -- mklabel gpt
# parted /dev/sda -- mkpart primary 512MiB 46GiB
# parted /dev/sda -- mkpart primary linux-swap 46GiB 100%
# parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
# parted /dev/sda -- set 3 boot on

# mkfs.ext4 -L crypted /dev/sda1
# mkswap -L swap /dev/sda2
# swapon /dev/sda2
# mkfs.fat -F 32 -n boot /dev/sda3        # (for UEFI systems only)

# # CREATION OF ENCRYPTED HOME
# cryptsetup luksFormat /dev/sda1
# cryptsetup luksOpen /dev/sda1 crypted
# mkfs.ext4 /dev/mapper/crypted
# mkdir -p /mnt/boot                      # (for UEFI systems only)
# mount /dev/disk/by-label/boot /mnt/boot # (for UEFI systems only)

# nixos-generate-config --root /mnt
# nano /mnt/etc/nixos/configuration.nix
# nixos-install
# reboot


{ config, pkgs, ... }: 

{

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  
  boot.loader.systemd-boot.enable = true; 
  boot.initrd.luks.devices.crypted.device = "/dev/sda1";

  fileSystems = [
    { mountPoint = "/";
      device = "/dev/mapper/crypted";
    }
  ];


  networking.hostName = "nixos_test1";
  networking.wireless.enable = true;
  networking.useDHCP = false;
  networking.interfaces.ens33.useDHCP = true;

  time.timeZone = "Euorpe/Vienna";

  # nix search ...
  environment.systemPackages = [
    wget
    vim
    git
    stack
    firefox
  ];

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.faebl = {
    isNormalUser = true;
    home = "/home/faebl";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  system.stateVersion = "19.09";

  # UI
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw 
  services.xserver = {
    enable = true;
    layout = "de";

    desktopManager = {
      default = "none";
      xterm.enable = false;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu i3status i3lock
     ];
     package = pkgs.i3-gaps;
    };
  };

}