# Stacky

An interactive pulumi stack selector that remembers the selected stack and working dir

Usage

```sh
# select a stack
stacky select
# use stacky instead of pulumi
stacky stack output
```

## Installing

### Prerequisites

Requires dialog utility

```sh
# Mac
brew install dialog
```

### Fish shell

Copy stacky.fish to ~/.config/fish/functions/

### Other shells

You can't run the script normally (e.g. in a subshell) because that prevents the environment vars from being set in the parent shell. So it must be sourced instead.

1. Copy stacky.sh somewhere (e.g. ~/bin/stacky)
2. Add an alias to your .bashrc or .zshrc

```sh
# Alias
alias stacky='source ~/bin/stacky.sh'
```
