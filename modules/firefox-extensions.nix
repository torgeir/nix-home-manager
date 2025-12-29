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
    url = "https://addons.mozilla.org/firefox/downloads/file/4638146/darkreader-4.9.118.xpi";
    sha256 = "154k9hn7ak8x0kvvxvdj4p7q0lkn03rp4n4sxnfy2pjlhh7dmlk9";
  };

  ublock-origin = buildExtension rec {
    pname = "ublock-origin";
    version = "1.65.0";
    id = "uBlock0@raymondhill.net";
    url = "https://addons.mozilla.org/firefox/downloads/file/4629131/ublock_origin-1.68.0.xpi";
    sha256 = "05a3f11dcbdj6s6c70x7hanqrpdv35lia4ia490qh0clljylmbsw";
  };

  # ! name has -, filename has _
  onepassword-x-password-manager = buildExtension rec {
    pname = "1password-x-password-manager";
    version = "8.11.8.40.";
    id = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4644396/1password_x_password_manager-8.11.23.2.xpi";
    sha256 = "1kc6278qdyj2zcrsip38rpy8cf9dmd54jrfhz5fbs4rhyhp7hjiv";
  };

  vimium-ff = buildExtension rec {
    pname = "vimium-ff";
    version = "2.3";
    id = "{d7742d87-e61d-4b78-b8a1-b469842139fa}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4618554/vimium_ff-2.3.1.xpi";
    sha256 = "0wqlb4iik74h1jilkif20zl6br3l3rfvjq2fdsic4f8rnhf8c6rc";
  };

  multi-account-containers = buildExtension rec {
    pname = "multi-account-containers";
    version = "8.3.0";
    id = "@testpilot-containers";
    url = "https://addons.mozilla.org/firefox/downloads/file/4627302/multi_account_containers-8.3.6.xpi";
    sha256 = "0jnk4k8nr33sr9z8gkn4izxvlajak5zr47cz8ikg3v2bhidy6gdz";
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
    url = "https://addons.mozilla.org/firefox/downloads/file/4602712/tree_style_tab-4.2.7.xpi";
    sha256 = "06q26yd2smv5rb9x7g4r3z206g8vj795pqlcjqjsp22pcf0a73q9";
  };

  sidebery = buildExtension rec {
    pname = "sidebery";
    version = "5.3.3";
    id = "{3c078156-979c-498b-8990-85f7987dd929}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4613339/sidebery-5.4.0.xpi";
    sha256 = "16gm10jhk2wnxpxw167jwqs6s3qjxa5kpipmmy6h2nscvxbk2jhq";
  };

}
