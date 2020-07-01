# may need to rewrite to be POSIX sh

git_branch() {
    # -- Finds and outputs the current branch name by parsing the list of
    #    all branches
    # -- Current branch is identified by an asterisk at the beginning
    # -- If not in a Git repository, error message goes to /dev/null and
    #    no output is produced
    # git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
    git rev-parse --abbrev-ref HEAD 2>/dev/null
}

git_color() {
    # Receives output of git_status as argument; produces appropriate color
    # code based on status of working directory:
    # - White if everything is clean
    # - Green if all changes are staged
    # - Red if there are uncommitted changes with nothing staged
    # - Yellow if there are both staged and unstaged changes
    # - Blue if there are unpushed commits
    # - Orange if 'git status' still pending
    pending=$([[ $1 =~ "pid" ]] && echo yes)
    staged=$([[ $1 =~ \+ ]] && echo yes)
    dirty=$([[ $1 =~ [!\?] ]] && echo yes)
    needs_push=$([[ $1 =~ P ]] && echo yes)

    if [[ -n $pending ]]; then
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
        state=$(read_git_status_cache)
        color=$(git_color $state)
        echo -e "$color[$branch$state]\033[00m"  # last bit resets color
    fi
}

# --------------- new -----------------
# Checks if PWD is a git repo
#  - if yes, returns 0 and repo info
#  - otherwise returns non-0
is_git_repo() {
    # variable declaration must occur before assignment to allow capturing of command substition return code
    local repo_info
    repo_info=($(git rev-parse --show-toplevel --is-inside-git-dir --is-bare-repository --is-inside-work-tree --abbrev-ref HEAD 2>/dev/null; exit $?))
    local git_rev_parse_rc=$?

    local top_level=${repo_info[0]}  #  --show-toplevel
    # local in_git_dir=${repo_info[1]} #  --is-inside-git-dir
    # local is_bare=${repo_info[2]} #  --is-bare-repository
    # local in_work_tree=${repo_info[3]} #  --is-inside-work-tree
    # local branch_name=${repo_info[4]} #  --abbrev-ref HEAD
    # not in a git_repo if $top_level is empty, return non-zero
    if [[ -z "$top_level" ]]; then
        return 1
    fi

    # return repo_info with rc of 0
    echo "${repo_info[@]}"
    return 0
}

# returns string of characters indicating various git repo status info
read_git_status_cache() {
    local repo_info
    repo_info=($(is_git_repo))
    local is_git_repo_rc=$?
    # rc != 0 indicates PWD is not a git repo, return immediately

    local top_level=${repo_info[0]}  #  --show-toplevel
    # local in_git_dir=${repo_info[1]} #  --is-inside-git-dir
    # local is_bare=${repo_info[2]} #  --is-bare-repository
    # local in_work_tree=${repo_info[3]} #  --is-inside-work-tree
    # local branch_name=${repo_info[4]} #  --abbrev-ref HEAD

    local status
    status_file=$(read_git_status_cache_final $top_level)
    local rc=$?
    if [[ $status_file =~ "pid" ]]; then
        # git status process is running and there is no prior git status file
        #  output will be git status pid with how long it's been running
        pid=${status_file#pid}
        echo "|pid $pid `ps -p $pid -o etimes=`s"
        return 1
    elif [[ -e $status_file ]]; then
        status=$(<$status_file)
        age=$(file_age $status_file)
    fi

    # Outputs a series of indicators based on the status of the
    # working directory:
    # + changes are staged and ready to commit
    # ! unstaged changes are present
    # ? untracked files are present
    # S changes have been stashed
    # P local commits need to be pushed to the remote
    # ~ status still running

    [[ -n $(egrep '^[MADRC]' <<<"$status") ]] && output="$output+"
    [[ -n $(egrep '^.[MD]' <<<"$status") ]] && output="$output!"
    [[ -n $(egrep '^\?\?' <<<"$status") ]] && output="$output?"
    # Check if in bare repo: [[ $in_work_tree && ...
    [[ -n $(git stash list) ]] && output="${output}S"
    # Maybe only check if current branch needs to be pushed?
    #  or - capital P for current branch - bold blue
    #     - little p for some other branch - flight blue
    [[ -n $(git log --branches --not --remotes) ]] && output="${output}P"
    [[ -n $output ]] && output="|$output ${age}s"  # separate from branch name

    echo "$output"
}

is_pid_running() {
    kill -0 $1 2> /dev/null
    rc=$?
    echo $rc
}

file_age() {
    echo $(($(date +%s) - $(date +%s -r "$1")))
}

start_git_status() {
    local git_prompt_dir=$1

    # default dir/files permisions to private
    umask 077

    # Create git_prompt_dir if it doesn't exist
    [[ -d $git_prompt_dir ]] || mkdir -p $git_prompt_dir

    local git_prompt_file="${git_prompt_dir}/git_prompt_`date +%s`"

    # TODO clean up old files
    #  keep "newest" file and it's tmpfile
    #  delete everything else in dir

    local git_status_tmpfile
    local git_status_pid

    # Get a tempfile to redirect git status to
    git_status_tmpfile=$(mktemp -p $(dirname $git_prompt_file))
    # exec and fork git status with redirect to tempfile
    nohup git status --porcelain 1> $git_status_tmpfile 2>/dev/null &
    # capture forked git status PID
    git_status_pid=$!

    # write git status info to git_prompt_file
    echo $git_status_pid $git_status_tmpfile > $git_prompt_file

    # TODO wait a brief amount of time to allow git status process to complete (< 1 second)
    # wait $git_status_pid
    # if $git_status_pid finishes, return $git_prompt_file

    echo "pid$git_status_pid"
}

get_git_prompt_repo_hash() {
    repo_top_hash=$(md5sum <<< $(readlink -e $1) | awk '{print $1}')
    # TODO maybe use different PATH than /tmp
    echo "/tmp/$USER/git_prompt/$repo_top_hash"
}

read_git_status_cache_final() {
    local pwd_top_level=$1

    # Get dir that git_status_cache files are stored in
    local git_prompt_dir=$(get_git_prompt_repo_hash $1)

    # Determine the "newest" git_prompt_file in cache
    local git_prompt_file="$(ls -t $git_prompt_dir/git_prompt_* 2> /dev/null | head -1)"

    # Check if git_prompt_file exists
    if [[ -f $git_prompt_file ]]; then
        local git_status_pid
        local git_status_tmpfile

        # git_prompt_file exists, read git status pid and output tmpfile
        read git_status_pid git_status_tmpfile < $git_prompt_file
        if [[ $(is_pid_running $git_status_pid) -ne 0 ]]; then
            # git status is done, read status output
            #status=$(<$git_status_tmpfile)
            status=$git_status_tmpfile
            age=$(file_age $git_status_tmpfile)
            # TODO refactor fix number to ENV variable MAX_GIT_STATUS_AGE
            [[ $age -gt 5 ]] && start_git_status $git_prompt_dir > /dev/null
        else
            status="pid$git_status_pid"
            # look for 2nd oldest git_prompt_file
            git_prompt_file="$(ls -t $git_prompt_dir/git_prompt_* 2> /dev/null | head -2 | tail -1)"
            if [[ -f $git_prompt_file ]]; then
                read git_status_pid git_status_tmpfile < $git_prompt_file
                if [[ $(is_pid_running $git_status_pid) -ne 0 ]]; then
                    # git status is done, read status output
                    #status=$(<$git_status_tmpfile)
                    status=$git_status_tmpfile
                fi
            fi
        fi
    fi

    # Could not find status, start git status now
    if [[ (-z $status) ]]; then
        status=$(start_git_status $git_prompt_dir)
    fi

    echo $status
}
