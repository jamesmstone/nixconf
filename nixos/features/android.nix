{
  self,
  pkgs,
  lib,
  ...
}: {
  flake.nixOnDroidModules.android = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixOnDroidModules.base
      self.nixOnDroidModules.openssh
    ];

    config = {
      preferences.user.name = "nix-on-droid";

      # Robust supervisord autostart. nix-on-droid's login-inner only starts
      # supervisord `if [ ! -e <socket> ]`, so a stale socket left by a killed
      # instance permanently blocks the start (and with it sshd). Run an
      # idempotent liveness check at session init: if supervisord isn't actually
      # responding, clear any stale socket and start it. Wired through
      # sessionVariables (sourced once per login) and guarded to always exit 0,
      # so it can never break login even if supervisord is misconfigured.
      environment.sessionVariables._NOD_ENSURE_SUPERVISORD = let
        ensure = pkgs.writeShellScript "ensure-supervisord" ''
          ${config.supervisord.package}/bin/supervisorctl pid >/dev/null 2>&1 && exit 0
          rm -f ${config.supervisord.socketPath} 2>/dev/null || true
          ${config.supervisord.package}/bin/supervisord -c /etc/supervisord.conf >/dev/null 2>&1 || true
          exit 0
        '';
      in "$(${ensure} >/dev/null 2>&1; true)";

      # The Nix-on-Droid app launches the proot login with TERM unset or "dumb",
      # so ncurses apps refuse to run (tmux: "open terminal failed: not a
      # terminal"). Default to a real terminal type, but preserve a usable TERM
      # that was already provided (e.g. forwarded over an interactive SSH login).
      environment.sessionVariables.TERM =
        ''$(if [ "''${TERM:-dumb}" = dumb ]; then echo xterm-256color; else echo "''${TERM}"; fi)'';

      environment.etc."resolv.conf".text = lib.mkForce ''
        # Use Tailscale's local resolver
        nameserver 100.100.100.100
        # Add tailnet search domain so short names work
        search finch-moth.ts.net
        # Fallback to a public DNS
        nameserver 1.1.1.1
        nameserver 8.8.8.8
      '';
    };
  };
}
