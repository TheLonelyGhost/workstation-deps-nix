{ pkgs }:
# vim: set ts=2 sts=2 sw=2 et

pkgs.writeShellApplication {
  name = "tat";
  runtimeInputs = [
    pkgs.tmux
  ];

  text = ''
    path_name="$(basename -- "$(pwd)" | tr . -)"
    session_name="''${1-$path_name}"

    create_if_needed_and_attach() {
      if [ -z "''${TMUX:-}" ]; then
        tmux new-session -As "$session_name"
      else
        if ! tmux has-session -t "$session_name" >/dev/null 2>&1; then
          env TMUX="" tmux new-session -As "$session_name" -d
        fi
        tmux switch-client -t "$session_name"
      fi
    }

    create_if_needed_and_attach
  '';
}
