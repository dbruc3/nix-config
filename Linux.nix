{ config, pkgs, lib, ... }:

{
  imports = [ ./common.nix ];

  home.username = "dan";
  home.homeDirectory = "/home/dan";
  home.stateVersion = "23.11";

  dconf.settings = {
    "org/gnome/desktop/background" = {
      show-desktop-icons = false;
    };
    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };
    "org/gnome/desktop/interface" = {
      clock-format = "24h";
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      show-battery-percentage = true;
    };
    "org/gnome/gnome-session" = {
      logout-prompt = false;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = false;
    };
    "org/gnome/terminal/legacy/keybindings" = {
      close-window = "<Super>q"; # TODO: handle all apps
    };
    "org/gnome/desktop/privacy" = {
      hide-identity = true;
      report-technical-problems = false;
      send-software-usage-stats = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      resize-with-right-button = true;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-timeout = 10800;
    };
    "org/gnome/shell/extensions/ding" = {
      show-home = false;
    };
  };

  home.activation = {
    postScripts = lib.hm.dag.entryAfter ["installPackages"] ''
      pushd ~ && rmdir Desktop Documents Downloads Music Pictures Public Templates Videos 2> /dev/null
      nix-index
      sudo dnf remove opensc -y # opensc interferes with yubikeys on fedora
    '';
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.protonvpn-gui # TODO: desktop entry
    pkgs.wl-clipboard # pass -c

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "Noto" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  programs.chromium = {
    enable = true;
  };

  programs.feh.enable = true;

  programs.gnome-terminal = {
    enable = true;
    showMenubar = false;
    profile.default = {
      default = true;
      visibleName = "defaultConfig";
      showScrollbar = false;
      font = "Monospace 11";
      colors = {
        palette = [
          "#1c2023"
          "#c7ae95"
          "#95c7ae"
          "#aec795"
          "#ae95c7"
          "#c795ae"
          "#95aec7"
          "#c7ccd1"
          "#747c84"
          "#c7ae95"
          "#95c7ae"
          "#aec795"
          "#ae95c7"
          "#c795ae"
          "#95aec7"
          "#f3f4f5"
        ];
        foregroundColor = "#ffffff";
        backgroundColor = "#1c1c1c";
      };
    };
  };
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
  xdg.systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];
}
