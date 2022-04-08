#!/bin/sh
set -e

TARGET_MANIFEST_PATH=${TARGET_MANIFEST_PATH-$HOME/.nix-profile/share/nix-ln-conf-manifest}
TARGET_MANIFEST=${1-$(cat "$TARGET_MANIFEST_PATH")}
CURRENT_MANIFEST_PATH="$HOME/.nix-ln-conf-manifest"
CURRENT_MANIFEST=$(cat "$CURRENT_MANIFEST_PATH" 2>/dev/null || true)

#[ -n "$TARGET_MANIFEST" ] || echo >&2 "ERROR: empty target manifest"
#[ -n "$CURRENT_MANIFEST" ] || echo >&2 "INFO: won't link, $1 already matches target manifest"

_manifest=$TARGET_MANIFEST
_errs=""
_torm=""
_toln=""

_link() {
  if [ -e "$1" ] || [ -L "$1" ]; then
    if [ -L "$1" ] && [ "$(readlink "$1")" = "$2" ]; then
      echo >&2 "INFO: won't link, $1 already matches target manifest"
    else
      _errs="${_errs}can't link, file already exists at $1
"
    fi
  else
    echo >&2 "INFO: will link $1 -> $2"
    _toln="${_toln}$1 $2
"
  fi
}

_unlink() {
  if [ -e "$1" ] || [ -L "$1" ]; then
    if [ -L "$1" ] && [ "$(readlink "$1")" = "$2" ]; then
      if echo "$_manifest" | grep -q "^$line$"; then
        echo >&2 "INFO: won't unlink $1 -> $2, it exists and is in target manifest"
        _manifest=$(echo "$_manifest" | grep -v "^$line$") || true
      else
        echo >&2 "INFO: will unlink $1 -> $2, matches old manifest"
        _torm="${_torm}$1
"
      fi
    else
      _errs="${_errs}can't unlink, file doesn't match old manifest at $1
"
    fi
  else
    echo >&2 "INFO: won't unlink, file $1 doesn't exist"
  fi
}

[ -z "$CURRENT_MANIFEST" ] || while read -r line; do
  _unlink $line
done <<EOF
$CURRENT_MANIFEST
EOF

[ -z "$_manifest" ] || while read -r line; do
  _link $line
done <<EOF
$_manifest
EOF

if [ -n "$_errs" ]; then
  while read -r line; do
    [ -z "$line" ] || echo >&2 ERROR: $line
  done <<EOF
$_errs
EOF
  echo >&2 "Failed!"
  exit 1
fi

[ -z "$_torm" ] || while read -r line; do
  [ -z "$line" ] || rm "$line"
done <<EOF
$_torm
EOF

[ -z "$_toln" ] || while read -r line; do
  if [ -n "$line" ]; then
    set $line
    mkdir -p $(dirname $1)
    ln -sT "$2" "$1"
  fi
done <<EOF
$_toln
EOF

echo "$CURRENT_MANIFEST" > "$CURRENT_MANIFEST_PATH-$(date +%s)"
echo "$TARGET_MANIFEST" > "$CURRENT_MANIFEST_PATH"
echo >&2 "Success!"
