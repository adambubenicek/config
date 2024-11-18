[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

PS1=''
if [[ -n $SSH_TTY ]]; then
  PS1+='\[\e[33m\]\h\[\e[0m\] '
fi
PS1+='\[\e[2m\]\w\[\e[0m\] '
PS1+='\[\e[34;1m\]> \[\e[0m\]'

export VISUAL=nvim
export EDITOR=nvim