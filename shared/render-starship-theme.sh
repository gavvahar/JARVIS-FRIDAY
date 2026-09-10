#!/usr/bin/env bash
# Renders shared/starship.toml.tmpl into a concrete starship config by
# substituting its @@...@@ placeholders. Used by the fish, termux, and zsh
# install scripts to produce both the JARVIS and FRIDAY theme files at
# install time, instead of checking in two hand-maintained near-duplicate
# .toml files (starship's config format has no include/import mechanism).
#
# Usage: render_starship_theme <template> <output> <title> <primary> \
#          <sec_cmddur> <sec_gitbranch> <sec_gitstatus> <sec_conda>

render_starship_theme() {
    local template="$1" output="$2" title="$3" primary="$4"
    local sec_cmddur="$5" sec_gitbranch="$6" sec_gitstatus="$7" sec_conda="$8"

    sed \
        -e "s/@@TITLE@@/$title/g" \
        -e "s/@@PRIMARY@@/$primary/g" \
        -e "s/@@SEC_CMDDUR@@/$sec_cmddur/g" \
        -e "s/@@SEC_GITBRANCH@@/$sec_gitbranch/g" \
        -e "s/@@SEC_GITSTATUS@@/$sec_gitstatus/g" \
        -e "s/@@SEC_CONDA@@/$sec_conda/g" \
        "$template" >"$output"
}

# Allow both `source render-starship-theme.sh` (then call the function
# directly) and running it standalone as `bash render-starship-theme.sh ...`.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    render_starship_theme "$@"
fi
