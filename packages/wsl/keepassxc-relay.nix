{ pkgs, npiperelay, ... }:


pkgs.writeShellApplication {
  name = "keepassxc-relay";

  runtimeInputs = [
    npiperelay
    pkgs.socat
    pkgs.busybox
  ];

  text = ''
  if [ -e "/mnt/wslg/runtime-dir" ]; then
    rundir="/mnt/wslg/runtime-dir"
  else
    rundir="''${HOME}/.local/run"
  fi
  if ! [ -e "$rundir" ]; then
    mkdir -p "$rundir"
    chmod 700 "$rundir"
  fi

  windows_username="''${1?Positional argument required for Windows Username}"
  sock="$rundir/org.keepassxc.KeePassXC.BrowserServer"

  if [ -e "$sock" ] && ! socat OPEN:/dev/null UNIX-CONNECT:"$sock" 1>/dev/null 2>&1; then
    # The socket is closed. Let's remove it so we can recreate
    # it further down
    rm "$sock"
  fi

  if ! [ -e "$sock" ]; then
    ( setsid socat UNIX-LISTEN:"$sock",fork EXEC:"npiperelay.exe -ei -s //./pipe/org.keepassxc.KeePassXC.BrowserServer_''${windows_username}",nofork & ) &>/dev/null
  fi

  printf 'export KEEPASSXC_BROWSER_SOCKET_PATH=%q\n' "$sock"
  '';
}
