{ pkgs, npiperelay, ... }:

pkgs.writeShellApplication {
  name = "ssh-relay";

  runtimeInputs = [
    npiperelay
    pkgs.socat
    pkgs.busybox
  ];

  text = ''
  if [ -e "/mnt/wslg/runtime-dir" ]; then
    # Support WSL version of user-specific /run
    rundir="/mnt/wslg/runtime-dir"
  else
    rundir="''${HOME}/.local/run"
  fi
  if ! [ -e "$rundir" ]; then
    mkdir -p "$rundir"
    chmod 700 "$rundir"
  fi

  sock="$rundir/ssh-agent.sock"

  if [ -e "$sock" ] && ! socat -u OPEN:/dev/null UNIX-CONNECT:"$sock" 1>/dev/null 2>&1; then
    rm "$sock"
  fi

  if ! [ -e "$sock" ]; then
    ( setsid socat UNIX-LISTEN:"$sock",fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork & ) &>/dev/null
  fi

  printf 'export SSH_AUTH_SOCK=%q\n' "$sock"
  '';
}
