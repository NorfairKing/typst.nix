{
  description = "typst.nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs =
    { self
    , nixpkgs
    , pre-commit-hooks
    }:
    let
      system = "x86_64-linux";
      overlay = final: _: {
        makeTypstDocument = final.callPackage ./makeTypstDocument.nix { };
      };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      };
    in
    {
      overlays.${system} = overlay;
      checks.${system} = {
        example = pkgs.makeTypstDocument {
          name = "example.pdf";
          main = "example.typ";
          src = ./example;
          packagesRepo = builtins.fetchGit {
            url = "https://github.com/typst/packages";
            rev = "78a618a0a6f46103fcaa2673c8af3963f9d1d4e5";
          };
          typstDependencies = [
            {
              name = "polylux";
              version = "0.3.1";
            }
          ];
        };
        shell = self.devShells.${system}.default;
        pre-commit = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            deadnix.enable = true;
          };
        };
      };
      devShells.${system}.default = pkgs.mkShell {
        name = "typst.vim-shell";
        buildInputs = (with pkgs; [
          typst
          jsonfmt
        ]) ++ (with pre-commit-hooks.packages.${system};
          [
            nixpkgs-fmt
            deadnix
          ]);
        shellHook = self.checks.${system}.pre-commit.shellHook;
      };
    };
}
