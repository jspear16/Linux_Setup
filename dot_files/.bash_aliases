
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


# My aliases
alias LS='ls -goAGh --time-style="+%F %T%Z"'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .-='cd -'
alias ~='cd ~'
alias e='echo -e'
alias c='clear'
alias s='source ~/.bashrc'