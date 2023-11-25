{ pkgs, thelonelyghost, ... }:
# vim: set ts=2 sts=2 sw=2 et

let
  go-build = import ../lib/go-build.nix { inherit pkgs; };

  version = "0.1.0";
  lic = pkgs.lib.licenses;
  plat = pkgs.lib.platforms;

  goarch = platform: {
    "i686" = "386";
    "x86_64" = "amd64";
    "aarch64" = "arm64";
    "arm" = "arm";
    "armv5tel" = "arm";
    "armv6l" = "arm";
    "armv7l" = "arm";
    "mips" = "mips";
    "mipsel" = "mipsle";
    "riscv64" = "riscv64";
    "s390x" = "s390x";
    "powerpc64le" = "ppc64le";
  }.${platform.parsed.cpu.name} or (throw "Unsupported system");
in
# Because we want to build the EXE for windows, but execute it from WSL
pkgs.stdenv.mkDerivation {
  pname = "npiperelay";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "jstarks";
    repo = "npiperelay";
    rev = "v${version}";
    sha256 = "sha256-cg4aZmpTysc8m1euxIO2XPv8OMnBk1DwhFcuIFHF/1o=";
  };

  impureEnvVars = pkgs.lib.fetchers.proxyImpureEnvVars ++ [
    "GIT_PROXY_COMMAND"
    "SOCKS_SERVER"
  ];

  nativeBuildInputs = [
    pkgs.go
  ];

  configurePhase = ''
    runHook preConfigure

    export GOCACHE="$TMPDIR/go-cache"
    export GOPATH="$TMPDIR/go"

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    go build -ldflags="-s -w" -o build/npiperelay.exe .

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r ./build $out/bin

    runHook postInstall
  '';

  GOFLAGS = [
    "-mod=vendor"
    "-trimpath"
  ];

  # deleteVendor = true;
  # vendorHash = "sha256-9KBecJBMHYgOD0rS5kKuMeBPD6K5CbJ/tRDPExhjwCs=";

  # This is because npiperelay needs to be compiled for windows and the EXE
  # executed from within WSL, so hardcode the Windows compile target and
  # assume the target linux is the same arch as the Windows host.
  GOOS = "windows";
  GOARCH = goarch pkgs.stdenv.targetPlatform;
  # GOHOSTOS = pkgs.stdenv.buildPlatform.parsed.kernel.name;
  # GOHOSTARCH = goarch pkgs.stdenv.buildPlatform;

  meta = {
    description = "Allows access to Windows named pipes from WSL";
    homepage = "https://github.com/jstarks/npiperelay";
    maintainers = [ thelonelyghost ];
    license = [ lic.mit ];
    platform = [ plat.linux ]; # Only useful from WSL -> Windows
  };
}
