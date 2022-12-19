{ pkgs }:
# vim: set ts=2 sts=2 sw=2 et

pkgs.writeShellApplication {
  name = "flakify";

  runtimeInputs = [
    pkgs.git
    pkgs.gnugrep
  ];

  text = ''
  # Defaults, if not set
  : "''${FLAKIFY_URI:=github:thelonelyghost/workstation-deps-nix}"
  : "''${FLAKIFY_TEMPLATE:=flakify}"

  nix flake init -t "''${FLAKIFY_URI}#''${FLAKIFY_TEMPLATE}"
  if git rev-parse --git-dir &>/dev/null; then
    git add -f -N ./flake.nix ./default.nix ./flake.lock || true
  fi
  direnv allow .

  if [ -n "''${EDITOR:-}" ]; then
    "''${EDITOR}" ./flake.nix
  else
    printf '\n\tWARNING: missing variable %q\n\n' "EDITOR" >&2
  fi
  '';
}
