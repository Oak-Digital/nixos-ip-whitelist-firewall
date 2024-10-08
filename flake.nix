{
  description = "A simple NixOS module for ip whitelisting certain ports";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules = rec {
      ip-whitelist-firewall = import ./modules/ip-whitelist-firewall.nix;
      default = ip-whitelist-firewall;
    };
  };
}
