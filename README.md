# Building Typst documents with Nix

## Using this repository

``` nix
let typstNixRepo = builtins.fetchGit {
        url = "https://github.com/NorfairKing/typst.nix";
        rev = "0000000000000000000000000000000000000000"; # Use a recent typst.nix commit
    };
    makeTypstDocument = pkgs.callPackage (typstNixRepo + "/makeTypstDocument.nix") {};
in makeTypstDocument {
    name = "presentation.pdf";
    main = "presentation.typ";
    src = ./presentation;
    packagesRepo = builtins.fetchGit {
      url = "https://github.com/typst/packages";
      rev = "0000000000000000000000000000000000000000"; # Use a recent typst packages commit
    };
    # Fill in all typst dependencies that you import in your .typ files
    typstDependencies = [
      {
        name = "polylux";
        version = "0.3.1";
      }
    ];
}
```

## `makeTypstDocument`

See [`./makeTypstDocument.nix`](./makeTypstDocument.nix)
