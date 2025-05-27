{
  description = "typst.nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    typst-packages.url = "github:typst/packages";
    typst-packages.flake = false;
  };

  outputs =
    { self
    , nixpkgs
    , pre-commit-hooks
    , typst-packages
    }:
    let
      system = "x86_64-linux";
      overlay = final: _: {
        makeTypstDocument = final.callPackage ./makeTypstDocument.nix { defaultTypstPackagesRepo = typst-packages; };
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
          typstDependencies = [
            {
              name = "polylux";
              version = "0.4.0";
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
