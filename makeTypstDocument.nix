{ lib
, stdenv
, typst
}:
{ src
, name ? "document.pdf"
, main ? "main.typ"
, typstDependencies ? [ ]
, packagesRepo ? null
, ...
}:

assert typstDependencies != [ ] -> packagesRepo != null;

# We try to use this trick to make packages available locally:
let
  typstDependencyScript = dep: ''
    mkdir -p $XDG_DATA_HOME/typst/packages/preview/${dep.name}
    ln -s ${packagesRepo}/packages/preview/${dep.name}/${dep.version} $XDG_DATA_HOME/typst/packages/preview/${dep.name}/${dep.version}
  '';
  typstDependencyScripts = lib.concatStringsSep "\n" (builtins.map typstDependencyScript typstDependencies);
in
stdenv.mkDerivation {
  inherit name src;
  buildInputs = [
    typst
  ];
  buildCommand = ''
    export XDG_DATA_HOME=$(pwd)
    ${typstDependencyScripts}
    typst compile --root $src $src/${main} $out
  '';
}
