export EDITOR="emacsclient -c"
export VISUAL="emacsclient -c"
export SYSTEMD_EDITOR="emacsclient -c"
export PAGES=bat
export TERMINAL=kitty
export BROWSER="flatpak run org.mozilla.firefox"
# export BROWSER=brave
export GOPATH=$HOME/Projects/golang
export GOBIN=$HOME/Projects/golang/bin
export SHELL=/usr/bin/fish
export NPM_PACKAGES="$HOME/.npm-packages"
export MANPATH=$MANPATH:$NPM_PACKAGES/share/man
export PIPBIN="$HOME/.local/bin"
export PATH=$PATH:${GOBIN}:${NPM_PACKAGES}/bin:${PIPBIN}
export PKGEXT=.pkg.tar
