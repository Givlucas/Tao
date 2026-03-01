{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
        nativeBuildInputs = with pkgs; [
            cargo
            rustc
            rustfmt
            pre-commit
            rustPackages.clippy
            dioxus-cli
            lld
          ];
      in
      {
        defaultPackage = naersk-lib.buildPackage {
          src = ./.;
          nativeBuildInputs = nativeBuildInputs;
          buildInputs = with pkgs; [
          	openssl
          ];
          # Skip naersk's default cargo build — use dx instead
          singleStep = true;
          doCheck = false;
          checkPhase = "";
          buildPhase = ''
        	dx build --release --platform server
          '';
          installPhase = ''
        	mkdir -p $out/bin
        	cp -r ./target/dx/tao/release/web/. $out/bin/
          '';
        };

        devShell = with pkgs; mkShell {
          buildInputs = nativeBuildInputs;
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
        };
      }
    );
}
