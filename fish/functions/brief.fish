function brief
    set hour (date "+%H")
    if test $hour -lt 12
        set period "morning"
    else if test $hour -lt 17
        set period "afternoon"
    else
        set period "evening"
    end

    set datetime (date "+%A, %B %d %Y — %I:%M %p")
    set uptime_str (uptime -p 2>/dev/null | string replace 'up ' '')
    set mem_info (free -h 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2}')
    set cpu_load (cat /proc/loadavg 2>/dev/null | awk '{print $1}')
    set disk_root (df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
    set ip_addr (ip route get 1 2>/dev/null | awk 'NR==1 {for(i=1;i<=NF;i++) if ($i=="src") {print $(i+1); exit}}')
    set weather_lines
    if test (count $JARVIS_LOCATIONS) -gt 0
        for loc in $JARVIS_LOCATIONS
            set w (python3 ~/.config/fish/get_weather.py $loc 2>/dev/null)
            if test -n "$w"
                set weather_lines $weather_lines $w
            end
        end
    else
        set w (python3 ~/.config/fish/get_weather.py 2>/dev/null)
        if test -n "$w"
            set weather_lines $w
        end
    end

    set interior 60
    set sep (string repeat -n $interior "═")
    if test (date "+%u") -eq 5
        set hdr "══[ F.R.I.D.A.Y. BRIEF ]"
        set accent c084fc
    else
        set hdr "══[ J.A.R.V.I.S. BRIEF ]"
        set accent cyan
    end
    set hdr_fill (string repeat -n (math $interior - (string length $hdr)) "═")

    set_color --bold $accent
    echo ""
    echo "  ╔$hdr$hdr_fill╗"
    set_color $accent
    echo "  ║"(string pad -r -w $interior (string sub -l $interior "  Good $period. Here is your briefing."))"║"
    echo "  ║"(string pad -r -w $interior (string sub -l $interior "  $datetime"))"║"
    if test (count $weather_lines) -gt 0
        echo "  ║"(string pad -r -w $interior "")"║"
        echo "  ║"(string pad -r -w $interior "  Weather:")"║"
        for w in $weather_lines
            set parts (string split ':::' $w)
            if test (count $parts) -ge 3
                set wloc (string pad -r -w 17 (string shorten -m 17 $parts[1]))
                set wtime $parts[2]
                set wcond $parts[3]
                echo "  ║"(string pad -r -w $interior (string sub -l $interior "    $wloc  $wtime  $wcond"))"║"
            end
        end
    end
    set_color --bold $accent
    echo "  ╠$sep╣"
    set_color $accent
    echo "  ║"(string pad -r -w $interior (string sub -l $interior "  Uptime:   $uptime_str"))"║"
    echo "  ║"(string pad -r -w $interior (string sub -l $interior "  Memory:   $mem_info"))"║"
    echo "  ║"(string pad -r -w $interior (string sub -l $interior "  CPU:      $cpu_load"))"║"
    echo "  ║"(string pad -r -w $interior (string sub -l $interior "  Disk /:   $disk_root"))"║"
    if test -n "$ip_addr"
        echo "  ║"(string pad -r -w $interior (string sub -l $interior "  Network:  $ip_addr"))"║"
    end
    set_color --bold $accent
    echo "  ╚$sep╝"
    set_color normal
    echo ""
end
