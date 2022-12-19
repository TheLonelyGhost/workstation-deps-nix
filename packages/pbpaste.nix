{ pkgs }:
# vim: set ts=2 sts=2 sw=2 et

pkgs.writeShellApplication {
  name = "pbpaste";
  runtimeInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
    # see: https://codepre.com/en/como-usar-los-comandos-pbcopy-y-pbpaste-en-linux.html
    pkgs.xclip
  ];

  text = if pkgs.stdenv.isLinux then ''
    xclip -selection clipboard -o
  '' else ''
    /usr/bin/pbpaste
  '';
}
