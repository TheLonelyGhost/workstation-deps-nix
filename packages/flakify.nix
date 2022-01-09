{ pkgs }:

let
  flakeNixTemplate = builtins.readFile ../templates/flake.nix;
  defaultNixTemplate = builtins.readFile ../templates/default.nix;
in
pkgs.writeShellApplication {
  name = "flakify";

  runtimeInputs = [
    pkgs.neovim-unwrapped
    pkgs.git
    pkgs.gnugrep
  ];

  text = ''
    if ! [ -e flake.nix ]; then
      cat >flake.nix <<'EOH'
    ${flakeNixTemplate}
    EOH
      git add -N ./flake.nix 2>/dev/null || true
    fi

    if ! [ -e default.nix ]; then
      cat >default.nix <<'EOH'
    ${defaultNixTemplate}
    EOH
      git add -N ./default.nix 2>/dev/null || true
    fi

    if ! grep -qFe 'use flake' .envrc 1>/dev/null 2>&1; then
      printf 'use flake\n' >> .envrc
      direnv allow .
    fi

    "''${EDITOR:-nvim}" flake.nix
  '';
}
