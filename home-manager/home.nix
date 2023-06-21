# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "toasty";
    homeDirectory = "/home/toasty";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "mabub03";
    userEmail = "mabub03@gmail.com";
  };

  #virtualisation.libvirtd.enable = true;
  services.kdeconnect.enable = true;
  # these program lines don't exist in home-manager
  #programs.kdeconnect.enable = true;
  #programs.gamemode.enable = true;

  #services.packagekit.enable = true;
  # gtk settings and gtk config files settings
  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.libsForQt5.breeze-icons;
      name = "breeze_cursors";
      size = 24;
    };
    iconTheme = {
      package = pkgs.libsForQt5.breeze-icons;
      name = "breeze";
    };
    theme = {
      package = pkgs.libsForQt5.breeze-gtk;
      name = "Breeze";
    };
    #TODO: make sure font changes when changing font in font config or kde settings first
    #font = {
    #  name = "SF Pro";
    #  size = 10;
    #};
    gtk4.extraConfig = {
      gtk-hint-font-metrics = 1;
    };
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    autocd = true;
    shellAliases = {
      ls = "exa --icons";
      tetris = "tetriscurses";
    };
    history = {
      size = 10000;
      save = 10000;
      path = "$HOME/.zsh_history";
    };
    #histSize = 1000;
    #histFile = "$HOME/.zsh_history";
    enableCompletion = true;
    enableAutosuggestions = true;
    sessionVariables = {
      VOLTA_HOME = "$HOME/.volta";
      PF_INFO="ascii title os host kernel de shell uptime pkgs memory";
      SAL_USE_VCLPLUGIN = "kf5";
      NIX_CONFIG = "experimental-features = nix-command flakes";
    };
    initExtra = ''
      setopt extendglob nomatch notify
      unsetopt beep

      export PATH="$VOLTA_HOME/bin:$PATH"
      export PATH="$HOME/.cargo/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
    '';
    initExtraFirst = ''
      zmodload zsh/zprof
      TIMEFMT=$'real\t\%E\nuser\t%U\nsys\t%S'
      autoload -Uz tetriscurses
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$username$hostname$directory$line_break$character";
      right_format = "$git_branch$git_state$git_status$nix_shell$nodejs$package$php$python$rust$shlvl";
      character = {
        success_symbol = "[󰘧](green bold)";
        error_symbol = "[󰘧](red)";
        vicmd_symbol = "[󰘧](purple)";
      };
      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };
      directory = {
        read_only = " ";
        style = "green bold";
      };
      git_branch = {
        format = "[$symbol$branch]($style)";
        style = "bright-black";
        symbol = " ";
      };
      git_state = {
        format = "'\([$state( $progress_current/$progress_total)]($style)\) '";
        style = "bright-black";
      };
      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "";
        untracked = "";
        modified = "";
        staged = "";
        renamed = "";
        deleted = "";
        stashed = "≡";
      };
      memory_usage = { symbol = "󰍛"; };
      nix_shell = {
        format = "[$symbol$state( \($name\))]($style)";
        symbol = " ";
        style = "blue bold";
      };
      nodejs = {
        format = "[$symbol($version )]($style)";
        symbol = " ";
        style = "green bold";
      };
      package = { symbol = "󰏗 "; };
      php = {
        format = "[$symbol$version]($style)";
        symbol = " ";
        style = "147 bold";
      };
      python = {
        format = "[$symbol$version]($style)";
        symbol = " ";
        style = "yellow bold";
      };
      rust = {
        format = "[$symbol$version]($style)";
        symbol = " ";
        style = "red bold";
      };
      shell = {
        fish_indicator = "";
        powershell_indicator = "_";
        bash_indicator = "";
        zsh_indicator = "";
        unknown_indicator = "mystery shell";
        style = "cyan bold";
        disabled = false;
      };
      shlvl = { symbol = " "; };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
