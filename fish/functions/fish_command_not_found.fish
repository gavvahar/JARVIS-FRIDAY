function fish_command_not_found
    if test (date "+%u") -eq 5
        set_color c084fc
    else
        set_color cyan
    end
    printf "  ◈ "
    set_color normal
    printf "Command not recognized: "
    set_color --bold white
    echo "'$argv[1]'"
    set_color normal
end
