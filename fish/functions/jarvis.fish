function jarvis
    set mem_info (free -h 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2}')
    set cpu_load (cat /proc/loadavg 2>/dev/null | awk '{print $1 "  " $2 "  " $3}')
    set disk_root (df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
    set ip_addr (ip route get 1 2>/dev/null | awk 'NR==1 {for(i=1;i<=NF;i++) if ($i=="src") {print $(i+1); exit}}')
    set uptime_str (uptime -p 2>/dev/null | string replace 'up ' '')

    set interior 54
    set sep (string repeat -n $interior "═")
    set hdr "══[ J.A.R.V.I.S. DIAGNOSTICS ]"
    set hdr_fill (string repeat -n (math $interior - (string length $hdr)) "═")

    set_color --bold cyan
    echo ""
    echo "  ╔$hdr$hdr_fill╗"
    set_color cyan

    if test -n "$uptime_str"
        echo "  ║"(string pad -r -w $interior "  Uptime:   $uptime_str")"║"
    end
    if test -n "$mem_info"
        echo "  ║"(string pad -r -w $interior "  Memory:   $mem_info")"║"
    end
    if test -n "$cpu_load"
        echo "  ║"(string pad -r -w $interior "  CPU Load: $cpu_load  (1m 5m 15m)")"║"
    end
    if test -n "$disk_root"
        echo "  ║"(string pad -r -w $interior "  Disk /:   $disk_root")"║"
    end
    if test -n "$ip_addr"
        echo "  ║"(string pad -r -w $interior "  Network:  $ip_addr")"║"
    end
    if test -n "$CONDA_DEFAULT_ENV" -a "$CONDA_DEFAULT_ENV" != "base"
        echo "  ║"(string pad -r -w $interior "  Conda:    $CONDA_DEFAULT_ENV")"║"
    end

    set_color --bold cyan
    echo "  ╚$sep╝"
    set_color normal
    echo ""
end
