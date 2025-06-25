{ config, pkgs, lib, ... }:

{
  home.stateVersion = "23.11"; # You should not change this value
  home.enableNixpkgsReleaseCheck = false;

  #nix = {
  #  package = pkgs.nix;
  #  settings.experimental-features = [ "nix-command" "flakes" ];
  #};

  home.packages = [
    pkgs.curl
    pkgs.devenv
    pkgs.epr # epub reader
    pkgs.gcalcli
    pkgs.gitmux
    pkgs.mods # chatGPT
    pkgs.mosh
    pkgs.ncdu
    pkgs.sc-im
    pkgs.signal-desktop
    pkgs.silver-searcher # fzf
    pkgs.tree
    pkgs.yt-dlp-light # youtubeDL
    pkgs.yubikey-manager
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

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dan/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    BROWSER = "firefox";
    EDITOR = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    initExtra = ''
      if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      # gg() { dir=`pwd | cut -d'/' -f4` ; cd ~/$dir }
      [ ! -f /tmp/openai ] && pass keys/openai > /tmp/openai
      [ -z "$LOC" ] && export LOC=`pass irl/location`
      rm -f ~/.gnupg/public-keys.d/pubring.db.lock
      export OPENAI_API_KEY="`cat /tmp/openai`"
      export PATH=$PATH:~/.npm-packages/bin
      #export XDG_DATA_DIRS=$HOME/.nix-profile/share:$HOME/.share:"`XDG_DATA_DIRS:-/usr/local/share/:/usr/share/`"
      [ -z "$TMUX"  ] && { tmux attach || exec tmux new-session && exit; }
      #clear
    '';
    sessionVariables = {
      SSH_AUTH_SOCK = "`gpgconf --list-dirs agent-ssh-socket`";
    };
    shellAliases = {
      hm = "vim ~/nix-config/$(uname).nix";
      hmc = "vim ~/nix-config/common.nix";
      hms = "nix-shell -p home-manager --run 'home-manager -f ~/nix-config/$(uname).nix switch'";
      g = "mods -m gpt-4o -a openai";
      ls = "ls --color=auto";
      sc = "sc-im";
      la = "ls -a";
      mv = "mv -i";
      cp = "cp -i";
      hig = "pass edit files/hig";
      todo = "vim ~/notes/todo.md";
      loc = "pass edit irl/location";
      yt-audio = "yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 -o";
      todos = "grepr TODO";
      ge = "FZF_DEFAULT_COMMAND='git status -s | rev | cut -d\" \" -f1 | rev' fzf --bind 'enter:become(vim {})'";
      gs = "git status";
      gd = "git diff";
      gr = "git restore";
      grepr = "grep -rnwI --exclude-dir .expo --exclude-dir node_modules --exclude-dir .git --exclude package-lock.json";
      ts = "tree -a -I .git -I node_modules";
      vz = "fzf --bind 'enter:become(vim {})'";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      weather = "curl wttr.in/$LOC?qF";
    };
  };
  programs.vim = {
    enable = true;
    settings = {
      number = true;
      shiftwidth = 2;
      tabstop = 2;
    };
    extraConfig = ''
      set softtabstop=2
      set backspace=2
      set showcmd
      set wildmenu
      set showmatch
      set incsearch
      set hlsearch
      set noshowmode
      set laststatus=2
      let netrw_browserx_viewer="$BROWSER"
      syntax on
      abbr hte the
      set foldmethod=indent
      set foldlevel=99
    '';
  };
  programs.tmux = {
    enable = true;
    clock24 = true;
    disableConfirmationPrompt = true;
    escapeTime = 0;
    keyMode = "vi";
    mouse = true;
    terminal = "xterm-256color";
    extraConfig = ''
      bind r source-file $HOME/.tmux.conf
      set -g status-position top
      set -g status-interval 30
      set -g status-left "" # 10 chars max
      set -g status-left-style "fg=white,bg=colour234"
      set -g status-right-length 200
      set -g status-right-style "fg=white,bg=colour234"

      set-window-option -g window-status-format "  #I: #{b:pane_current_path}  "
      set-window-option -g window-status-style "fg=white,bg=colour234"
      set-window-option -g window-status-current-format "  #I: #{b:pane_current_path}  "
      set-window-option -g window-status-current-style "fg=colour234,bg=white"
      set-option -g status-bg "colour234"

      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
    '';
  };
  programs.password-store.enable = true;

  programs.mpv.enable = true;
  programs.fzf = {
    enable = true;
    defaultCommand = "ag --hidden --ignore .git --ignore node_modules -g ''";
    tmux.enableShellIntegration = true;
  };
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
  programs.git = {
    enable = true;
    userName = "dbruc3";
    userEmail = "dbruce14@gmail.com";
    aliases = {
      co = "checkout";
    };
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
  programs.hstr.enable = true;
  programs.ledger = {
    enable = true;
  };
  programs.noti = {
    enable = true;
  };

  programs.topgrade.enable = true; # TODO: service

  programs.direnv = {
    enable = true;
  };
  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  programs.gpg = {
    enable = true;
  };

  services.home-manager.autoUpgrade = {
    enable = true;
    frequency = "weekly";
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-curses;
    enableScDaemon = true;
  };
}
