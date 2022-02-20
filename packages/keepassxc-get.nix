{ pkgs, git-credential-keepassxc, ... }:

pkgs.writeShellApplication {
  name = "keepassxc-get";

  runtimeInputs = [
    git-credential-keepassxc
    pkgs.gnugrep
    pkgs.jq
  ];

  text = ''

  helpText() {
    local helper_connect helper_auth_me helper_authorize txt
    txt=""

    helper_connect='git-credential-keepassxc configure'
    helper_auth_me='git-credential-keepassxc caller me'
    # shellcheck disable=SC2016
    helper_authorize='git-credential-keepassxc caller add --uid "$(id -u)" --gid "$(id -g)" "$(head -n1 "$(command -v keepassxc-get)" | tr -d '"'#!'"')"'

    if [ "$(jq '.databases | length' ~/.config/git-credential-keepassxc 2>/dev/null || echo 0)" -lt 1 ]; then
      txt="''${txt}    $helper_connect\n"
    fi
    if [ "$(jq '.callers | length' ~/.config/git-credential-keepassxc 2>/dev/null || echo 0)" -lt 1 ]; then
      txt="''${txt}    $helper_auth_me\n"
      txt="''${txt}    $helper_authorize\n"
    elif [ "$(jq '.callers | length' ~/.config/git-credential-keepassxc 2>/dev/null || echo 0)" -lt 2 ]; then
      txt="''${txt}    $helper_authorize\n"
    fi

    if [ -n "$txt" ]; then
      printf '\nTo fix this, please run the following:\n\n%b' "$txt" >&2
    fi
  }

  if ! {
    printf 'url=%s\n' "''${1?URL for the secret you need}"
    if [ -n "''${2:-}" ]; then
      printf 'username=%s\n' "$2"
    fi
  } | git-credential-keepassxc get --totp --advanced-fields --json 2> >(
    grep -v -iFe "Failed to get TOTP"
  )
  then
    helpText
    exit 1
  fi
  '';
}
