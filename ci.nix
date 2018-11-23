let
  pkgs = import <nixpkgs> {};
  name = "hello-2.10";
  jobs = rec {

    tarball =
      pkgs.releaseTools.sourceTarball {
        name = "hello-tarball";
        src = pkgs.fetchurl {
          url = "mirror://gnu/hello/${name}.tar.gz";
          sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
        };
        buildInputs = (with pkgs; [ gettext texinfo ]);
      };

    build =
      { system ? builtins.currentSystem }:

      let pkgs = import <nixpkgs> { inherit system; }; in
      pkgs.releaseTools.aggregate {
        constituents = [build tarball];
        name = "${name}";
        src = pkgs.fetchurl {
          url = "mirror://gnu/hello/${name}.tar.gz";
          sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
        };
    };
  };
in
  jobs
