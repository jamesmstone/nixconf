{self, ...}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.matui-configured = let
      config = {
        user_id = "@jamesmstone:beeper.com";
        homeserver_url = "https://matrix.beeper.com";
      };

      configDir = pkgs.runCommand "matui-config" {} ''
        install -Dm444 ${(pkgs.formats.toml {}).generate "matui-config.toml" config} \
          $out/matui/config.toml
      '';
    in
      self.lib.writeShellApplicationWithDefaults pkgs {
        name = "matui";
        runtimeInputs = [self'.packages.matui];
        text = ''
          XDG_CONFIG_HOME=${configDir} exec matui "$@"
        '';
      };
  };
}
