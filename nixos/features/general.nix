{self, ...}: {
  flake.nixosModules.general = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      self.nixosModules.extra_hjem
      self.nixosModules.gtk
      self.nixosModules.nix
    ];

    users.users.${config.preferences.user.name} = {
      isNormalUser = true;
      description = "${config.preferences.user.name}'s account";
      extraGroups = ["wheel" "networkmanager"];
      shell = self.packages.${pkgs.system}.environment;

      initialPassword = "12345"; # todo use https://github.com/Mic92/sops-nix?tab=readme-ov-file#setting-a-users-password
    };

    persistance.data.directories = [
      "nixconf"

      "Videos"
      "Documents"
      "Projects"

      ".ssh"
    ];

    # todo: remove
    persistance.cache.directories = [
      ".local/share/zoxide"
      ".local/share/direnv"
      ".local/share/nvim"
      ".local/share/fish"
      ".config/nvim"
    ];
  };
}
