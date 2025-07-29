# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt append_history
setopt share_history

# Completion
autoload -Uz compinit
compinit

_git_prompt_info() {
  local branch dirty staged untracked
  local git_dir

  git_dir=$(git rev-parse --git-dir 2>/dev/null) || return

  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -z $branch ]] && branch="detached"

  # staged changes
  staged=$(git diff --cached --quiet || echo "+")
  # unstaged changes
  dirty=$(git diff --quiet || echo "!")
  # untracked files
  untracked=$(git ls-files --others --exclude-standard | grep -q . && echo "?")

  echo " ($branch $staged$dirty$untracked)"
}

# Prompt
autoload -Uz promptinit
promptinit
setopt prompt_subst
#PROMPT='[barecode@lab/%1~${vcs_info_msg_0_}]: %'
PROMPT='[barecode@lab/%1~$(_git_prompt_info)]: %'

bindkey -v

# Enable history search
bindkey -M viins '^[[A' history-beginning-search-backward
bindkey -M viins '^[[B' history-beginning-search-forward

export PATH="$HOME/.local/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"


export EDITOR="nvim"

setopt no_beep

alias p="paru"

source /usr/share/nvm/init-nvm.sh

alias x='startx'
