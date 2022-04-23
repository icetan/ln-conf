{ pkgs ? import <nixpkgs> { }
}:
let
  inherit (pkgs)
    dash envsubst coreutils gnugrep
    writeScriptBin writeTextDir;
  inherit (pkgs.lib) makeBinPath;

  ln-conf = import ./. { inherit pkgs; };

  concatManifest = import ./manifest.nix;
  paths = makeBinPath [ envsubst coreutils gnugrep ];

  bin = writeScriptBin "ln-conf" ''
    #!${dash}/bin/dash
    PATH="${paths}:$PATH"
    ${builtins.readFile ./ln-conf}
  '';

  # str -> [{ *: str }] -> drv
  mkManifest = name: links:
    writeTextDir "etc/ln-conf.d/${name}" (concatManifest links);

  # str -> [{ paths: [drv], links: { *: str }, vars: { *: str } }] -> drv
  mkEnv = name: envs:
    let
      envs' = builtins.concatMap (env: env.envs or [env]) (if builtins.isList envs then envs else [envs]);
      links = builtins.foldl' (acc: env: acc // env.links or { }) { } envs';
      varsToText = vars: map (n: n + "=" + vars.${n}) (builtins.attrNames vars);
      vars = builtins.concatMap (env: varsToText (env.vars or { })) envs';
      manifest = mkManifest name (links // {
        "$HOME/.env" = pkgs.writeText "${name}-env-vars" (builtins.concatStringsSep "\n" vars);
      });
      paths = [ manifest ]
        ++ builtins.concatMap (env: env.paths or [ ]) envs';
    in
    (pkgs.buildEnv {
      inherit name paths;
      ignoreCollisions = true;
    }) // {
      inherit manifest;
      envs = envs';
    };
in
bin // {
  inherit mkManifest mkEnv;
}
