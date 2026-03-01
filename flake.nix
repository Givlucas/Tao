{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        nativeBuildInputs = with pkgs; [
            dioxus-cli
            lld
          ];
      in
      {
        defaultPackage = pkgs.rustPlatform.buildRustPackage {
          pname = "tao";
          name = "tao";
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
          nativeBuildInputs = nativeBuildInputs;
          buildInputs = with pkgs; [
          	openssl
          ];
          buildPhase = ''
        	dx build --release --platform server
          '';
          installPhase = ''
        	mkdir -p $out/bin
        	cp -r ./target/dx/tao/release/web/. $out/bin/
          '';
        };

        devShell = with pkgs; mkShell {
          buildInputs = nativeBuildInputs ++ [ cargo ];
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
        };
      }
    );
}
