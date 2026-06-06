# Exposed as a flake.lib helper so it works from both perSystem packages and nixosModules.
# Takes `pkgs` first since flake.lib has no ambient package set.
{
  flake.lib.writeShellApplicationWithDefaults = pkgs: args: let
    inherit (pkgs) writeShellApplication lib stdenv shellcheck-minimal;
    extraChecks = args.extraChecks or "";
    excludeFlags =
      lib.optionals ((args.excludeShellChecks or []) != []) [
        "--exclude"
        (lib.concatStringsSep "," (args.excludeShellChecks or []))
      ];
    shellcheckCommand = lib.optionalString (shellcheck-minimal != null) ''
      ${lib.getExe shellcheck-minimal} ${lib.escapeShellArgs (excludeFlags ++ (args.extraShellCheckFlags or []))} "$target"
    '';
    defaultChecks = ''
      runHook preCheck
      ${stdenv.shellDryRun} "$target"
      ${shellcheckCommand}
      runHook postCheck
    '';
    cleanedArgs = builtins.removeAttrs args ["extraChecks"];
    derivationArgs = (args.derivationArgs or {}) // {doCheck = true;};
  in
    writeShellApplication (cleanedArgs
      // {
        inherit derivationArgs;
        checkPhase = extraChecks + defaultChecks;
      });
}
