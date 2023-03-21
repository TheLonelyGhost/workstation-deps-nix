{ pkgs, thelonelyghost, ... }:
# vim: set ts=2 sts=2 sw=2 et

let
  version = "0.12.0";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "git-credential-keepassxc";
  inherit version;
  buildFeatures = [
    "notification"
    "yubikey"
    # "strict-caller"
  ];

  src = pkgs.fetchFromGitHub {
    owner = "Frederick888";
    repo = "git-credential-keepassxc";
    rev = "v${version}";
    sha256 = "sha256-siVSZke+anVTaLiJVyDEKvgX+VmS0axa+4721nlgmiw=";
  };

  cargoSha256 = "sha256-QMAAKkjWgM/UiOfkNMLQxyGEYYmiSvE0Pd8fZXYyN48=";

  buildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.Security
    pkgs.darwin.apple_sdk_11_0.frameworks.Cocoa
    pkgs.darwin.apple_sdk_11_0.frameworks.Foundation
  ];

  meta = {
    description = "Helper that allows Git (and shell scripts) to use KeePassXC as credential store";
    homepage = "https://github.com/Frederick888/git-credential-keepassxc";
    maintainers = [ thelonelyghost ];
    license = [ pkgs.lib.licenses.gpl3 ];
  };
}
