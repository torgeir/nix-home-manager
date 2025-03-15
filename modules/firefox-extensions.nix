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
  # curl -s --head https://addons.mozilla.org/firefox/downloads/latest/darkreader/ | grep location | awk '{print $2}' | pbcopy
  # nix-hash --type sha256 --flat <(curl -L -s https://addons.mozilla.org/firefox/downloads/latest/darkreader/)
  # this does not always work, just download the xpi instead and sha256sum
  #
  # find ids by installing a plugin manually then going to about:debugging#/runtime/this-firefox
  # remove it then add it here or looking at manifest.json:browser_specific_settings.gecko.id
  #
  # or look at https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/generated-firefox-addons.nix?ref_type=heads

  darkreader = buildExtension rec {
    pname = "darkreader";
    version = "4.9.99";
    id = "addon@darkreader.org";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/4405074/darkreader-${version}.xpi";
    sha256 = "02c67ce2b3cd96719b5e369b9207ef11ed6c3a79eccb454d1e6ec3e005004e72";
  };

  ublock-origin = buildExtension rec {
    pname = "ublock-origin";
    version = "1.62.0";
    id = "uBlock0@raymondhill.net";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/4412673/ublock_origin-${version}.xpi";
    sha256 = "8a9e02aa838c302fb14e2b5bc88a6036d36358aadd6f95168a145af2018ef1a3";
  };

  # ! name has -, filename has _
  onepassword-x-password-manager = buildExtension rec {
    pname = "1password-x-password-manager";
    version = "8.10.64.7";
    id = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/4448043/1password_x_password_manager-${version}.xpi";
    sha256 = "c67f4fa0b6cdfe7e5efea4f5a09a1c57fda0e0f55d999761f5b4e9e4180ba4ef";
  };

  vimium-ff = buildExtension rec {
    pname = "vimium-ff";
    version = "2.1.2";
    id = "{d7742d87-e61d-4b78-b8a1-b469842139fa}";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/4259790/vimium_ff-${version}.xpi";
    sha256 = "3b9d43ee277ff374e3b1153f97dc20cb06e654116a833674c79b43b8887820e1";
  };

  multi-account-containers = buildExtension rec {
    pname = "multi-account-containers";
    version = "8.2.0";
    id = "@testpilot-containers";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/4355970/multi_account_containers-${version}.xpi";
    sha256 = "1ce35650853973572bc1ce770076d93e00b6b723b799f7b90c3045268c64b422";
  };

  firefox-color = buildExtension rec {
    pname = "firefox-color";
    version = "2.1.7";
    id = "FirefoxColor@mozilla.com";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/3643624/firefox_color-${version}.xpi";
    sha256 = "b7fb07b6788f7233dd6223e780e189b4c7b956c25c40493c28d7020493249292";
  };

  tree-style-tab = buildExtension rec {
    pname = "tree-style-tab";
    version = "3.9.19";
    id = "treestyletab@piro.sakura.ne.jp";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/4197314/tree_style_tab-${version}.xpi";
    sha256 = "bb67f47a554f8f937f4176bee6144945eb0f240630b93f73d2cff49f0985b55a";
  };

  sidebery = buildExtension rec {
    pname = "sidebery";
    version = "5.2.0";
    id = "{3c078156-979c-498b-8990-85f7987dd929}";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/4246774/sidebery-${version}.xpi";
    sha256 = "a5dd94227daafeec200dc2052fae6daa74d1ba261c267b71c03faa4cc4a6fa14";
  };

}
