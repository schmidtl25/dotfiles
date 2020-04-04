echo sourcing bash_profile
# /etc/profile has been sourced for interactive-login shells

#################################################################
# source profile #
#################################################################
[ -r "$HOME/.profile" ] && source $HOME/.profile

#################################################################
# source bashrc #
#################################################################
[ -r "$HOME/.bashrc" ] && source $HOME/.bashrc
