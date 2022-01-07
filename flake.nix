{
  description = "Custom tools for nix-based workstations";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.tag.url = "github:thelonelyghost/tag";

  outputs = { self, nixpkgs, flake-utils, flake-compat, tag }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
        {
          devShell = pkgs.mkShell {
            nativeBuildInputs = [
              pkgs.bashInteractive
              pkgs.gnumake
              tag.outputs.defaultPackage."${system}"
            ];
            buildInputs = [];
          };

          packages = {
            tag = tag.outputs.defaultPackage."${system}";
          };
        }
    );
}
