{ pkgs ? import <nixpkgs> {} }:
let
  lume = pkgs.callPackage ./lume.nix {};
  haskellInputs = 
    pkgs.haskellPackages.developPackage { 
      root = ./.; 
      withHoogle = true;
      modifier = drv:
      pkgs.haskell.lib.addBuildTools drv (with pkgs.haskellPackages;
        [ cabal-install
          ghc
          haskell-language-server
        ]);   
    };
in
  pkgs.mkShell {
   inputsFrom = [haskellInputs lume]; 
  }
