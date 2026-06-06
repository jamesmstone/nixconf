{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.matui = pkgs.rustPlatform.buildRustPackage {
      pname = "matui";
      version = "0.6.0-unstable-fork";

      src = inputs.matui;

      cargoLock = {
        lockFile = "${inputs.matui}/Cargo.lock";
      };

      nativeBuildInputs = [pkgs.pkg-config pkgs.makeWrapper];
      buildInputs = [pkgs.openssl pkgs.sqlite];

      postInstall = ''
        wrapProgram $out/bin/matui --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.ffmpeg]}
      '';

      meta = {
        description = "Opinionated Matrix TUI (E2EE via vodozemac, no libolm); patched fork";
        homepage = "http://hermanii:3000/james/matui";
        license = pkgs.lib.licenses.gpl2Only;
        platforms = pkgs.lib.platforms.linux;
        mainProgram = "matui";
      };
    };
  };
}
