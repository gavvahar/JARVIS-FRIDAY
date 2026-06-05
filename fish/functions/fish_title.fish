function fish_title
    if test (date "+%u") -eq 5
        echo "F.R.I.D.A.Y. — "(prompt_pwd)
    else
        echo "J.A.R.V.I.S. — "(prompt_pwd)
    end
end
