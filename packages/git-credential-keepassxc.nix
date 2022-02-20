{ pkgs, thelonelyghost, ... }:

pkgs.rustPlatform.buildRustPackage {
  pname = "git-credential-keepassxc";
  version = "0.8.2";
  buildFeatures = ["all"];

  src = pkgs.fetchFromGitHub {
    owner = "Frederick888";
    repo = "git-credential-keepassxc";
    rev = "v0.8.2";
    sha256 = "sha256-tmX2mD0AWsihRzuPJdr8DwnKo/4GnGIq+czOavtFpLU=";
  };

  cargoSha256 = "sha256-vltqwJXf5I7JF7kB/bOSh6b+OvODN3bWuDRAu8RsHnc=";

  meta = {
    description = "Helper that allows Git (and shell scripts) to use KeePassXC as credential store";
    homepage = "https://github.com/Frederick888/git-credential-keepassxc";
    maintainers = [thelonelyghost];
    license = [pkgs.lib.licenses.gpl3];
  };
}
