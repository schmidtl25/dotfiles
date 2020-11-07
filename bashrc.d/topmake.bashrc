topmake() {
    local top_level=$(git rev-parse --show-toplevel 2> /dev/null)
    [[ ! -z $top_level ]] && pushd $top_level > /dev/null
    make $@
    local make_rc=$?
    [[ ! -z $top_level ]] && popd > /dev/null
    return $make_rc
}

# #!/bin/bash
# top_level=$(git rev-parse --show-toplevel 2> /dev/null)
# [ $? -eq 0 ] && cd $top_level
# eval "$*"
# exit $?
