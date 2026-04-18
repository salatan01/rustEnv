{
  description = "nk rust env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        # Define the exact toolchain you want to use.
        # You can change `stable` to `nightly` or a specific version like `"1.75.0"`.
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
            "clippy"
          ];
          # Uncomment and add targets if you are cross-compiling or building for WebAssembly
          # targets = [ "wasm32-unknown-unknown" ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          # nativeBuildInputs is usually for build-time tools (pkg-config, compilers)
          nativeBuildInputs = with pkgs; [
            rustToolchain
            pkg-config
          ];

          # buildInputs is for runtime dependencies (C libraries your Rust code links against)
          buildInputs = with pkgs; [
            openssl
            # Add other common C dependencies your project might need here:
            # sqlite
            # wayland
            # libxkbcommon
          ];

          # Environment variables required by the environment
          # RUST_SRC_PATH is strictly required for rust-analyzer to work cleanly on NixOS
          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";

          shellHook = ''
            echo "🦀 Welcome to your Rust development environment!"
            cargo --version
          '';
        };
      }
    );
}
