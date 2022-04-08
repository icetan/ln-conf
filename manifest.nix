links:
let
  paths = builtins.sort (a: b: a < b) (builtins.attrNames links);
  lines = map (path: path + ":" + links.${path}) paths;
in
builtins.concatStringsSep "\n" lines
