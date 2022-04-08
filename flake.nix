{
  description = "ln-conf a simple symlink manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs, ... }:
    let
      call = system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        { default = import ./. { inherit pkgs; }; };
    in
    {
      lib.toManifest = import ./manifest.nix;
      packages = builtins.foldl'
        (acc: system: acc // { ${system} = call system; })
        { }
        [ "aarch64-darwin" "aarch64-linux" "i686-linux" "x86_64-darwin" "x86_64-linux" ];
    };
}
