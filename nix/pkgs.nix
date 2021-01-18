# our packages overlay
pkgs: _: with pkgs; {
  votingToolsLibHaskellPackages = import ./haskell.nix {
    inherit config
      lib
      stdenv
      haskell-nix
      buildPackages
      ;
  };
}
