{
  description = "A basic flake with a shell";
  # Known-stable version of nixpkgs
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/f096b7122ab08e93c8b052c92461ca71b80c0cc8";
  inputs.nixpkgs.url = "flake:nixpkgs";
  inputs.flake-utils.url = "flake:flake-utils";
  inputs.overlays.url = "github:thelonelyghost/blank-overlay-nix";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, overlays, flake-compat }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.overlays = [ overlays.overlays.default ];
          # config.allowUnfree = true;
        };
      in
      {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.bashInteractive
            pkgs.python3
            pkgs.poetry
          ];
          buildInputs = [
          ];
        };
      });
}
