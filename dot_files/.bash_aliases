#!/bin/bash
# Colors (L = Light; D = Dark)
_BLK='\033[0;30m'
_RED='\033[0;31m'
_GRN='\033[0;32m'
_ORG='\033[0;33m'
_BLU='\033[0;34m'
_PUR='\033[0;35m'
_CYN='\033[0;36m'
_LGRA='\033[0;37m'

_DGRA='\033[1;30m'
_LRED='\033[1;31m'
_LGRN='\033[1;32m'
_YEL='\033[1;33m'
_LBLU='\033[1;34m'
_LPUR='\033[1;35m'
_LCYN='\033[1;36m'
_WHT='\033[1;37m'

_NC='\033[0m'

# Text Attributes
_BLINK='\e[5m'
_BOLD='\e[1m'
_DIM='\e[2m'
_ITON='\e[3m'
_ITOFF='\e[23m'
_HIGHON='\e[7m'
_HIGHOFF='\e[27m'
_UNDERON='\e[4m'
_UNDEROFF='\e[24m'
_REV='\e[7m'    # Switch text and background colors

_RESET='\e(B\e[m'
_CLEAR='\e[H\e[2J'


##### Alias functions #####
# Sudo last command
JS_sudo_last_command() { # do sudo, or sudo the last command if no argument given
    if [[ $# == 0 ]]; then
        sudo "$(history -p '!!')"
    else
        sudo "$@"
    fi
    return 0;
}

# Special function for LS
JS_special_ls() {
    if ! [[ $# == 0 ]]; then
        ls -goAGh --time-style="+%F %T%Z" $1 
    else
        ls -goAGh --time-style="+%F %T%Z" . 
    fi
    return 0;
}

# Run a shell script through the shellcheck command and run if it passes
JS_shellcheck_and_run() {
    if ! [[ $# == 1 ]]; then
        echo -e "${_RED}ERROR\n\t${_NC}Please enter a file to check and run"        
        return 1;
    fi
    shellcheck -x $1 && "./$1";
    return 0;
}


JS_help_info() {
    echo -e "
    ---------------------------------------------------------------------------------
    |   __________   __________   _________   __________   __________   __________  |
    |  |___    ___| |   _______| |   ___   | |   _______| |   ____   | |   ____   | |
    |      |  |     |  |         |  |   |  | |  |         |  |    |  | |  |    |  | |
    |      |  |     |  |_______  |  |___|  | |  |_____    |  |____|  | |  |____|  | |
    |      |  |     |_______   | |   ______| |   _____|   |   ____   | |      ____| |
    |   _  |  |             |  | |  |        |  |         |  |    |  | |  |\  \     |
    |  | |_|  |      _______|  | |  |        |  |_______  |  |    |  | |  | \  \    |
    |  |______|     |__________| |__|        |__________| |__|    |__| |__|  \__\   |
    ---------------------------------------------------------------------------------
    "
    echo -e "This tooltip is used to give basic instruction for Joseph's environment!\n"
    echo -e "The following are a list of helpful functions to use with this environment setup:

    ${_BOLD}JS_sudo_last_command (alias: s)${_RESET}
        Runs the last command as a super user

    ${_BOLD}JS_special_ls (alias: LS)${_RESET}
        Perform basic functionality to run an advanced ls command

    ${_BOLD}JS_shellcheck_and_run (alias: run)${_RESET}
        Run a shell script through the schellcheck linter program and run if there are no errors

    ${_BOLD}JS_help_info (alias: h)${_RESET}
        Display this help information

"
    echo -e "The following are a list of downloadable tools to use with this environment setup:

    shellcheck

"

    return 0;
}

##### My aliases #####
alias LS='JS_special_ls'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .-='cd -'
alias ~='cd ~'
alias e='echo -e'
alias c='clear'
alias s='JS_sudo_last_command'
alias t='touch'
alias h='JS_help_info'
alias run='JS_shellcheck_and_run'
