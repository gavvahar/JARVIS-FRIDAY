# ~/.bashrc

# ── Only run in interactive shells ────────────────────────────────────────────
case $- in
    *i*) ;;
      *) return;;
esac

# ── ble.sh — must load before everything else ────────────────────────────────
[[ -f ~/.local/share/blesh/ble.sh ]] && source ~/.local/share/blesh/ble.sh --noattach

# ── Config directory (where this repo is installed) ───────────────────────────
_BASH_TERMINAL_DIR="$HOME/.config/bash-terminal"

# ── OS detection ─────────────────────────────────────────────────────────────
case "$(uname -s)" in
    Darwin*)  _JARVIS_OS="mac"     ;;
    MINGW*|MSYS*|CYGWIN*) _JARVIS_OS="windows" ;;
    *)        _JARVIS_OS="linux"   ;;
esac

# ── Locale: ensure UTF-8 so printf pads by character width, not bytes ────────
case "${LC_ALL:-${LC_CTYPE:-$LANG}}" in
    *UTF-8*|*utf8*|*utf-8*) ;;
    *) export LC_CTYPE=C.UTF-8 ;;
esac
export PYTHONUTF8=1  # Windows defaults to cp1252; force UTF-8 for all python3 calls

# ── History ───────────────────────────────────────────────────────────────────
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=10000
HISTFILESIZE=20000

shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
[[ ":$PATH:" != *":$HOME/.fzf/bin:"* ]] && [ -d "$HOME/.fzf/bin" ] && export PATH="$HOME/.fzf/bin:$PATH"
if [[ "$_JARVIS_OS" == "mac" ]]; then
    [ -d "/opt/homebrew/bin" ] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]] && export PATH="/opt/homebrew/bin:$PATH"
    [ -d "/usr/local/bin"    ] && [[ ":$PATH:" != *":/usr/local/bin:"*    ]] && export PATH="/usr/local/bin:$PATH"
fi

# ── System info helpers (OS-aware) ───────────────────────────────────────────
_sys_uptime() {
    case "$_JARVIS_OS" in
        mac)
            uptime 2>/dev/null \
                | sed 's/.*up //' \
                | sed 's/,[[:space:]]*[0-9]*[[:space:]]*users\{0,1\}.*//' \
                | sed 's/^[[:space:]]*//'
            ;;
        windows)
            uptime 2>/dev/null | sed 's/^up //' || true ;;
        *)
            uptime -p 2>/dev/null | sed 's/^up //' ;;
    esac
}

_sys_mem() {
    case "$_JARVIS_OS" in
        mac)
            python3 -c "
import subprocess, re
vm = subprocess.run(['vm_stat'], capture_output=True, text=True).stdout
p  = int(re.search(r'page size of (\d+)', vm).group(1))
g  = lambda k: int(re.search(k + r':\s+(\d+)', vm).group(1)) * p
u  = g('Pages active') + g('Pages wired down')
try: u += g('Pages occupied by compressor')
except: pass
t = int(subprocess.run(['sysctl','-n','hw.memsize'], capture_output=True, text=True).stdout)
h = lambda b: f'{b/1073741824:.1f}Gi' if b >= 1073741824 else f'{b/1048576:.0f}Mi'
print(h(u) + '/' + h(t))
" 2>/dev/null ;;
        windows)
            wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Value 2>/dev/null \
                | awk -F= 'BEGIN{t=0;f=0} /TotalVisible/{t=$2+0} /FreePhysical/{f=$2+0}
                           END{if(t>0) printf "%.0fMi/%.0fMi\n",(t-f)/1024,t/1024}' || true ;;
        *)
            free -h 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2}' ;;
    esac
}

_sys_cpu1() {
    case "$_JARVIS_OS" in
        mac)     sysctl -n vm.loadavg 2>/dev/null | awk '{print $2}' ;;
        windows) true ;;
        *)       awk '{print $1}' /proc/loadavg 2>/dev/null ;;
    esac
}

_sys_cpu3() {
    case "$_JARVIS_OS" in
        mac)     sysctl -n vm.loadavg 2>/dev/null | awk '{print $2 "  " $3 "  " $4}' ;;
        windows) true ;;
        *)       awk '{print $1 "  " $2 "  " $3}' /proc/loadavg 2>/dev/null ;;
    esac
}

_sys_container() {
    if command -v systemd-detect-virt &>/dev/null; then
        local virt
        virt=$(systemd-detect-virt --container 2>/dev/null)
        [ "$virt" != "none" ] && [ -n "$virt" ] && echo "$virt"
    elif [ -f "/.dockerenv" ]; then
        echo "docker"
    elif [ -f "/run/host/container-manager" ]; then
        cat /run/host/container-manager 2>/dev/null
    fi
}

_box_width() {
    local cols="${COLUMNS:-80}"
    local w=$(( cols - 4 ))
    [ "$w" -gt 60 ] && w=60  # match fish config default
    [ "$w" -lt 40 ] && w=40
    echo "$w"
}

_brow() {
    # Unicode-aware padding: outputs $1 padded to exactly $2 display columns.
    # Delegates to Python str.ljust() to avoid byte-vs-char ambiguity across
    # platforms (Git Bash printf is display-width aware; Linux is byte-aware).
    local text="$1" width="$2"
    BROW_T="$text" BROW_W="$width" python3 -c \
        "import os; t=os.environ['BROW_T']; print(t.ljust(int(os.environ['BROW_W'])), end='')" \
        2>/dev/null \
        || printf "%-${width}s" "$text"
}

_sys_ip() {
    case "$_JARVIS_OS" in
        mac)
            local iface
            iface=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')
            [ -n "$iface" ] && ipconfig getifaddr "$iface" 2>/dev/null ;;
        windows)
            ip route get 1 2>/dev/null \
                | awk 'NR==1{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}' \
            || python3 -c "
import socket
s = socket.socket()
s.connect(('8.8.8.8', 80))
print(s.getsockname()[0])
s.close()
" 2>/dev/null || true ;;
        *)
            ip route get 1 2>/dev/null \
                | awk 'NR==1{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}' ;;
    esac
}

# ── AI theme — FRIDAY on Fridays, JARVIS all other days ──────────────────────
if [ "$(date +%u)" -eq 5 ]; then
    export JARVIS_MODE="FRIDAY"
    export STARSHIP_CONFIG="$_BASH_TERMINAL_DIR/starship-friday.toml"
    _AI_BOLD=$'\e[1;38;2;192;132;252m'
    _AI_NORM=$'\e[38;2;192;132;252m'
else
    export JARVIS_MODE="JARVIS"
    export STARSHIP_CONFIG="$_BASH_TERMINAL_DIR/starship.toml"
    _AI_BOLD=$'\e[1;36m'
    _AI_NORM=$'\e[36m'
fi
_AI_RESET=$'\e[0m'

# ── Color support for ls / grep ───────────────────────────────────────────────
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
elif [[ "$_JARVIS_OS" == "mac" ]]; then
    alias ls='ls -G'
    alias grep='grep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# ── Git aliases ───────────────────────────────────────────────────────────────
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# ── Bitwarden SSH agent (optional) ───────────────────────────────────────────
if [ -S "$HOME/.bitwarden-ssh-agent.sock" ]; then
    export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
fi

# ── Bash completion ───────────────────────────────────────────────────────────
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    elif [[ "$_JARVIS_OS" == "mac" ]] && [ -f "/opt/homebrew/etc/profile.d/bash_completion.sh" ]; then
        . "/opt/homebrew/etc/profile.d/bash_completion.sh"
    fi
fi

# ── fzf ───────────────────────────────────────────────────────────────────────
if [[ ${BLE_VERSION-} ]]; then
    ble-import -d integration/fzf-completion
    ble-import -d integration/fzf-key-bindings
else
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
fi

# ── History prefix search (case-insensitive, cycles with Up/Down) ─────────────
# Used when ble.sh is unavailable (e.g. Git Bash on Windows).
if [[ -z "${BLE_VERSION-}" ]]; then
    _hist_pos=0
    _hist_pfx=""

    __hist_bk() {
        # If the line no longer starts with our saved prefix, user edited it — reset
        if (( _hist_pos > 0 )) && [[ "${READLINE_LINE,,}" != "${_hist_pfx,,}"* ]]; then
            _hist_pos=0
        fi
        (( _hist_pos == 0 )) && _hist_pfx="${READLINE_LINE:0:$READLINE_POINT}"
        (( _hist_pos++ ))
        local esc match
        esc=$(printf '%s' "$_hist_pfx" | sed 's/[[\.*^$()+?{}|]/\\&/g')
        match=$(history | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' \
                        | grep -i "^$esc" | tac | sed -n "${_hist_pos}p")
        if [[ -n "$match" ]]; then
            READLINE_LINE="$match"
            READLINE_POINT=${#READLINE_LINE}
        else
            (( _hist_pos-- ))
        fi
    }

    __hist_fw() {
        (( _hist_pos <= 0 )) && return
        (( _hist_pos-- ))
        if (( _hist_pos == 0 )); then
            READLINE_LINE="$_hist_pfx"
            READLINE_POINT=${#READLINE_LINE}
            return
        fi
        local esc match
        esc=$(printf '%s' "$_hist_pfx" | sed 's/[[\.*^$()+?{}|]/\\&/g')
        match=$(history | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' \
                        | grep -i "^$esc" | tac | sed -n "${_hist_pos}p")
        if [[ -n "$match" ]]; then
            READLINE_LINE="$match"
            READLINE_POINT=${#READLINE_LINE}
        fi
    }

    bind -x '"\e[A": __hist_bk'
    bind -x '"\e[B": __hist_fw'
fi

# ── Starship prompt ───────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# ── Terminal title ────────────────────────────────────────────────────────────
_jarvis_set_title() {
    if [ "$JARVIS_MODE" = "FRIDAY" ]; then
        printf '\033]0;F.R.I.D.A.Y. — %s\007' "$(basename "$PWD")"
    else
        printf '\033]0;J.A.R.V.I.S. — %s\007' "$(basename "$PWD")"
    fi
}
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_jarvis_set_title"

# ── Zoxide ────────────────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi

# ── Greeting ──────────────────────────────────────────────────────────────────
_jarvis_greeting() {
    command -v python3 &>/dev/null || return

    local hour period
    hour=$(date +%H)
    if   [ "$hour" -lt 12 ]; then period="morning"
    elif [ "$hour" -lt 17 ]; then period="afternoon"
    else                           period="evening"
    fi
    local datetime uptime_str mem_info cpu_load container
    datetime=$(date "+%A, %B %d %Y — %I:%M %p")
    uptime_str=$(_sys_uptime)
    mem_info=$(_sys_mem)
    cpu_load=$(_sys_cpu1)
    container=$(_sys_container)

    local interior
    interior=$(_box_width)
    local sep hdr hdr_len hdr_fill
    sep=$(python3 -c "print('═' * $interior, end='')")

    local b="$_AI_BOLD" n="$_AI_NORM" r="$_AI_RESET"

    if [ "$JARVIS_MODE" = "FRIDAY" ]; then
        local msgs=("All systems green." "Ready when you are." "Standing by."
                    "Online and operational." "Good to go." "At your service." "Systems clear.")
        local status_msg="${msgs[$RANDOM % ${#msgs[@]}]}"
        hdr="══[ F.R.I.D.A.Y. ]"
        hdr_len=$(python3 -c "print(len('$hdr'))")
        hdr_fill=$(python3 -c "print('═' * ($interior - $hdr_len), end='')")

        printf "${b}\n  ╔%s%s╗\n" "$hdr" "$hdr_fill"
        printf "  ║${r}${n}%s${b}║\n" "$(_brow "  Female Replacement Intelligent Digital Asst." "$interior")"
        printf "  ╠%s╣\n${r}${n}" "$sep"
        printf "  ║%s${b}║\n${r}${n}" "$(_brow "  Hey, $(whoami). Good $period." "$interior")"
        printf "  ║%s${b}║\n${r}${n}" "$(_brow "  $datetime" "$interior")"
        [ -n "$uptime_str" ] && printf "  ║%s${b}║\n${r}${n}" "$(_brow "  Uptime: $uptime_str" "$interior")"
        [ -n "$mem_info" ]   && printf "  ║%s${b}║\n${r}${n}" "$(_brow "  Memory: $mem_info   CPU: $cpu_load" "$interior")"
        [ -n "$container" ]  && printf "  ║%s${b}║\n" "$(_brow "  Container: $container" "$interior")"
        printf "${b}  ╠%s╣\n" "$sep"
        printf "  ║${r}${n}%s${b}║\n" "$(_brow "  ◈ $status_msg" "$interior")"
        printf "  ╚%s╝${r}\n\n" "$sep"
    else
        local msgs=("All systems operational." "Running at peak efficiency."
                    "No anomalies detected." "Diagnostics complete. All clear."
                    "Systems nominal. Standing by.")
        local status_msg="${msgs[$RANDOM % ${#msgs[@]}]}"
        hdr="══[ J.A.R.V.I.S. ]"
        hdr_len=$(python3 -c "print(len('$hdr'))")
        hdr_fill=$(python3 -c "print('═' * ($interior - $hdr_len), end='')")

        printf "${b}\n  ╔%s%s╗\n" "$hdr" "$hdr_fill"
        printf "  ║${r}${n}%s${b}║\n" "$(_brow "  Just A Rather Very Intelligent System" "$interior")"
        printf "  ╠%s╣\n${r}${n}" "$sep"
        printf "  ║%s${b}║\n${r}${n}" "$(_brow "  Good $period, $(whoami)." "$interior")"
        printf "  ║%s${b}║\n${r}${n}" "$(_brow "  $datetime" "$interior")"
        [ -n "$uptime_str" ] && printf "  ║%s${b}║\n${r}${n}" "$(_brow "  Uptime: $uptime_str" "$interior")"
        [ -n "$mem_info" ]   && printf "  ║%s${b}║\n${r}${n}" "$(_brow "  Memory: $mem_info   CPU: $cpu_load" "$interior")"
        [ -n "$container" ]  && printf "  ║%s${b}║\n" "$(_brow "  Container: $container" "$interior")"
        printf "${b}  ╠%s╣\n" "$sep"
        printf "  ║${r}${n}%s${b}║\n" "$(_brow "  ◈ $status_msg" "$interior")"
        printf "  ╚%s╝${r}\n\n" "$sep"
    fi
}
_jarvis_greeting

# ── jarvis: system diagnostics ────────────────────────────────────────────────
jarvis() {
    command -v python3 &>/dev/null || { echo "python3 required for jarvis"; return 1; }

    local mem_info cpu_load disk_root ip_addr uptime_str
    mem_info=$(_sys_mem)
    cpu_load=$(_sys_cpu3)
    disk_root=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
    ip_addr=$(_sys_ip)
    uptime_str=$(_sys_uptime)

    local interior
    interior=$(_box_width)
    local sep hdr hdr_len hdr_fill
    sep=$(python3 -c "print('═' * $interior, end='')")
    hdr="══[ J.A.R.V.I.S. DIAGNOSTICS ]"
    hdr_len=$(python3 -c "print(len('$hdr'))")
    hdr_fill=$(python3 -c "print('═' * ($interior - $hdr_len), end='')")

    local b="$_AI_BOLD" n="$_AI_NORM" r="$_AI_RESET"

    printf "${b}\n  ╔%s%s╗\n${r}${n}" "$hdr" "$hdr_fill"
    [ -n "$uptime_str" ] && printf "  ║%s${b}║${r}${n}\n" "$(_brow "  Uptime:   $uptime_str" "$interior")"
    [ -n "$mem_info" ]   && printf "  ║%s${b}║${r}${n}\n" "$(_brow "  Memory:   $mem_info" "$interior")"
    [ -n "$cpu_load" ]   && printf "  ║%s${b}║${r}${n}\n" "$(_brow "  CPU Load: $cpu_load  (1m 5m 15m)" "$interior")"
    [ -n "$disk_root" ]  && printf "  ║%s${b}║${r}${n}\n" "$(_brow "  Disk /:   $disk_root" "$interior")"
    [ -n "$ip_addr" ]    && printf "  ║%s${b}║${r}${n}\n" "$(_brow "  Network:  $ip_addr" "$interior")"
    local container
    container=$(_sys_container)
    [ -n "$container" ] && printf "  ║%s${b}║${r}${n}\n" "$(_brow "  Container: $container" "$interior")"
    if [ -n "$CONDA_DEFAULT_ENV" ] && [ "$CONDA_DEFAULT_ENV" != "base" ]; then
        printf "  ║%s${b}║${r}${n}\n" "$(_brow "  Conda:    $CONDA_DEFAULT_ENV" "$interior")"
    fi
    printf "${b}  ╚%s╝${r}\n\n" "$sep"
}

# ── brief: morning briefing with weather ─────────────────────────────────────
brief() {
    command -v python3 &>/dev/null || { echo "python3 required for brief"; return 1; }

    local hour period
    hour=$(date +%H)
    if   [ "$hour" -lt 12 ]; then period="morning"
    elif [ "$hour" -lt 17 ]; then period="afternoon"
    else                           period="evening"
    fi
    local datetime uptime_str mem_info cpu_load disk_root ip_addr
    datetime=$(date "+%A, %B %d %Y — %I:%M %p")
    uptime_str=$(_sys_uptime)
    mem_info=$(_sys_mem)
    cpu_load=$(_sys_cpu1)
    disk_root=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
    ip_addr=$(_sys_ip)

    local weather_lines=()
    local loc_file="$HOME/.config/bash/jarvis_locations"
    if [ -f "$_BASH_TERMINAL_DIR/get_weather.py" ]; then
        if [ -f "$loc_file" ] && [ -s "$loc_file" ]; then
            while IFS= read -r loc; do
                [ -z "$loc" ] && continue
                local w
                w=$(python3 "$_BASH_TERMINAL_DIR/get_weather.py" "$loc" 2>/dev/null)
                [ -n "$w" ] && weather_lines+=("$w")
            done < "$loc_file"
        else
            local w
            w=$(python3 "$_BASH_TERMINAL_DIR/get_weather.py" 2>/dev/null)
            [ -n "$w" ] && weather_lines+=("$w")
        fi
    fi

    local interior
    interior=$(_box_width)
    local sep hdr hdr_len hdr_fill
    sep=$(python3 -c "print('═' * $interior, end='')")
    if [ "$JARVIS_MODE" = "FRIDAY" ]; then
        hdr="══[ F.R.I.D.A.Y. BRIEF ]"
    else
        hdr="══[ J.A.R.V.I.S. BRIEF ]"
    fi
    hdr_len=$(python3 -c "print(len('$hdr'))")
    hdr_fill=$(python3 -c "print('═' * ($interior - $hdr_len), end='')")

    local b="$_AI_BOLD" n="$_AI_NORM" r="$_AI_RESET"

    printf "${b}\n  ╔%s%s╗\n${r}${n}" "$hdr" "$hdr_fill"
    printf "  ║%s${b}║\n${r}${n}" "$(_brow "  Good $period. Here is your briefing." "$interior")"
    printf "  ║%s${b}║\n${r}${n}" "$(_brow "  $datetime" "$interior")"

    if [ "${#weather_lines[@]}" -gt 0 ]; then
        printf "  ║%s${b}║\n${r}${n}" "$(_brow "" "$interior")"
        printf "  ║%s${b}║\n${r}${n}" "$(_brow "  Weather:" "$interior")"
        for w in "${weather_lines[@]}"; do
            local wloc wtime wcond
            wloc=$(echo "$w" | awk -F':::' '{printf "%-17.17s", $1}')
            wtime=$(echo "$w" | awk -F':::' '{print $2}')
            wcond=$(echo "$w" | awk -F':::' '{print $3}')
            printf "  ║%s${b}║\n${r}${n}" "$(_brow "    $wloc  $wtime  $wcond" "$interior")"
        done
    fi

    printf "${b}  ╠%s╣\n${r}${n}" "$sep"
    printf "  ║%s${b}║\n${r}${n}" "$(_brow "  Uptime:   $uptime_str" "$interior")"
    printf "  ║%s${b}║\n${r}${n}" "$(_brow "  Memory:   $mem_info" "$interior")"
    printf "  ║%s${b}║\n${r}${n}" "$(_brow "  CPU:      $cpu_load" "$interior")"
    printf "  ║%s${b}║\n${r}${n}" "$(_brow "  Disk /:   $disk_root" "$interior")"
    [ -n "$ip_addr" ] && printf "  ║%s${b}║\n${r}${n}" "$(_brow "  Network:  $ip_addr" "$interior")"
    printf "${b}  ╚%s╝${r}\n\n" "$sep"
}

# ── jarvis-locate: manage weather locations ───────────────────────────────────
_JARVIS_LOC_FILE="$HOME/.config/bash/jarvis_locations"

jarvis-locate() {
    local sub="${1:-list}"

    case "$sub" in
        list|"")
            if [ ! -f "$_JARVIS_LOC_FILE" ] || [ ! -s "$_JARVIS_LOC_FILE" ]; then
                printf "${_AI_NORM}  ◈ ${_AI_RESET}No locations set — using IP detection.\n"
            else
                printf "${_AI_BOLD}  Monitored locations:${_AI_RESET}\n"
                local i=1
                while IFS= read -r loc; do
                    [ -z "$loc" ] && continue
                    printf "${_AI_NORM}  %s. ${_AI_RESET}%s\n" "$i" "$loc"
                    ((i++))
                done < "$_JARVIS_LOC_FILE"
            fi
            ;;
        add)
            local loc="${*:2}"
            if [ -z "$loc" ]; then
                echo 'Usage: jarvis-locate add "City, State"'
                return 1
            fi
            mkdir -p "$(dirname "$_JARVIS_LOC_FILE")"
            echo "$loc" >> "$_JARVIS_LOC_FILE"
            printf "${_AI_NORM}  ◈ ${_AI_RESET}Added: %s\n" "$loc"
            ;;
        remove)
            local loc="${*:2}"
            if [ -f "$_JARVIS_LOC_FILE" ]; then
                local tmp
                tmp=$(grep -vxF "$loc" "$_JARVIS_LOC_FILE")
                printf '%s\n' "$tmp" > "$_JARVIS_LOC_FILE"
            fi
            printf "${_AI_NORM}  ◈ ${_AI_RESET}Removed: %s\n" "$loc"
            ;;
        clear)
            > "$_JARVIS_LOC_FILE"
            printf "${_AI_NORM}  ◈ ${_AI_RESET}All locations cleared. Falling back to IP detection.\n"
            ;;
        *)
            echo "Usage:"
            echo "  jarvis-locate                       — show monitored locations"
            echo '  jarvis-locate add "City, State"     — add a location'
            echo '  jarvis-locate remove "City, State"  — remove a location'
            echo "  jarvis-locate clear                 — clear all locations"
            ;;
    esac
}

# ── ble.sh attach — must be last ─────────────────────────────────────────────
if [[ ${BLE_VERSION-} ]]; then
    bleopt complete_auto_complete=1
    ble-face -s auto_complete fg=242
    ble-attach
fi

# ── conda initialize (optional) ───────────────────────────────────────────────
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
        _CONDA_BIN=""
        for _p in "$HOME/miniconda3" "/c/ProgramData/miniconda3" "$HOME/AppData/Local/miniconda3"; do
            [[ -x "$_p/Scripts/conda" ]] && _CONDA_BIN="$_p/Scripts/conda" && break
        done
        unset _p ;;
    *)
        _CONDA_BIN="$HOME/miniconda3/bin/conda" ;;
esac
if command -v conda &>/dev/null || [ -x "$_CONDA_BIN" ]; then
    __conda_setup="$("$_CONDA_BIN" 'shell.bash' 'hook' 2>/dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
    unset __conda_setup
fi
unset _CONDA_BIN
