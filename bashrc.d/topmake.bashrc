topmake() {
    local top_level=$(git rev-parse --show-toplevel 2> /dev/null)
    [ $? -eq 0 ] && cd $top_level
    make $@
    return $?
}

# #!/bin/bash
# top_level=$(git rev-parse --show-toplevel 2> /dev/null)
# [ $? -eq 0 ] && cd $top_level
# eval "$*"
# exit $?
