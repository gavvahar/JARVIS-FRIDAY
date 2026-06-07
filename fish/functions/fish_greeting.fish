function fish_greeting
    set hour (date "+%H")
    set is_friday (test (date "+%u") -eq 5; and echo 1; or echo 0)

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

    set interior 60
    set sep (string repeat -n $interior "═")

    if test $is_friday -eq 1
        set messages \
            "All systems green." \
            "Ready when you are." \
            "Standing by." \
            "Online and operational." \
            "Good to go." \
            "At your service." \
            "Systems clear."
        set status_msg $messages[(random 1 (count $messages))]
        set hdr "══[ F.R.I.D.A.Y. ]"
        set hdr_fill (string repeat -n (math $interior - (string length $hdr)) "═")

        set_color --bold c084fc
        echo ""
        echo "  ╔$hdr$hdr_fill╗"
        echo "  ║"(string pad -r -w $interior (string sub -l $interior "  Female Replacement Intelligent Digital Asst."))"║"
        echo "  ╠$sep╣"
        set_color normal
        set_color --bold c084fc
        echo "  ║"(string pad -r -w $interior (string sub -l $interior "  Hey, "(whoami)". Good $period."))"║"
        echo "  ║"(string pad -r -w $interior (string sub -l $interior "  $datetime"))"║"
        if test -n "$uptime_str"
            echo "  ║"(string pad -r -w $interior (string sub -l $interior "  Uptime: $uptime_str"))"║"
        end
        if test -n "$mem_info" -a -n "$cpu_load"
            echo "  ║"(string pad -r -w $interior (string sub -l $interior "  Memory: $mem_info   CPU: $cpu_load"))"║"
        end
        set_color --bold c084fc
        echo "  ╠$sep╣"
        echo "  ║"(string pad -r -w $interior (string sub -l $interior "  ◈ $status_msg"))"║"
        echo "  ╚$sep╝"
        set_color normal
    else
        set messages \
            "All systems operational." \
            "Running at peak efficiency." \
            "No anomalies detected." \
            "Diagnostics complete. All clear." \
            "Systems nominal. Standing by."
        set status_msg $messages[(random 1 (count $messages))]
        set hdr "══[ J.A.R.V.I.S. ]"
        set hdr_fill (string repeat -n (math $interior - (string length $hdr)) "═")

        set_color --bold cyan
        echo ""
        echo "  ╔$hdr$hdr_fill╗"
        echo "  ║"(string pad -r -w $interior (string sub -l $interior "  Just A Rather Very Intelligent System"))"║"
        echo "  ╠$sep╣"
        set_color normal
        set_color --bold cyan
        echo "  ║"(string pad -r -w $interior (string sub -l $interior "  Good $period, "(whoami)"."))"║"
        echo "  ║"(string pad -r -w $interior (string sub -l $interior "  $datetime"))"║"
        if test -n "$uptime_str"
            echo "  ║"(string pad -r -w $interior (string sub -l $interior "  Uptime: $uptime_str"))"║"
        end
        if test -n "$mem_info" -a -n "$cpu_load"
            echo "  ║"(string pad -r -w $interior (string sub -l $interior "  Memory: $mem_info   CPU: $cpu_load"))"║"
        end
        set_color --bold cyan
        echo "  ╠$sep╣"
        echo "  ║"(string pad -r -w $interior (string sub -l $interior "  ◈ $status_msg"))"║"
        echo "  ╚$sep╝"
        set_color normal
    end
    echo ""
end
