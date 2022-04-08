{
  description = "Simple Nix based config manager";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs, ... }: builtins.foldl' (acc: system: let
    pkgs = import nixpkgs { inherit system; };
  in
  acc // {
    packages.${system}.default = import ./. { inherit pkgs; };
  }) {} [ "x86_64-linux" ];
}
