# NixOS ip based allowed ports

This NixOS module lets you open ports in your firewall that is only accepted by certain ips.

Let's say you have a postgresql database that you want to access from another server, then instead of opening the port to the entire world, you can just open the port to specific ips.

```nix
{
  networking.firewall.ipBasedAllowedTCPPorts = [
    {
      port = 5432;
      ips = [
        ipOffice
        ipHome
      ];
    }
  ];
}
```

## Usage and installation

To use this module, add the flake to your flake.

```nix
# flake.nix
{
  inputs = {
    ip-whitelist.url = "github:Oak-Digital/nixos-ip-whitelist-firewall";
  };
  # ...
}
```

Then import the module in your configuration.

```nix
{ inputs, ... }:

{
  imports = [
    inputs.ip-whitelist.nixosModules.default
  ];
  #...
}
```

And now you can configure the ports that should be ip whitelisted.

```nix
let
  ipOffice = "x.x.x.x";
  ipHome = "y.y.y.y";
  ipDatacenter = "z.z.z.z/24";
in
{
  networking.firewall.ipBasedAllowedTCPPorts = [
    {
      port = 5432;
      ips = [
        ipOffice
        ipHome
        ipDatacenter
      ];
    }
  ];
}
```
