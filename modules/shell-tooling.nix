{ dotfiles, config, lib, pkgs, isLinux ? false, ... }:

let cfg = config.programs.t-shell-tooling;

in {

  options.programs.t-shell-tooling.enable =
    lib.mkEnableOption "Enable useful shell tooling";

  config = lib.mkIf cfg.enable {

    programs.jq = { enable = true; };

    programs.fzf = { enable = true; };
    home.file.".fzfrc".source = dotfiles + "/fzfrc";

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fonts.fontconfig.enable = true;
    home.packages = with pkgs;
      [

        # TODO bring back these when they are renamed nerd-fonts also in nix stable
        # nerd-fonts.iosevka
        # nerd-fonts.iosevka-term

        (ripgrep.override { withPCRE2 = true; })
        eza
        fd
        bat
        yazi
        gawk
        htop
        btop
        watch
      ] ++ lib.optionals (isLinux) [ ncdu ];
    home.file.".config/btop".source = dotfiles + "/config/btop";
    home.file.".config/bat".source = dotfiles + "/config/bat";

    home.file.".config/yazi".source = dotfiles + "/config/yazi";

    # zsh
    home.file.".zsh".source = dotfiles + "/zsh/";
    home.file.".zshrc".source = dotfiles + "/zshrc";
    home.file.".inputrc".source = dotfiles + "/inputrc";
    home.file.".zprofile".source = dotfiles + "/profile";
    home.file.".p10k.zsh".source = dotfiles + "/p10k.zsh";

    programs.oh-my-posh = {
      package = pkgs.oh-my-posh;
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    xdg.configFile."oh-my-posh/config.toml".text = ''
      #:schema https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json
      version = 2
      final_space = true
      console_title_template = '{{ .Shell }} in {{ .Folder }}'
      tooltips_action = "extend" # replace
      notice = false
      auto = false

      [[blocks]]
        type = 'prompt'
        alignment = 'left'
        newline = true

        [[blocks.segments]]
          type = 'path'
          style = 'plain'
          background = 'transparent'
          foreground = 'blue'
          template = '{{ .Path }}'

          [blocks.segments.properties]
            style = 'full'

        [[blocks.segments]]
          type = 'git'
          style = 'plain'
          #background_templates = [
          #  '{{ if or (.Working.Changed) (.Staging.Changed) }}#FF9248{{ end }}',
          #  '{{ if and (gt .Ahead 0) (gt .Behind 0) }}#ff4500{{ end }}',
          #  '{{ if gt .Ahead 0 }}#B388FF{{ end }}',
          #  '{{ if gt .Behind 0 }}#B388FF{{ end }}']
          template = ' {{ .UpstreamIcon }}{{ .HEAD }}<p:grey>{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }}  {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }}  {{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }}  {{ .StashCount }}{{ end }} '
          background = 'transparent'
          foreground = 'green'

          [blocks.segments.properties]
            branch_template = '{{ trunc 25 .Branch }}'
            fetch_status = false
            fetch_upstream_icon = false

      [[blocks]]
        type = 'rprompt'
        overflow = 'hidden'

        [[blocks.segments]]
          type = 'executiontime'
          style = 'plain'
          foreground = 'yellow'
          background = 'transparent'
          template = '{{ .FormattedMs }}'

          [blocks.segments.properties]
            threshold = 1000

      [[blocks]]
        type = 'prompt'
        alignment = 'left'
        newline = true

        [[blocks.segments]]
          type = "session"
          style = "diamond"
          foreground = 'yellow'
          background = 'transparent'
          template = '{{ if .SSHSession }} {{ .UserName }}<p:red>@</>{{ .HostName }}{{ end }} '

        [[blocks.segments]]
          type = 'text'
          style = 'plain'
          foreground = 'red'
          background = 'transparent'
          template = '{{ if ne .Env.OMP_JOB_COUNT "0" }}{{ .Env.OMP_JOB_COUNT }} {{ end }}'

        [[blocks.segments]]
          type = 'text'
          style = 'plain'
          foreground_templates = [
            "{{if gt .Code 0}}red{{end}}",
            "{{if eq .Code 0}}green{{end}}",
          ]
          background = 'transparent'
          template = '❯'

      [transient_prompt]
        foreground_templates = [
          "{{if gt .Code 0}}red{{end}}",
          "{{if eq .Code 0}}green{{end}}",
        ]
        background = 'transparent'
        template = '❯ '

      [secondary_prompt]
        foreground = 'green'
        background = 'transparent'
        template = '❯❯ '

      [palette]
      tooltip-version = "#193549"
      grey = '#333333'
      red = '#ff5555'

      [[tooltips]]
      type = "java"
      tips = [ "java", "javac", "javap", "gradle", "gw", "mvn", "kotlin"]
      foreground = "p:tooltip-version"
      template = " {{ .Env.OMP_JAVA_VERSION }}"

      [[tooltips]]
      type = "npm"
      tips = [ "npm" ]
      foreground = "p:tooltip-version"
      template = " {{ .Env.OMP_NPM_SCRIPTS }}"

      [[tooltips]]
      type = "node"
      tips = [ "node" ]
      foreground = "p:tooltip-version"
      template = " {{ .Env.OMP_NODE_VERSION }} {{ .Env.OMP_NPM_VERSION }}"

      [[tooltips]]
      type = "git"
      tips = [ "git" ]
      foreground = "p:tooltip-version"
      template = "{{ .Env.OMP_GIT_VERSION }}"

      [tooltips.properties]
      fetch_status = true
      fetch_upstream_icon = true
    '';

  };
}
