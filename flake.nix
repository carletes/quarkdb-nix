{
  description = "NixOS module for QuarkDB (https://eos-web.web.cern.ch/eos-web/)";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      perSystem = { config, pkgs, ... }: {
        packages = {
          quarkdb = pkgs.callPackage ./nixpkgs/quarkdb {
            inherit (pkgs)
              lib stdenv fetchgit
              bzip2
              cmake
              elfutils
              fmt
              git
              jemalloc
              libbfd
              libuuid
              lz4
              openssl
              pkg-config
              python3
              rocksdb
              snappy
              xrootd
              zstd
              ;
          };

          default = config.packages.quarkdb;
        };
      };
    };
}
