if [ -r "$HOME/.profile.ibm" ]; then
    CWD=`pwd`
    PROFILE_IBM_PATH=$(dirname `readlink $HOME/.profile.ibm`)
    PROFILE_IBM=$(basename `readlink $HOME/.profile.ibm`)
    cd $PROFILE_IBM_PATH
    source $PROFILE_IBM
    cd $CWD
fi
[ -r "$HOME/.profile.schmidtl" ] && source $HOME/.profile.schmidtl
