{ fetchurl, stdenv, lib, pkgs, ... }:

let
  # Copyright (C) 2019-2022 Robert Helgesson
  buildExtension = { pname, version, id, url, sha256, ... }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";
      src = fetchurl { inherit url sha256; };
      preferLocalBuild = true;
      allowSubstitutes = true;
      buildCommand = ''
        # application id of firefox
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${id}.xpi"
      '';
    };
in {

  # find urls and sha256 by

# for w in darkreader ublock-origin 1password-x-password-manager vimium-ff multi-account-containers firefox-color tree-style-tab sidebery; do
#   u=$(curl -L -s --head https://addons.mozilla.org/firefox/downloads/latest/$w/ | grep location | awk '{print $2}' | tr -d "\r\n")
#   echo "    url = \"$u\";\n    sha256 = \"$(nix-prefetch-url $u 2>/dev/null)\";\n";
# done

  # find ids by installing a plugin manually then going to about:debugging#/runtime/this-firefox
  # remove it then add it here or looking at manifest.json:browser_specific_settings.gecko.id
  #
  # or look at https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/generated-firefox-addons.nix?ref_type=heads

  darkreader = buildExtension rec {
    pname = "darkreader";
    version = "4.9.110";
    id = "addon@darkreader.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/4535824/darkreader-4.9.110.xpi";
    sha256 = "1p1hmrpqcnx8p218c8m148rz1z3n40xlk03lb441mk3hcj14aql4";
  };

  ublock-origin = buildExtension rec {
    pname = "ublock-origin";
    version = "1.65.0";
    id = "uBlock0@raymondhill.net";
    url = "https://addons.mozilla.org/firefox/downloads/file/4578681/ublock_origin-1.66.4.xpi";
    sha256 = "1c3z0ww46xcc370rlb3g8q41hjxx5csqjhwnd0ajy8810s9wsqmw";
  };

  # ! name has -, filename has _
  onepassword-x-password-manager = buildExtension rec {
    pname = "1password-x-password-manager";
    version = "8.11.8.40.";
    id = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4588819/1password_x_password_manager-8.11.12.27.xpi";
    sha256 = "18x3vsxwnj15bk5wbpkhqjygriyqgxmvxqzz9hqi5k27ix2qap23";
  };

  vimium-ff = buildExtension rec {
    pname = "vimium-ff";
    version = "2.3";
    id = "{d7742d87-e61d-4b78-b8a1-b469842139fa}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4524018/vimium_ff-2.3.xpi";
    sha256 = "16wfc19maics36b7wm37fh9h8n9m8xzpmj45p80axix1dcpw1a9x";
  };

  multi-account-containers = buildExtension rec {
    pname = "multi-account-containers";
    version = "8.3.0";
    id = "@testpilot-containers";
    url = "https://addons.mozilla.org/firefox/downloads/file/4494279/multi_account_containers-8.3.0.xpi";
    sha256 = "0c422f62y8yp79q5irpp9574h3nsyq5jb92plip2a4spq3lqhy6g";
  };

  firefox-color = buildExtension rec {
    pname = "firefox-color";
    version = "2.1.7";
    id = "FirefoxColor@mozilla.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/3643624/firefox_color-2.1.7.xpi";
    sha256 = "14lj4j9h80np50y4jh2wq9bbkixli7hq1rr3cbfk6wlgg2v0gyxp";
  };

  tree-style-tab = buildExtension rec {
    pname = "tree-style-tab";
    version = "4.2.5";
    id = "treestyletab@piro.sakura.ne.jp";
    url = "https://addons.mozilla.org/firefox/downloads/file/4583182/tree_style_tab-4.2.6.xpi";
    sha256 = "1yaixz2dssv8sbzlk90p0jjc91yxrn7w7l94dwkbjvg2szn9x61z";
  };

  sidebery = buildExtension rec {
    pname = "sidebery";
    version = "5.3.3";
    id = "{3c078156-979c-498b-8990-85f7987dd929}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4442132/sidebery-5.3.3.xpi";
    sha256 = "0ss7lzis7x1smjz05f75z9rjfhix3g6kx517bywxddwkbwqaiyd4";
  };

}
