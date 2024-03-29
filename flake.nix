{
  description = "Custom tools for nix-based workstations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11-small";
    flake-utils.url = "flake:flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    overlays.url = "github:thelonelyghost/blank-overlay-nix";

    tag = {
      url = "https://flakehub.com/f/TheLonelyGhost/tag/*.tar.gz";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        overlays.follows = "overlays";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "flake-compat";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat, overlays, tag }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # For npiperelay
          config.allowUnsupportedSystem = true;
          overlays = [ overlays.overlays.default ];
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

        keepassxc-get = import ./packages/keepassxc-get.nix { inherit pkgs; };
        flakify = import ./packages/flakify.nix { inherit pkgs; };
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.bashInteractive
            pkgs.gnumake
            flakify
          ];
          buildInputs = [ ];
        };

        packages = {
          tag = tag.defaultPackage."${system}";
          g = import ./packages/g.nix { inherit pkgs; };
          git-ignore = import ./packages/git-ignore.nix { inherit pkgs; };
          tat = import ./packages/tat.nix { inherit pkgs; };
          pbcopy = import ./packages/pbcopy.nix { inherit pkgs; };
          pbpaste = import ./packages/pbpaste.nix { inherit pkgs; };

          inherit npiperelay wsl-ssh-agent-relay wsl-keepassxc-relay keepassxc-get flakify;
          inherit (pkgs) git-credential-keepassxc;
        };
      }
    )) // {
      templates.python = {
        path = ./templates/python;
        description = "Python project tooling";
      };
      templates.rust = {
        path = ./templates/rust;
        description = "Rust project tooling";
      };
      templates.default = {
        path = ./templates/default;
        description = "No fluff, basic project workspace";
      };
    };
}
