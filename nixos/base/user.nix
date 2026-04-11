{
  flake.nixosModules.base = {lib, ...}: {
    options.preferences = {
      user.name = lib.mkOption {
        type = lib.types.str;
        default = "james";
      };

      user.timezone = lib.mkOption {
        type = lib.types.str;
        default = "Europe/Copenhagen";
      };

      user.authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8SwiQTnAbm75QwPGe8igWlT38e/QlwkOZkz2iXTjqCJa9J++NhSvbtMf43nOTB0oQiJl2CmfQ0s6DpsKoJOlagSC4rJtKxMM3cz1Z7qY4VFRq2wbQhaDwIpuptTjYOHGLP/8LGpq3tIra8HXB71l3Q+l8cxjzFeUlUcoBGinrmh8Q7WvyXcrEDqJzgPwbhH4E+ZPgkT5bLXBnIDo3fk7JSS0SyPQrzu+ClEnOTBz9zma92jZnlDt3ECBKn1YHV2/2qxUDdvrnqYVfBodrT5bWhh/4N0UVs+7QBXprwO8u651eRKdPBsUSnYHVb3niWYjdbqVjrc36ryhajQQsEOIwYroBUz21p9mDWLjSF2PcVlr4x2sSV3OH3zIa8yCTTXkzGKAZMrUX5L4D2HB6qIRFS0Bd9zhTNyjEchWEhN+i8vvuiUiu9RpF+kb+F0rCkosggKWWn4hXgBNp5HqA16EZ6d5TlfspsIr1HiP9FP5EbIIlhTcnjBP3B6gyhc/zg/s= james@nixos"
        ];
      };
    };
  };
}
