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
        gawk
        htop
        btop
        watch
      ] ++ lib.optionals (isLinux) [ ncdu ];
    home.file.".config/btop".source = dotfiles + "/config/btop";
    home.file.".config/bat".source = dotfiles + "/config/bat";

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
          fetch_status = true
          fetch_upstream_icon = true
    
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

  home.file.".zshrc-extra".text = ''
    function prompt_t_node () {
      # fall back to $NODE_VERSION from ~/.config/dotfiles/source/exports
      if [[ -d $HOME/.nvm ]] &> /dev/null
      then
        NVM_NODE_VERSION=$(echo $NVM_BIN | sed -e "s#$HOME/.nvm/versions/node/##" | cut -d "/" -f1)
        export OMP_NODE_VERSION=''${NVM_NODE_VERSION:-$NODE_VERSION}
        export OMP_NPM_VERSION=$(cat $HOME/.nvm/versions/node/$NODE_VERSION/lib/node_modules/npm/package.json | jq -r .version)
      else
        export OMP_NPM_VERSION=$(npm --version 2> /dev/null)
        export OMP_NODE_VERSION=$(node --version 2> /dev/null)
      fi
    }

    function prompt_t_npm () {
      export OMP_NPM_SCRIPTS=$([[ -f package.json ]] && cat package.json | jq -er '.scripts | keys? | sort | join(" ")' || echo "no scripts/package.json")
    }
    
    function prompt_t_java () {
      case $(uname) in
        Linux)
            export OMP_JAVA_VERSION=$(command -v java &>/dev/null && java --version | head -n 1 | awk '{print $1 " " $2}')
            #export OMP_GRADLE_VERSION=$(command -v gw &>/dev/null && gw --version | grep "Gradle" | awk '{print $1 " " $2}')
          ;;
        Darwin)
          if [ $(ls /Library/Java/JavaVirtualMachines/ | wc -l) != 0 ]; then
            export OMP_DEFAULT_JAVA=$(/usr/libexec/java_home)
            export OMP_JAVA_VERSION=$(echo ''${JAVA_HOME:-$OMP_DEFAULT_JAVA} | tr "/" " " | awk '{print $4}')
          else
            export OMP_JAVA_VERSION=$(command -v java &>/dev/null && java --version | head -n 1 | awk '{print $1 " " $2}')
            #export OMP_GRADLE_VERSION=$(command -v gw &>/dev/null && gw --version | grep "Gradle" | awk '{print $1 " " $2}')
          fi
          ;;
      esac
    }
    
    function prompt_t_git () {
      export OMP_GIT_VERSION=$(command -v git &>/dev/null && git --version | awk '{print $3}')
    } 
    
    function set_poshcontext() {
      prompt_t_node
      prompt_t_npm
      prompt_t_java
      prompt_t_git
    }
  '';

  };
}
