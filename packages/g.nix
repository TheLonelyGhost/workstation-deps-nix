{ pkgs }:

pkgs.writeShellApplication {
  name = "g";
  runtimeInputs = [
    pkgs.git
    pkgs.gnupg
  ];

  text = ''
    gpg-connect-agent updatestartuptty /bye 1>/dev/null

    if [ $# -gt 0 ]; then
      git "$@"
    else
      git status -sb
    fi
  '';
}
