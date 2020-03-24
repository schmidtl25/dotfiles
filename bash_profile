# /etc/profile has been sourced for interactive-login shells

#################################################################
# source profile #
#################################################################
if [ -r "$HOME/.profile" ]; then
   echo "sourcing $HOME/.profile"
   source $HOME/.profile
   echo "sourced"
fi

#################################################################
# source bashrc #
#################################################################
[ -r "$HOME/.bashrc" ] && source $HOME/.bashrc
