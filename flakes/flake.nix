{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }: let
    system = "x86_64-linux";  # Swap it for your system if needed
                              # "aarch64-linux" / "x86_64-darwin" / "aarch64-darwin"
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {

      packages = [
        pkgs.cargo
        pkgs.rustc

        pkgs.rust-analyzer
        pkgs.rustfmt

        (pkgs.python3.withPackages (python-pkgs: [
          python-pkgs.scapy
        ]))

        pkgs.go  # Add Go to the packages list
      ];

      RUST_BACKTRACE = "1";

      shellHook = ''
        # Rust-specific shell hook
        venv="$(cd $(dirname $(which python)); cd ..; pwd)"
        ln -Tsf "$venv" .venv
        echo "Entered development environment!"

        # Go-specific shell hook to set up Go environment variables
        export GOPATH=$HOME/go
        export PATH=$PATH:$GOPATH/bin
        export GO111MODULE=on
      '';

    };
  };
}

