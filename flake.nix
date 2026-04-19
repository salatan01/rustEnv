{
  description = "A secure, streamlined Rust development environment";

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
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        # Clean, stable toolchain with essential LSP components
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
            "clippy"
            "rustfmt"
          ];
        };

      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            rustToolchain
            pkg-config

            # ── Security & Auditing ──────────────────────────────────────────
            cargo-audit # Checks dependency tree for known vulnerabilities
            cargo-deny # Bans malicious crates and unapproved licenses

            # ── Workflow Essentials ──────────────────────────────────────────
            cargo-watch # Automates 'cargo check' on file save
            just # Simple command runner
          ];

          buildInputs = with pkgs; [
            openssl
          ];

          # ── Strict Environment Variables ───────────────────────────────────
          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          RUST_BACKTRACE = "1";

          # Force OpenSSL to use the system library to prevent build failures
          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
          OPENSSL_NO_VENDOR = "1";

          shellHook = ''
            echo "🛡️ Secure Rust environment loaded."
            echo "   Run 'cargo audit' to check dependencies."
          '';
        };

        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
