# My personal nix configurations

## setup

### install nix
```
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon
```

### initial setup
```
nix-shell -p home-manager --run 'home-manager -f ~/nix-config/$(uname).nix switch -b backup'
```
