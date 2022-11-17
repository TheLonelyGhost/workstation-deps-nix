{
  description = "Custom tools for nix-based workstations";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.overlays.url = "github:thelonelyghost/blank-overlay-nix";
  inputs.tag.url = "github:thelonelyghost/tag";
  inputs.tag.inputs.overlays.follows = "overlays";

  outputs = { self, nixpkgs, flake-utils, flake-compat, overlays, tag }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnsupportedSystem = true;
          overlays = [overlays.overlays.default];
        };

        thelonelyghost = {
          name = "David Alexander";
          email = "opensource@thelonelyghost.com";
          github = "TheLonelyGhost";
          githubId = 1276113;
        };

        npiperelay = import ./packages/npiperelay.nix { inherit pkgs thelonelyghost; };
        wsl-ssh-agent-relay = import ./packages/wsl/ssh-agent-relay.nix { inherit pkgs npiperelay; };
        wsl-keepassxc-relay = import ./packages/wsl/keepassxc-relay.nix { inherit pkgs npiperelay; };

        git-credential-keepassxc = import ./packages/git-credential-keepassxc.nix { inherit pkgs thelonelyghost; };
        keepassxc-get = import ./packages/keepassxc-get.nix { inherit pkgs git-credential-keepassxc; };
      in
      {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.bashInteractive
            pkgs.gnumake
          ];
          buildInputs = [ ];
        };

        packages = {
          tag = tag.outputs.defaultPackage."${system}";
          nixify = import ./packages/nixify.nix { inherit pkgs; };
          flakify = import ./packages/flakify.nix { inherit pkgs; };
          g = import ./packages/g.nix { inherit pkgs; };
          git-ignore = import ./packages/git-ignore.nix { inherit pkgs; };
          tat = import ./packages/tat.nix { inherit pkgs; };
          pbcopy = import ./packages/pbcopy.nix { inherit pkgs; };
          pbpaste = import ./packages/pbpaste.nix { inherit pkgs; };

          inherit npiperelay wsl-ssh-agent-relay wsl-keepassxc-relay;
          inherit git-credential-keepassxc keepassxc-get;
        };
      }
    );
}
