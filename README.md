# Nix Flake: Workstation tools

This is a meta-repo including workstation tools that I find helpful.

Packages included:

- [`tag`](https://github.com/thelonelyghost/tag)

## Usage

### With Flakes

Add this repo to your `flake.nix` inputs like:

```nix
{
  # ...
  inputs.tlg-workstation.url = "github:thelonelyghost/workstation-deps-nix";
  # ...

  outputs = { self, nixpkgs, flake-utils, tlg-workstation, ...}@attrs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
      ws = tlg-workstation.packages."${system}";
    in {
      devShell = pkgs.mkShell {
        nativeBuildInputs = [
          pkgs.bashInteractive
          ws.tag
        ];
      };
    });
}
```

**Updating:** Anytime you want to update what workstation-deps offers, run `nix flake lock --update-input tlg-workstation` and rebuild your nix expression acccordingly.

### Without Flakes

If you're not yet using [Nix Flakes][flakes], such as with [`home-manager`][home-manager], here's how you can include it:

1. Install [`niv`][niv] and run `niv init`
2. Run `niv add thelonelyghost/workstation-deps-nix --name tlg-workstation`
3. Include the following in your code:

```nix
{ lib, config, ... }:

let
  sources = import ./nix/sources.nix {};
  pkgs = import sources.nixpkgs {};

  ws = (import (pkgs.fetchGitHub { inherit (sources.tlg-workstation) owner repo rev sha256; })).outputs.packages."${builtings.currentSystem}";
in
{
  home.packages = [
    ws.tag
  ];
}
```

**Updating:** Anytime you want to update what golang-webdev offers, run `niv update tlg-workstation` and rebuild your nix expression acccordingly.

[flakes]: https://github.com/NixOS/nix/blob/master/src/nix/flake.md
[home-manager]: https://github.com/nix-community/home-manager
[niv]: https://github.com/nmattia/niv
