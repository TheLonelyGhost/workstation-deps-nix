{ pkgs }:

let
  shellNixTemplate = builtins.readFile ../templates/shell.nix;
in
pkgs.writeShellApplication {
  name = "nixify";
  runtimeInputs = [
    pkgs.niv
    pkgs.git
    pkgs.direnv
    pkgs.neovim-unwrapped
  ];

  text = ''
    if ! [ -e shell.nix ]; then
      cat >shell.nix <<'EOH'
    ${shellNixTemplate}
    EOH
      if ! [ -e nix/sources.nix ]; then
        niv init --nixpkgs-branch nixpkgs-unstable
      fi
      git add -N ./shell.nix 2>/dev/null || true
    fi

    if ! grep -qFe 'use nix' .envrc 1>/dev/null 2>&1; then
      printf 'use nix\n' >> .envrc
      direnv allow .
    fi

    "''${EDITOR:-nvim}" shell.nix
  '';
}
