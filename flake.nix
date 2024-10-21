{
  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/96bf45e4c6427f9152afed99dde5dc16319ddbd6";
    flake-utils.url = "github:numtide/flake-utils/c1dfcf08411b08f6b8615f7d8971a2bfa81d5e8a";
    ocaml-overlay.url = "git+file:///Users/adam/Documents/Programming/libs/nix-overlays";
    ocaml-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ocaml-overlay,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          ocaml-overlay.overlays.default
          (final: prev: {ocamlPackages = prev.ocaml-ng.ocamlPackages_5_3;})
        ];
      };
    in rec {
      packages.default = pkgs.ocamlPackages.buildDunePackage {
        pname = "ocamlformat";
        version = "1.0.0";

        src = ./.;
        buildInputs = with pkgs.ocamlPackages; [
          csexp
          re
          base
          cmdliner
          dune-build-info
          either
          fix
          fpath
          menhir
          menhirLib
          menhirSdk
          ocaml-version
          stdio
          uuseg
          uutf
          astring
          camlp-streams
          yojson
          alcotest
          ocp-indent
          bechamel
        ];
      };
      devShells.default = pkgs.mkShell {
        inputsFrom = [packages.default];
        packages = [pkgs.alejandra pkgs.ocamlPackages.ocaml-lsp];
      };
    });
}
