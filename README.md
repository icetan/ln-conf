# ln-conf

Simple symlink manager, maybe for your configs.

## Usage

```sh
echo > ~/.ln-conf '
$XDG_CONFIG_HOME/:$HOME/src/my-git-managed-configs/desktop/*
$XDG_CONFIG_HOME/:$HOME/src/my-git-managed-configs/editor/*
$HOME/.bashrc:$HOME/src/my-git-managed-configs/shell/bash
$HOME/.bash_profile:$HOME/.bashrc
'
ln-conf -v -n
ln-conf
```
