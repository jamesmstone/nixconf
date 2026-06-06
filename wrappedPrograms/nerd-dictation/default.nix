{
  perSystem = {pkgs, ...}: {
    packages.nerd-dictation = let
      inherit (pkgs) lib stdenv fetchurl fetchgit python3Packages;

      libvosk = stdenv.mkDerivation {
        name = "libvosk";
        pname = "libvosk";

        src = fetchurl {
          url = "https://github.com/alphacep/vosk-api/releases/download/v0.3.45/vosk-linux-x86_64-0.3.45.zip";
          sha256 = "sha256-u9yO2FxDl59kQxQoiXcOqVy/vFbP+1xdzXOvqHXF+7I=";
        };

        nativeBuildInputs = [pkgs.unzip];
        propagatedBuildInputs = [stdenv.cc];
        unpackPhase = "unzip $src";

        installPhase = ''
          mkdir -p $out/lib
          mv vosk-linux-x86_64-0.3.45/* $out/lib
        '';
      };

      vosk = python3Packages.buildPythonPackage {
        pname = "vosk";
        version = "0.3.45";
        format = "setuptools";

        src = fetchgit {
          url = "https://github.com/alphacep/vosk-api";
          rev = "cf2560c9f8a49d3d366b433fdabd78c518231bec";
          sparseCheckout = [
            "src"
            "python"
          ];
          hash = "sha256-hVQJNZSNhpw+BdOkZDqDVlRg6feK5OjR0ks7DizrBeE=";
        };

        nativeBuildInputs = [stdenv.cc];
        buildInputs = [libvosk];
        propagatedBuildInputs = [
          python3Packages.cffi
          python3Packages.requests
          python3Packages.srt
          python3Packages.websockets
          python3Packages.tqdm
          libvosk
        ];

        patches = [
          ./vosk-setup.py.patch
        ];

        configurePhase = ''
          # hack: put things in places like their module expects
          cp ${libvosk}/lib/vosk_api.h src/
          cp ${libvosk}/lib/libvosk.so python/vosk/
        '';

        preBuild = "cd python";
        doCheck = false;
      };

      pyWithVosk = python3Packages.python.withPackages (p: [vosk]);
    in
      stdenv.mkDerivation {
        name = "nerd-dictation";
        pname = "nerd-dictation";

        src = fetchgit {
          url = "https://github.com/ideasman42/nerd-dictation";
          sparseCheckout = ["nerd-dictation"];
          hash = "sha256-xNjsBDbSPzE3H96kike/n2apYfofdAIp8IwifwGlW6I=";
        };

        nativeBuildInputs = [pkgs.makeWrapper];
        propagatedBuildInputs = [
          pyWithVosk
          pkgs.xdotool
          pkgs.pulseaudio
          pkgs.wtype
        ];

        preInstall = ''
          mkdir -p "$out/bin"
          cp nerd-dictation $out/bin/
          chmod +x $out/bin/nerd-dictation
        '';

        postFixup = ''
          wrapProgram $out/bin/nerd-dictation \
            --set PATH ${lib.makeBinPath [
            pyWithVosk
            pkgs.xdotool
            pkgs.pulseaudio
            pkgs.wtype
          ]} \
            --set LD_LIBRARY_PATH ${lib.makeLibraryPath [libvosk pkgs.gcc.cc]}
        '';
      };
  };
}
