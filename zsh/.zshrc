# ─── Completions ──────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' rehash true

# ─── History ──────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY

# ─── Options ──────────────────────────────────────────────────────────────────
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS INTERACTIVE_COMMENTS

# ─── JARVIS / FRIDAY theme ────────────────────────────────────────────────────
if [[ $(date "+%u") -eq 5 ]]; then
    export STARSHIP_CONFIG=~/zsh/starship-friday.toml
    _J_COLOR=$'\e[38;2;192;132;252m'
    _J_BOLD=$'\e[1;38;2;192;132;252m'
    _J_NAME="F.R.I.D.A.Y."
    _J_FULL="Female Replacement Intelligent Digital Asst."
    _J_HL='fg=#c084fc,bold'
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#553366'
else
    export STARSHIP_CONFIG=~/zsh/starship.toml
    _J_COLOR=$'\e[36m'
    _J_BOLD=$'\e[1;36m'
    _J_NAME="J.A.R.V.I.S."
    _J_FULL="Just A Rather Very Intelligent System"
    _J_HL='fg=cyan,bold'
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
fi
_J_RESET=$'\e[0m'

# ─── Syntax highlighting ──────────────────────────────────────────────────────
source ~/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[command]=$_J_HL
ZSH_HIGHLIGHT_STYLES[builtin]=$_J_HL
ZSH_HIGHLIGHT_STYLES[function]=$_J_HL
ZSH_HIGHLIGHT_STYLES[alias]=$_J_HL
ZSH_HIGHLIGHT_STYLES[precommand]=$_J_HL
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[comment]='fg=8'
ZSH_HIGHLIGHT_STYLES[path]='fg=white'
ZSH_HIGHLIGHT_STYLES[assign]='fg=white'

# ─── Autosuggestions ──────────────────────────────────────────────────────────
source ~/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ─── Key bindings ─────────────────────────────────────────────────────────────
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[^[[D' backward-word

# ─── Terminal title ───────────────────────────────────────────────────────────
function _jarvis_title { print -Pn "\e]0;J.A.R.V.I.S. — %~\a" }
precmd_functions+=(_jarvis_title)

# ─── zoxide ───────────────────────────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ─── fzf ──────────────────────────────────────────────────────────────────────
source ~/.fzf/shell/key-bindings.zsh
source ~/.fzf/shell/completion.zsh
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border'
export FZF_CTRL_R_OPTS='--sort --exact'

# ─── Git aliases (from fish abbreviations) ────────────────────────────────────
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# ─── Path ─────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.fzf/bin:$PATH"

# ─── Prompt (Starship) ────────────────────────────────────────────────────────
eval "$(starship init zsh)"

# ─── Box drawing helper ───────────────────────────────────────────────────────
function _j_line {
    local w=$1; shift
    printf "  ║%-${w}s║\n" "$*"
}
function _j_sep {
    printf '═%.0s' $(seq 1 $1)
}

# ─── jarvis command ───────────────────────────────────────────────────────────
function jarvis {
    local w=54
    local sep=$(_j_sep $w)
    local hdr="══[ ${_J_NAME} DIAGNOSTICS ]"
    local fill=$(_j_sep $((w - ${#hdr})))
    local mem=$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2}')
    local cpu=$(cat /proc/loadavg 2>/dev/null | awk '{print $1 "  " $2 "  " $3}')
    local disk=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
    local ip=$(ip route get 1 2>/dev/null | awk 'NR==1 {for(i=1;i<=NF;i++) if($i=="src"){print $(i+1);exit}}')
    local up=$(uptime -p 2>/dev/null | sed 's/up //')
    echo ""
    printf "${_J_BOLD}  ╔${hdr}${fill}╗${_J_RESET}\n"
    printf "${_J_BOLD}"
    [[ -n "$up"   ]] && _j_line $w "  Uptime:   $up"
    [[ -n "$mem"  ]] && _j_line $w "  Memory:   $mem"
    [[ -n "$cpu"  ]] && _j_line $w "  CPU Load: $cpu  (1m 5m 15m)"
    [[ -n "$disk" ]] && _j_line $w "  Disk /:   $disk"
    [[ -n "$ip"   ]] && _j_line $w "  Network:  $ip"
    [[ -n "$CONDA_DEFAULT_ENV" && "$CONDA_DEFAULT_ENV" != "base" ]] && _j_line $w "  Conda:    $CONDA_DEFAULT_ENV"
    printf "${_J_BOLD}  ╚${sep}╝${_J_RESET}\n"
    echo ""
}

# ─── brief command ────────────────────────────────────────────────────────────
function brief {
    local hour=$(date "+%H")
    if   [[ $hour -lt 12 ]]; then local period="morning"
    elif [[ $hour -lt 17 ]]; then local period="afternoon"
    else                          local period="evening"; fi

    local w=60
    local sep=$(_j_sep $w)
    local hdr="══[ ${_J_NAME} BRIEF ]"
    local fill=$(_j_sep $((w - ${#hdr})))
    local dt=$(date "+%A, %B %d %Y — %I:%M %p")
    local up=$(uptime -p 2>/dev/null | sed 's/up //')
    local mem=$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2}')
    local cpu=$(cat /proc/loadavg 2>/dev/null | awk '{print $1}')
    local disk=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
    local ip=$(ip route get 1 2>/dev/null | awk 'NR==1 {for(i=1;i<=NF;i++) if($i=="src"){print $(i+1);exit}}')

    echo ""
    printf "${_J_BOLD}  ╔${hdr}${fill}╗${_J_RESET}\n"
    printf "${_J_BOLD}"
    _j_line $w "  Good ${period}. Here is your briefing."
    _j_line $w "  ${dt}"
    printf "${_J_BOLD}  ╠${sep}╣${_J_RESET}\n"
    printf "${_J_BOLD}"
    [[ -n "$up"   ]] && _j_line $w "  Uptime:   $up"
    [[ -n "$mem"  ]] && _j_line $w "  Memory:   $mem"
    [[ -n "$cpu"  ]] && _j_line $w "  CPU:      $cpu"
    [[ -n "$disk" ]] && _j_line $w "  Disk /:   $disk"
    [[ -n "$ip"   ]] && _j_line $w "  Network:  $ip"
    printf "${_J_BOLD}  ╚${sep}╝${_J_RESET}\n"
    echo ""
}

# ─── Greeting ─────────────────────────────────────────────────────────────────
function _jarvis_greeting {
    local hour=$(date "+%H")
    if   [[ $hour -lt 12 ]]; then local period="morning"
    elif [[ $hour -lt 17 ]]; then local period="afternoon"
    else                          local period="evening"; fi

    local w=60
    local sep=$(_j_sep $w)
    local hdr="══[ ${_J_NAME} ]"
    local fill=$(_j_sep $((w - ${#hdr})))
    local dt=$(date "+%A, %B %d %Y — %I:%M %p")
    local up=$(uptime -p 2>/dev/null | sed 's/up //')
    local mem=$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2}')
    local cpu=$(cat /proc/loadavg 2>/dev/null | awk '{print $1}')

    if [[ $(date "+%u") -eq 5 ]]; then
        local msgs=("All systems green." "Ready when you are." "Standing by." "Online and operational." "Good to go." "At your service." "Systems clear.")
    else
        local msgs=("All systems operational." "Running at peak efficiency." "No anomalies detected." "Diagnostics complete. All clear." "Systems nominal. Standing by.")
    fi
    local msg=${msgs[$RANDOM % ${#msgs[@]} + 1]}

    echo ""
    printf "${_J_BOLD}  ╔${hdr}${fill}╗${_J_RESET}\n"
    printf "${_J_BOLD}  ║$(printf "%-${w}s" "  ${_J_FULL}")║${_J_RESET}\n"
    printf "${_J_BOLD}  ╠${sep}╣${_J_RESET}\n"
    printf "${_J_BOLD}  ║$(printf "%-${w}s" "  Good ${period}, $(whoami).")║${_J_RESET}\n"
    printf "${_J_BOLD}  ║$(printf "%-${w}s" "  ${dt}")║${_J_RESET}\n"
    [[ -n "$up"  ]] && printf "${_J_BOLD}  ║$(printf "%-${w}s" "  Uptime: ${up}")║${_J_RESET}\n"
    [[ -n "$mem" && -n "$cpu" ]] && printf "${_J_BOLD}  ║$(printf "%-${w}s" "  Memory: ${mem}   CPU: ${cpu}")║${_J_RESET}\n"
    printf "${_J_BOLD}  ╠${sep}╣${_J_RESET}\n"
    printf "${_J_BOLD}  ║$(printf "%-${w}s" "  ◈ ${msg}")║${_J_RESET}\n"
    printf "${_J_BOLD}  ╚${sep}╝${_J_RESET}\n"
    echo ""
}
_jarvis_greeting

# ─── conda ────────────────────────────────────────────────────────────────────
if [[ -f "$HOME/miniconda3/bin/conda" ]]; then
    __conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.zsh' 'hook' 2>/dev/null)"
    [[ $? -eq 0 ]] && eval "$__conda_setup" || export PATH="$HOME/miniconda3/bin:$PATH"
    unset __conda_setup
fi
