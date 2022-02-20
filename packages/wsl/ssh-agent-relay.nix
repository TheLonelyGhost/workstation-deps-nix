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
  SSH_AUTH_SOCK="''${SSH_AUTH_SOCK:-$sock}"

  if [ "$SSH_AUTH_SOCK" != "$sock" ] && ! [ -e "$SSH_AUTH_SOCK" ]; then
    # If it doesn't exist on the filesystem, let's just set it to
    # our own location instead
    SSH_AUTH_SOCK="$sock"
  fi

  if [ -e "$SSH_AUTH_SOCK" ] && ! socat -u OPEN:/dev/null UNIX-CONNECT:"''${SSH_AUTH_SOCK}" 1>/dev/null 2>&1; then
    # The socket is closed. Let's remove it so we can recreate it
    # further down
    rm "''${SSH_AUTH_SOCK}"
  fi

  if ! [ -e "''${SSH_AUTH_SOCK}" ]; then
    ( setsid socat UNIX-LISTEN:"''${SSH_AUTH_SOCK}",fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork & ) &>/dev/null
  fi

  if [ "$SSH_AUTH_SOCK" != "$sock" ]; then
    # This way we can eval the output safely (as much as `eval` is safe...)
    printf 'export SSH_AUTH_SOCK=%q\n' "$sock"
  fi
  '';
}
