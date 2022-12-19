{ pkgs }:
# vim: set ts=2 sts=2 sw=2 et

pkgs.writeShellApplication {
  name = "flakify";

  runtimeInputs = [
    pkgs.git
    pkgs.gnugrep
  ];

  text = builtins.readFile ./flakify.sh;
}
