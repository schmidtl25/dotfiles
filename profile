if [ -r "$HOME/.profile.ibm" ]; then
    CWD=`pwd`
    PROFILE_IBM_PATH=$(dirname `readlink $HOME/.profile.ibm`)
    PROFILE_IBM=$(basename `readlink $HOME/.profile.ibm`)
    # echo CWD=$CWD
    # echo PROFILE_IBM_PATH=$PROFILE_IBM_PATH
    # echo PROFILE_IBM=$PROFILE_IBM
    # source $HOME/.profile.ibm
    cd $PROFILE_IBM_PATH
    source $PROFILE_IBM
    cd $CWD
fi
[ -r "$HOME/.profile.schmidtl" ] && source $HOME/.profile.schmidtl
