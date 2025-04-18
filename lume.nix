{ pkgs ? import <nixpkgs>  {} }:
pkgs.stdenv.mkDerivation {
  name = "lume";
  src = pkgs.fetchzip {
    url = "https://github.com/trycua/cua/releases/download/lume-v0.1.23/lume-0.1.23-darwin-arm64.pkg.tar.gz";    
    hash = "";
  };
  # buildInputs = with pkgs; [];
  installPhase =
  ''
    mkdir $out
    mv ./lume $out/lume/bin
  '';
}
