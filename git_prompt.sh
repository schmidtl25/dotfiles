# may need to rewrite to be POXIX sh

git_branch() {
    # -- Finds and outputs the current branch name by parsing the list of
    #    all branches
    # -- Current branch is identified by an asterisk at the beginning
    # -- If not in a Git repository, error message goes to /dev/null and
    #    no output is produced
    # git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
    git rev-parse --abbrev-ref HEAD 2>/dev/null
}

git_status() {
    # Outputs a series of indicators based on the status of the
    # working directory:
    # + changes are staged and ready to commit
    # ! unstaged changes are present
    # ? untracked files are present
    # S changes have been stashed
    # P local commits need to be pushed to the remote
    # ~ status timedout
    # ~~ status still running
    
    local timeout_short=""
    local timeout_long=""
    if command -v timeout > /dev/null; then
        timeout_short="timeout 1s"
        timeout_long="timeout 1s"
    fi

    # status="$($timeout_long git status --porcelain 2>/dev/null)"
    # status="$($timeout_long sleep 5 2>/dev/null)"
    
    # status="$($timeout_long git diff --no-ext-diff --quiet || if [ "$?" == "124" ]; then { nohup  git diff --no-ext-diff --quiet >/dev/null 2>&1 & } ;  skip="yes"; w="~"; else w="*"; fi)"

    # Check if prior 'git status' is still running
    GIT_STATUS_PID_FILE="/tmp/.${USER}_$$_GIT_STATUS"
    if [[ -r "$GIT_STATUS_PID_FILE" ]]; then
        GIT_STATUS_PID=$(<$GIT_STATUS_PID_FILE)
        kill -0 $GIT_STATUS_PID 2>/dev/null
        if [[ $? -eq 0 ]]; then
            echo "~~$GIT_STATUS_PID"
            return 0
        fi
        rm $GIT_STATUS_PID_FILE
    fi
    
    status="$( \
$timeout_long git status --porcelain 2>/dev/null || \
if [ "$?" == "124" ]; then \
  { nohup git status --porcelain >/dev/null 2>&1 & } ; \
  export GIT_STATUS_PID=$!; \
  echo "~$GIT_STATUS_PID" ; \
fi \
)"
    output=''
    if [[ $status =~ \~ ]]; then
        # could capture git status PID, check if it's still active, and not run another status until it's done
        # output="$status"
        GIT_STATUS_PID=${status#?}
        output="~$GIT_STATUS_PID "
        echo $GIT_STATUS_PID > $GIT_STATUS_PID_FILE
        # output="$output~"
    else
        [[ -n $(egrep '^[MADRC]' <<<"$status") ]] && output="$output+"
        [[ -n $(egrep '^.[MD]' <<<"$status") ]] && output="$output!"
        [[ -n $(egrep '^\?\?' <<<"$status") ]] && output="$output?"
        [[ -n $(git stash list) ]] && output="${output}S"
        [[ -n $(git log --branches --not --remotes) ]] && output="${output}P"
        [[ -n $output ]] && output="|$output"  # separate from branch name
    fi
    echo $output
}

git_color() {
    # Receives output of git_status as argument; produces appropriate color
    # code based on status of working directory:
    # - White if everything is clean
    # - Green if all changes are staged
    # - Red if there are uncommitted changes with nothing staged
    # - Yellow if there are both staged and unstaged changes
    # - Blue if there are unpushed commits
    timedout=$([[ $1 =~ \~ ]] && echo yes)
    staged=$([[ $1 =~ \+ ]] && echo yes)
    dirty=$([[ $1 =~ [!\?] ]] && echo yes)
    needs_push=$([[ $1 =~ P ]] && echo yes)

    if [[ -n $timedout ]]; then
        echo -e '\033[38;5;214m\033[1m'  # bold orange
    elif [[ -n $staged ]] && [[ -n $dirty ]]; then
        echo -e '\033[1;33m'  # bold yellow
    elif [[ -n $staged ]]; then
        echo -e '\033[1;32m'  # bold green
    elif [[ -n $dirty ]]; then
        echo -e '\033[1;31m'  # bold red
    elif [[ -n $needs_push ]]; then
        echo -e '\033[1;34m'  # bold blue
    else
        echo -e '\033[1;37m'  # bold white
    fi
}

git_prompt() {
    # First, get the branch name...
    branch=$(git_branch)
    # Empty output? Then we're not in a Git repository, so bypass the rest
    # of the function, producing no output
    if [[ -n $branch ]]; then
        state=$(git_status)
        color=$(git_color $state)
        if [[ $state =~ \~ ]]; then
            echo -e "$color[$state $branch]\033[00m"  # last bit resets color            
        else
            echo -e "$color[$branch$state]\033[00m"  # last bit resets color
        fi
    fi
}
