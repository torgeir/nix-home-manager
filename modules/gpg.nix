{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.t-gpg;
in
{
  options.programs.t-gpg.enable = lib.mkEnableOption "Enable gpg configuration";
  options.programs.t-gpg.opCmd = lib.mkOption {
    type = lib.types.str;
    default = "/run/wrappers/bin/op";
    description = "op cmd to use.";
  };

  config = lib.mkIf cfg.enable {

    #https://github.com/tejing1/nixos-config/blob/master/homeConfigurations/tejing/encryption.nix
    # https://freerangebits.com/posts/2023/12/gnupg-broke-emacs/
    programs.gpg = {
      enable = true;
      package = pkgs.gnupg24;
    };

    services.gpg-agent =
      let
        pinentry = pkgs.writeShellScriptBin "gpg-1p-pinentry" ''
          get_passphrase_from_1password() {
            local passphrase timeout_cmd=()
            if command -v timeout >/dev/null 2>&1; then
              timeout_cmd=(${pkgs.coreutils}/bin/timeout 1s)
            fi

            if passphrase=$("''${timeout_cmd[@]}" ${cfg.opCmd} item get keybase.io --format json \
              | /etc/profiles/per-user/torgeir/bin/jq -j '.fields[] | select(.id == "password") | .value' 2>/dev/null); then
              echo "D $passphrase"
              echo "OK"
              return 0
            else
              echo "ERR 83886179 1Password locked/unavailable <Pinentry>"
              return 1
            fi
          }

          # Send initial OK
          echo "OK Pleased to meet you"

          while IFS= read -r line; do
            case "$line" in
              "GETPIN")
                get_passphrase_from_1password
                ;;
              "BYE")
                echo "OK closing connection"
                exit 0
                ;;
              GETINFO\ pid)
                echo "D $$"
                echo "OK"
                ;;
              GETINFO\ flavor)
                echo "D tty"
                echo "OK"
                ;;
              OPTION*|SETDESC*|SETPROMPT*|SETTITLE*|SETOK*|SETCANCEL*|SETNOTOK*|SETERROR*|SETREPEAT*|SETREPEATOK*|SETREPEATERROR*|SETQUALITYBAR*|SETQUALITYBAR_T*)
                echo "OK"
                ;;
              *)
                echo "ERR 83886179 Command not supported <Pinentry>"
                ;;
            esac
          done
        '';
      in
      {
        enable = true;
        enableSshSupport = true;
        maxCacheTtl = 28800;
        defaultCacheTtl = 28800;
        maxCacheTtlSsh = 28800;
        defaultCacheTtlSsh = 28800;
        extraConfig = ''
          pinentry-program "${lib.getExe pinentry}"
        '';
      };
  };
}
