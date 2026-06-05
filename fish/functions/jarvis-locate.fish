function jarvis-locate
    set sub $argv[1]

    if test (count $argv) -eq 0 -o "$sub" = list
        if test (count $JARVIS_LOCATIONS) -eq 0
            set_color cyan; printf "  ◈ "; set_color normal
            echo "No locations set — using IP detection."
        else
            set_color --bold cyan; echo "  Monitored locations:"; set_color normal
            set i 1
            for loc in $JARVIS_LOCATIONS
                set_color cyan; printf "  $i. "; set_color normal
                echo $loc
                set i (math $i + 1)
            end
        end

    else if test "$sub" = add
        set loc (string join ' ' $argv[2..-1])
        if test -z "$loc"
            echo "Usage: jarvis-locate add \"City, State\""
            return 1
        end
        set -Ux JARVIS_LOCATIONS $JARVIS_LOCATIONS $loc
        set_color cyan; printf "  ◈ "; set_color normal
        echo "Added: $loc"

    else if test "$sub" = remove
        set loc (string join ' ' $argv[2..-1])
        set new_list
        for l in $JARVIS_LOCATIONS
            if test "$l" != "$loc"
                set new_list $new_list $l
            end
        end
        set -Ux JARVIS_LOCATIONS $new_list
        set_color cyan; printf "  ◈ "; set_color normal
        echo "Removed: $loc"

    else if test "$sub" = clear
        set -Ue JARVIS_LOCATIONS
        set_color cyan; printf "  ◈ "; set_color normal
        echo "All locations cleared. Falling back to IP detection."

    else
        echo "Usage:"
        echo "  jarvis-locate                       — show monitored locations"
        echo "  jarvis-locate add \"City, State\"    — add a location"
        echo "  jarvis-locate remove \"City, State\" — remove a location"
        echo "  jarvis-locate clear                 — clear all locations"
    end
end
