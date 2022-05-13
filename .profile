#!/bin/bash
export GOPATH=$HOME/.local/share/go
export PATH=$GOPATH/bin:/usr/lib/ruby/gems/3.0.0/bin:$HOME/.local/share/gem/ruby/3.0.0/bin:$HOME/.local/bin:$HOME/.scripts:/opt:$HOME/.ghcup/bin:$HOME/.nimble/bin:$HOME/.dotnet:$PATH
. "$HOME/.cargo/env"
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/gavin/.local/bin/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/gavin/.local/bin/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/gavin/.local/bin/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/gavin/.local/bin/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
if test -z "${XDG_RUNTIME_DIR}"; then
	export XDG_RUNTIME_DIR=/tmp/${UID}-runtime-dir
	if ! test -d "${XDG_RUNTIME_DIR}"; then
		mkdir "${XDG_RUNTIME_DIR}"
		chmod 0700 "${XDG_RUNTIME_DIR}"
	fi
fi
export _JAVA_AWT_WM_NONREPARENTING=1
export SDL_VIDEODRIVER=wayland
export MOZ_ENABLE_WAYLAND=1
unset DISPLAY

export GPG_TTY=$(tty)

[[ ! -r /home/gavin/.opam/opam-init/init.sh ]] || source /home/gavin/.opam/opam-init/init.sh  > /dev/null 2> /dev/null

. "$HOME/.cargo/env"
