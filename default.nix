{ pkgs ? import <nixpkgs> { }
}:
let
  inherit (pkgs) dash writeScriptBin writeTextDir buildEnv;
in

{ pkgs ? [ ], links ? { } }:

let
  manifest =
    let
      sortedPaths = builtins.sort (a: b: a < b) (builtins.attrNames links);
      lines = map (path: "${path} ${links.${path}}\n") sortedPaths;
    in
    writeTextDir "share/nix-ln-conf-manifest" (builtins.concatStringsSep "" lines);

  bin = writeScriptBin "nix-ln-conf" ''
    #!${dash}/bin/dash
    ${builtins.readFile ./nix-ln-conf.sh}
  '';
  #TARGET_MANIFEST_PATH="${manifest}"

  paths = pkgs ++ [ manifest bin ];

  env = buildEnv {
    inherit paths;
    name = "nix-ln-conf-env";
  };
in
env
