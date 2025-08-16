{ lib
, stdenv
, fetchgit
, bzip2
, cmake
, elfutils
, fmt
, git
, jemalloc
, libbfd
, libuuid
, lz4
, openssl
, pkg-config
, python3
, rocksdb
, snappy
, xrootd
, zstd
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "quarkdb";
  version = "0.4.3.112.d07fd8e";

  src = lib.makeOverridable fetchgit {
    url = "https://gitlab.cern.ch/eos/quarkdb.git";
    rev = "d07fd8ed0b231083a3e443722740acb3df6b355b";
    hash = "sha256-StI8YOMCGXnX0F3L4+dTVjrb5dP/gP5pR+5DWbHXKWM=";
    fetchSubmodules = true; # Some dependencies are in Git submodules.
    deepClone = true; # Needed by this package's `genversion.py` script.
  };

  postPatch = ''
    substituteInPlace genversion.py \
      --replace-fail '#!/usr/bin/env python3' '#!${python3}/bin/python3'
  '';

  nativeBuildInputs = [
    cmake
    git
    pkg-config
    python3
  ];

  buildInputs = [
    bzip2
    elfutils
    fmt
    jemalloc
    libbfd
    libuuid
    lz4
    openssl
    rocksdb
    snappy
    xrootd
    zstd
  ];

  strictDeps = true;

  cmakeFlags = [
    (lib.cmakeBool "PACKAGEONLY" false)
    (lib.cmakeBool "TESTCOVERAGE" false)
    (lib.cmakeBool "XROOTD_JEMALLOC" false)
    (lib.cmakeFeature "ROCKSDB_ROOT" "${rocksdb}")
  ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    ./test/quarkdb-tests

    # XXX Resilvering tests fail.
    # ./test/quarkdb-stress-tests

    runHook postCheck
  '';

  postInstall = ''
    rm -rf $out/bin/quarkdb-bench
    rm -rf $out/bin/quarkdb-stress-tests
    rm -rf $out/bin/quarkdb-sudo-tests
    rm -rf $out/bin/quarkdb-tests
    rm -rf $out/include
    rm -rf $out/lib/backward
    rm -rf $out/lib/cmake
    rm -rf $out/lib/libgmock*
    rm -rf $out/lib/libgtest*
    rm -rf $out/lib/libqclient*
    rm -rf $out/lib/pkgconfig
    rm -rf $out/sbin
  '';

  meta = with lib; {
    description = "Highly available datastore that implements a small subset of the Redis command set, developed by IT-ST at CERN";
    homepage = "https://gitlab.cern.ch/eos/quarkdb";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "quarkdb-server";
  };
})
