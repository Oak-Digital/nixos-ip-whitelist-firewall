{ lib, config, ... }:

let
  inherit (lib)
    types
    mkOption;

  portWithIps = with types; submodule {
    options = {
      port = mkOption {
        type = int;
        description = ''
          The TCP port that is allowed to be accessed from the outside.
        '';
      };

      ips = mkOption {
        type = with types; listOf string;
        default = [ ];
        description = ''
          The IP addresses that are allowed to access the port.
          You can also use CIDR notation to specify a range of IP addresses.
        '';
      };
    };
  };
in
{
  options = {
    networking.firewall.ipBasedAllowedTCPPorts = mkOption {
      default = [ ];
      type = with types; listOf portWithIps;
      description = ''
        List of TCP ports that are allowed to be accessed by specified ips.
      '';
    };

    networking.firewall.ipBasedAllowedUDPPorts = mkOption {
      default = [ ];
      type = with types; listOf portWithIps;
      description = ''
        List of UDP ports that are allowed to be accessed by specified ips.
      '';
    };
  };

  config = {
    networking.firewall.extraCommands =
      let
        createCommand = proto: port: ip: ''
          iptables -A nixos-fw -p ${proto} --dport ${toString port} -s ${ip} -j nixos-fw-accept
        '';
      in
      ''
        # Allow access to the specified ports from the specified IP addresses.
        ${lib.concatMapStringsSep "\n" (portWithIps: ''
          ${lib.concatMapStringsSep "\n" (ip: ''
            echo "executing: ${createCommand "tcp" portWithIps.port ip}"
            ${createCommand "tcp" portWithIps.port ip}
          '') portWithIps.ips}
        '') config.networking.firewall.ipBasedAllowedTCPPorts}
        
        # Allow access to the specified ports from the specified IP addresses.
        ${lib.concatMapStringsSep "\n" (portWithIps: ''
          ${lib.concatMapStringsSep "\n" (ip: ''
            echo "executing: ${createCommand "udp" portWithIps.port ip}"
            ${createCommand "udp" portWithIps.port ip}
          '') portWithIps.ips}
        '') config.networking.firewall.ipBasedAllowedUDPPorts}
      '';

    networking.firewall.extraStopCommands =
      let
        removeCommand = proto: port: ip: ''
          iptables -D nixos-fw -p ${proto} --dport ${toString port} -s ${ip} -j nixos-fw-accept || true
        '';
      in
      ''
        # Drop ip based allowed tcp ports rules
        ${lib.concatMapStringsSep "\n" (portWithIps: ''
          ${lib.concatMapStringsSep "\n" (ip: ''
            echo "executing: ${removeCommand "udp" portWithIps.port ip}"
            ${removeCommand "tcp" portWithIps.port ip}
          '') portWithIps.ips}
        '') config.networking.firewall.ipBasedAllowedTCPPorts}

        # Drop ip based allowed udp ports rules
        ${lib.concatMapStringsSep "\n" (portWithIps: ''
          ${lib.concatMapStringsSep "\n" (ip: ''
            echo "executing: ${removeCommand "udp" portWithIps.port ip}"
            ${removeCommand "udp" portWithIps.port ip}
          '') portWithIps.ips}
        '') config.networking.firewall.ipBasedAllowedUDPPorts}
      '';
  };
}
