{ pkgs }:
# vim: set ts=2 sts=2 sw=2 et

pkgs.writeShellApplication {
  name = "git-ignore";

  runtimeInputs = [
    pkgs.curl
    pkgs.perl
    pkgs.coreutils
  ];

  text = ''
    topics="$(perl -e 'print join(\",\", @ARGV);' "$@")"

    curl --fail -SsLo - "https://www.toptal.com/developers/gitignore/api/$topics" | \
      tee ./.gitignore
  '';
}
