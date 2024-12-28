{
  description = "NixOS module for QuarkDB (https://eos-web.web.cern.ch/eos-web/)";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlays.default =
        final: prev: {
          quarkdb = prev.callPackage ./nixpkgs/quarkdb {
            inherit (final)
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
        }
      ;
    } // (
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
        in
        {
          packages = {
            inherit (pkgs)
              quarkdb
              ;
          };
        }));
}
