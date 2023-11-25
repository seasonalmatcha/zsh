#!/bin/zsh

HISTFILE=~/.zsh_history
setopt appendhistory
setopt autocd extendedglob nomatch menucomplete
setopt interactive_comments
stty stop undef
zle_highlight=('paste:none')
unsetopt BEEP

autoload -Uz compinit
zstyle ':completion:*' menu select

# autocomplete with ignore case
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# change directory colors for autocomplete menu
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zmodload zsh/complist

# include hidden files
_comp_options+=(globdots)

autoload -U up-line-or-begining-search
autoload -U down-line-or-begining-search
zle -N up-line-or-begining-search
zle -N down-line-or-begining-search
autoload -Uz colors && colors
autoload -Uz add-zsh-hook

source "$ZDOTDIR/zsh-functions"

# bindkey ";5D" backward-word
# bindkey ";5C" forward-word
# bindkey "^H" backward-kill-word
# bindkey "5~" kill-word

bindkey -v
# export KEYTIMEOUT=1

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

zle-line-init() {
  # Set to insert mode immediately
  zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
  echo -ne "\e[5 q"

  # Set to normal mode immediately
  # zle -K vicmd
}
zle -N zle-line-init

function zle-clear-screen() {
  clear
  zle && zle .reset-prompt && zle -R
  zle zle-line-init
}
zle -N zle-clear-screen

bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M viins 'jk' vi-cmd-mode
bindkey -M viins '^h' vi-backward-word
bindkey -M viins '^l' vi-forward-word
bindkey -M vicmd '^l' zle-clear-screen
bindkey '^k' zle-clear-screen

zsh_add_file "zsh-aliases"
zsh_add_file "zsh-exports"

zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting"

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
else
  zsh_add_file "zsh-prompt"
fi
