{ lib
, stdenv
, typst
}:
{ name
, src
, main
, typstDependencies
, ...
}:
# We try to use this trick to make packages available locally:
let
  packagesRepo = builtins.fetchGit {
    url = "https://github.com/typst/packages";
    rev = "78a618a0a6f46103fcaa2673c8af3963f9d1d4e5";
  };
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
