#!/bin/bash

# ~/.shellcheckrc
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

######### PERSONAL SECTION #########
# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.


### Bashrc Configuration ###

if [ -f ~/.bash_aliases ]; then
# shellcheck disable=SC1090
    . ~/.bash_aliases
fi

lines=0

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend
shopt -s autocd     # Allows cd into a directory without putting 'cd ' in front of the directory name

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi
# lines=2

entered=0

# Received functions from https://unix.stackexchange.com/questions/88296/get-vertical-cursor-position
pos_num(){
    local CURPOS
    read -sdR -p $'\E[6n' CURPOS
    CURPOS=${CURPOS#*[} # Strip decoration characters <ESC>[
    echo "${CURPOS}"    # Return position in "row;col" format
}
row_num(){
    local COL
    local ROW
    IFS=';' read -sdR -p $'\E[6n' ROW COL
    echo "${ROW#*[}"
}
col_num(){
    local COL
    local ROW
    IFS=';' read -sdR -p $'\E[6n' ROW COL
    echo "${COL}"
}

# Functions for the PROMPT_COMMAND. These happen right before the PS1 prompt is printed
first_enter(){
    if [[ $entered -eq 0 ]]; then
        entered=1
        # In the future, can potentially add background color using something like the following
        # r=0
        # g=0
        # b=255
        # printf '\e[0;48;2;%s;%s;%sm%03d;%03d;%03d ' "$r" "$g" "$b" "$r" "$g" "$b"
        # tput clear
    fi
}
print_header(){
    # Check if row_num is NOT equal to lines on
    if ! [[ $(row_num) -eq `tput lines` ]]; then
        tput sc
        tput home
        tput dl 2
        tput rc
        tput cuu1
    else
        tput cud1
    fi

    if [[ $(row_num) -lt 2 ]]; then
        tput cup 2 0
        tput cuu1
    fi

}



if [ "$color_prompt" = yes ]; then
#   Default PS1
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#   PS1="${_GRN}\u${_LGRA}@${_PUR}\h${_LGRA}:${_CYN}\w${_GRN}$ ${_LGRA}"
#   PS1='$ '

# tput setab 234 # If we want to use different background
# \033[39;49m # This resets the background

# This is currently not working with completions
# PROMPT_COMMAND=('first_enter' 'print_header')
#     PS1="
# \[$(tput setaf 2)\]\
# \[$(tput sc; tput home; tput il 2; tput cuf $(($COLUMNS/2 - 14)))\]\u\
# \[$(tput setaf 7)\]@\[$(tput setaf 13)\]\h\[$(tput setaf 7)\]   \t
# \[$(tput setaf 6)\] \$PWD
# \[$(tput rc)\]\[$(tput setaf 2)\] $\[$(tput setaf 7)\] "

else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt


# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export PATH=/usr/lib/mxe/usr/bin/:"$PATH"

######### END PERSONAL SECTION #########















######## WORK SECTION #########
# Consts
MONO_DIR=~/workspace/skipline/projects;
SYS_DIR=~/skiprepo/production/systems;
SIM_DIR=~/supportsim/skipline/projects;

red_msg()
{
    echo -en "\e[0;31m"
    echo "$@"
    echo -en "\e[0m"
}
gc_build()
{
    (
    export PATH=${HOME}/qt_versions/5.15.2/gcc_64/bin/:"$PATH"
    mkdir -p build && cd build/ && qmake .. CONFIG+=debug && make -j8
    ) 2>&1 > /dev/null | sed -e 's;^../../;;'
}
gc_static_analyze()
{
    GC_STATIC_ANALYZER="clazy --standalone"
#   GC_STATIC_ANALYZER="clang-tidy"
    (
    export CLAZY_HEADER_FILTER="\./"
    jq '.[].directory+"/"+.[].file'  build/compile_commands.json |
        sort | uniq |
        xargs "$GC_STATIC_ANALYZER" -p build \
            --extra-arg="-Wno-inconsistent-missing-override" \
            --extra-arg="-Wno-clazy-connect-by-name" \
            --export-fixes="$(readlink -f build/fixes.yaml)"
    )
}
gc_hw_build()
{
    if ! ( grep 'BR2_DEFCONFIG' "${HOME}/workspace/buildroot-hdvo/.config" | grep 'zynq_hdvo318_defconfig' ); then
        red_msg "Must use correct defconfig: make zynq_hdvo318_defconfig"
        return 1
    fi
    (
    mkdir -p hw-build && cd hw-build/ && "${HOME}/workspace/buildroot-hdvo/output/host/bin/qmake" .. && make -j8
    ) 2>&1 > /dev/null
}
canutils_build()
{
    (
    export PATH=${HOME}/qt_versions/5.15.2/gcc_64/bin/:"$PATH"
    # -k flag keeps going when CANDisplay fails to build correctly
    # Building with qt4 is desired now because stax viewer has janky colors at the moment with qt5
    mkdir -p build && cd build/ && qmake .. CONFIG+=debug && bear --append -- make -j8 -k
    ) 2>&1 > /dev/null | sed -e 's;^../../;;'
}
ust_build()
{
    (
    export PATH=${HOME}/qt_versions/5.15.2/gcc_64/bin/:"$PATH"
    mkdir -p build && cd build/ && cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo .. && make -j8
    ) 2>&1 > /dev/null
}
ust_hw_build()
{
    (
    export UST_BUILDROOT_DIR="${HOME}/workspace/buildroot-ust20"
    mkdir -p build/build-hw && cd build/build-hw/ && "$UST_BUILDROOT_DIR/output/host/bin/cmake" -Wno-dev -DCMAKE_TOOLCHAIN_FILE=../../ust20_toolchain.cmake -DUST_BUILDROOT_DIR:PATH="$UST_BUILDROOT_DIR" ../.. && make -j8
    ) 2>&1 > /dev/null
    # See script.sh in ~/workspace/ust-update/update-example
    # This script is what runs, basically copied to each update
    # different systems may need to do different things.
    # Pass the list of files to the mkupdate
    # Dan T is using _Release/ from CoreSkipper, confirm if that is ok
#(ins)$ cd ~/workspace/buildroot-ust20/board/skipline/ust20_updateroot/UpdateCreator/
#make_update.sh
#bash ./make_update.sh ~/workspace/ust-update/whiteline/*
# makes output/update.bin
# https://git.skip-line.com/dan_sl/u-st20 is where the setups for a brand new
#    ust20 setup are
# Need new folder for safety mark or whoever in skiprepo
}
pigeon_hw_build()
{
    (
    export PATH=/opt/swi/y25-ext/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi/:"$PATH"
    mkdir -p build && cd build/ && /opt/swi/y25-ext/sysroots/x86_64-pokysdk-linux/usr/bin/qmake .. && make -j8
    ) 2>&1 > /dev/null
}
gc_system()
{( # subshell so env doesn't leak
        system="${1:?system required eg~/skiprepo/production/systems/GC12_A22311/variants/cellular_hdvo/}"
        # default to root directory, per gc developer setup instructions
        SKLCORE_ROOT="${2:-/}"
        rm -rf --preserve-root "$SKLCORE_ROOT"/data/* "$SKLCORE_ROOT"/factorydefaults/*
        cp "$system"/factorydefaults/*.xml "$SKLCORE_ROOT"/factorydefaults/
        cp "$system"/permissions/permissions.json "$SKLCORE_ROOT"/factorydefaults/
        # Woops! These should be per dev becasue DataTransmit could be generating SRO data on the dev PC.
        cp "$system"/loggingconfig.json "$SKLCORE_ROOT"/factorydefaults/
        cp "$system"/enc_id "$SKLCORE_ROOT"/factorydefaults/
        cp "$system"/DefaultUIConfig.json "$SKLCORE_ROOT"/factorydefaults/
        cp "$system"/PatternConfig.json "$SKLCORE_ROOT"/factorydefaults/
)}
ust_run() {
    (
        export QT_LOGGING_RULE=qt.qml.binding.removal.info=true
        export LD_LIBRARY_PATH=$HOME/qt_versions/5.15.2/gcc_64/lib
        ./build/src/ust
    )
}
remote_connect_wait_for_tunnel()
{
    if [ $# -lt 1 ] || [ -z "$1" ]; then
        echo "Pass CVO_xxxx as first param" 1>&2
        return 1
    fi
    local CVO_ID
    CVO_ID="$1"
    mosquitto_pub -h realtime.skip-line.com -p 8883 -u m742r5O599CaV5W -P GQ52Rn5jK97iwQj -t "HDVO/$CVO_ID/REMOTE_CONNECT" -n --capath /etc/ssl/certs || { echo "mosquitto failed"; return 1; }
    echo "do 'ps aux | grep ssh' until a new connection appears"
    echo "then use remote_connect_start_ssh"
    # RT is also a channel (replacing REMOTE_CONNECT) and doesn't require remote connection stuff I think
}
remote_connect_start_ssh()
{
    ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i ~/Documents/hdvo_ssh/hdvo_access_key -p 1234 root@localhost
    red_msg "DON'T FORGET TO CLOSE THE REMOTE CONNECTION IN ORG"
}
remote_connect_kill_ssh()
{
    ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i ~/Documents/hdvo_ssh/hdvo_access_key -p 1234 root@localhost "killall ssh"
}
remote_connect_scp()
{
    scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i ~/Documents/hdvo_ssh/hdvo_access_key -P 1234 root@localhost:"$1" ./
    red_msg "DON'T FORGET TO CLOSE THE REMOTE CONNECTION IN ORG"
}
switch_functions_to_num()
{
    cpp -P -D'DefineSwitchFunction(a,b,c)=__COUNTER__ a' "$HOME/workspace/skipline/projects/common_libs/switches/switch_functions.def" | awk '{ print $1+1 "\t" $2 }'
}
kiwi_build()
{
    #https://github.com/Spec-Rite/Kiwi/wiki/Building#building-kiwi
    (
    mkdir -p build && cd build/ && cmake -DCPU_ONLY=on -DCMAKE_BUILD_TYPE=Debug -DDESKTOP_BUILD=ON .. && make -j8 && make dev_gui -j8
    ) 2>&1 > /dev/null
}
kiwi_hw_build()
{
    # Building on the actual target
    #https://github.com/Spec-Rite/Kiwi/wiki/Building#building-kiwi
    (
    mkdir -p build && cd build/ && cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/eagleeye_toolchain.cmake -DKIWI_BUILD=ON .. && make -j8
    ) 2>&1 > /dev/null
}
kiwi_stream_to_video4()
{
    # This matches the first sampleconfig.json input in the Kiwi repo
    video=/dev/video4
    fakevideonum=7
    if [ $# -lt 1 ]; then
        red_msg "Usage: ${FUNCNAME[0]} <path to image>"
        return 1
    fi
    if [ ! -h "$video" ]; then
        # We have to make a loopback device and then
        # symlink it to /dev/video0 because the Kiwi looks
        # at that device name.
        sudo mv "$video" "$video".bak
        sudo modprobe v4l2loopback video_nr="$fakevideonum"
        sudo ln -s "/dev/video$fakevideonum" "$video"
    fi
    is_image=false
    if file "$1" | grep -E -i "(jpeg|jpg|bmp|png)"; then
        is_image=true
    fi
    # This encodes the image into a loop and streams the raw h264 video
    # to stdout. The second ffmpeg instance grabs it off stdin and sends
    # it to the loopback device. Note that it will fail if the image width
    # and height are not even numbers.
    # We scale the video to the expected dimensions
    if [ "$is_image" = "true" ]; then
        ffmpeg -re -loop 1 -i "$1" -vf "scale=1920:1080" -c:v libx264 -tune stillimage -pix_fmt yuv420p -f rawvideo - | ffmpeg -re -i - -f v4l2 "/dev/video$fakevideonum"
    else
        # Run the input video on a loop
        ffmpeg -re -stream_loop -1 -i "$1" -vf "scale=1920:1080" -c:v libx264 -f v4l2 "/dev/video$fakevideonum"
    fi
}
start_StaxViewer()
{
    ~/workspace/skipline/projects/canutils/build/StaxViewer/StaxViewer --truck "$@" &>/dev/null &
}
start_GrinderTester()
{
    ~/workspace/skipline/projects/canutils/GrinderTester/GrinderTester &>/dev/null &
}
start_CANDisplayV2()
{
    ~/workspace/skipline/projects/canutils/build/CANDisplayV2/CANDisplayV2 &>/dev/null &
}
start_BerendsenSim()
{
    ~/workspace/skipline/projects/canutils/build/BerendsenSim/BerendsenSim &>/dev/null &
}
start_LaserSimulator()
{
    ~/workspace/skipline/projects/canutils/build/LaserSimulator/LaserSimulator &>/dev/null &
}
start_EatonKeypad()
{
    ~/workspace/skipline/projects/canutils/build/EatonJ1939KeypadSim/EatonJ1939KeypadSim &>/dev/null &
}
start_EatonOutput()
{
    # Often we may want to use the second mRFRM on a system, in which case we need to pass
    # the argument "--index 1" to allow us to tell the simulator which CAN messages to send
    ~/workspace/skipline/projects/canutils/build/EatonJ1939OutputSim/EatonJ1939OutputSim "$@" &>/dev/null &
}
start_SupportSimUtil()
{
    python3 ~/workspace/SupportSimUtil/mainwindow.py &>/dev/null &
}
start_BootloaderGUI()
{
    ~/workspace/skipline/projects/canutils/build/BootloaderGUI/BootloaderGUI &>/dev/null &
}
start_TruckDesigner()
{
    (cd ~/workspace/skipline/projects/can-cfg && ./build/can-cfg --svntestonly &>/dev/null) &
}
start_MakeSystemUpdate()
{
    (cd ~/workspace/skipline/projects/utils/UpdateCreator && ./make_system_update.sh "$@" && cp ~/Downloads/DL-18UpdateInstructions.pdf ./output/ && xdg-open ./output)
}
start_DeployManualBinaries()
{
    if [ "$#" -lt 1 ]; then
        return 1
    fi
    system_file=$(readlink -f "$1")
    if ! [ -e "$system_file" ]; then
        echo "system file doesn't exist"
        return 1
    fi
    (cd ~/workspace/skipline/projects/skipper && ./systems/select_system.py "$system_file" && ./scripts/eclipse_build.sh Deploy _Deploy . && ./scripts/deployBinaries.py)
}
start_UpdateApollo()
{
    ssh burner@apollo.skip-line.com "cd skiprepo/production/systems && svn up"
}
start_meldSystemFiles()
{
    (
    cd ~/skiprepo/production/systems || return 1
    if ! [ -d "$1" ]; then
        echo "system directory doesn't exist"
        return 1
    fi
    cd "$1" || return 1
    files=( "permissions/permissions.json" "factorydefaults/IOConfig.xml" "factorydefaults/DefaultUIConfig.xml" )
    td_folder="td_variants/logging"
    if ! [ -d "$td_folder" ]; then
        td_folder="td_variants/non_logging"
    fi
    if ! [ -d "$td_folder" ]; then
        echo "no td folder"
    fi
    variants_folder="variants/cellular_hdvo"
    if ! [ -d "$variants_folder" ]; then
        variants_folder="variants/logging"
    fi
    if ! [ -d "$variants_folder" ]; then
        variants_folder="variants/non_logging"
    fi
    if ! [ -d "$variants_folder" ]; then
        echo "no variants folder"
        # Actually just print list of file pairs to diff, then make outer function that calls meld with
        # --diff option repeatedly. Then each new call to these functions will open a new meld instance.
    fi
    for file in "${files[@]}"; do
        echo meld "$td_folder/$file" "$variants_folder/$file" -n
        meld "$td_folder/$file" "$variants_folder/$file" -n &>/dev/null &
    done
    start_meldManualAndTD "$1"
    )
}
start_meldManualAndTD()
{
    (
    if ! [ "$#" -eq 1 ]; then
        red_msg "Pass system name eg systems/sc12_blah_MANUAL or sc12_blah"
        return 1
    fi
    local sanitized_input;
    sanitized_input=$(basename "${1%%/}");
    local base_system="${sanitized_input%%_MANUAL.h}"
    local maybe_manual_system="${base_system}_MANUAL"
    local manual_system_file_name="${maybe_manual_system}.h"
    local skipper_systems_folder="$HOME/workspace/skipline/projects/skipper/systems"
    local systems_folder="$HOME/skiprepo/production/systems"
    if ! [ -d "$systems_folder/$base_system" ]; then
        red_msg "$systems_folder/$base_system does not exist"
        return 1
    fi
    if ! [ -f "$skipper_systems_folder/$manual_system_file_name" ]; then
        red_msg "$skipper_systems_folder/$manual_system_file_name does not exist"
    fi
    echo meld "$systems_folder/$base_system/system.h" "$skipper_systems_folder/$manual_system_file_name" -n
    meld "$systems_folder/$base_system/system.h" "$skipper_systems_folder/$manual_system_file_name" -n &>/dev/null &
    )
}
start_RebuildTDAndGC()
{
    (cd ~/workspace/skipline/projects/can-cfg && touch can-cfg.qrc && scripts/command_line_dev_build --quiet)
    (cd ~/workspace/skipline/projects/GlassCockpit && scripts/command_line_dev_build --release-pc --quiet)
}
start_DeployHDVO()
{
    if [ $# -lt 1 ]; then
        return 1
    fi
    local folder_path
    folder_path="$(readlink -f "$1")"
    if ! [ -d "$folder_path" ]; then
        red_msg "$folder_path is not a valid directory"
        return 1
    fi
    ( cd "$folder_path" && ~/workspace/skipline/projects/GlassCockpit/scripts/deployHDVOscript/deployHDVO.py "$(basename "$folder_path")" )
}
start_MakeSystemManual()
{
    if [ $# -lt 1 ]; then
        return 1
    fi
    local folder_path
    folder_path="$(readlink -f "$1")"
    if ! [ -d "$folder_path" ]; then
        red_msg "$folder_path is not a valid directory"
        return 1
    fi
    ( cd ~/workspace/skipline/projects/skipper && ./scripts/make_system_manual.sh "$(basename "$folder_path")" )
}
start_DeployStandaloneHDVO()
{
    ( cd ~/hdvo-318/code/hdvo-318/scripts/production && ./hdvo_config_deploy.py )
}
start_ProgramSwc-1312()
{
    avrdude -pc128 -cavrisp2 -Pusb -B6 -F -u -Uflash:w:avr-cbl/STANDALONE_SWITCH_BOX/avr-cbl.hex:a -Ulfuse:w:0xFF:m -Uhfuse:w:0xD0:m -Uefuse:w:0xF5:m
}
start_sgpt()
{
    sgpt --model 'gpt-4' "$@"
}
example_find()
{
    # handles newlines, spaces, etc
    while IFS= read -r -d '' file; do
        echo "$file"
    done < <(find "$dir" -type f \( -name "*.bin" -o -name "*Wiring Sheet.pdf" \) -print0)
}
start_search_systems_for_features()
{
    while IFS= read -r -d '' file; do
        local llama_info
        llama_info=$(jq -e 'recurse | select(.materialPressureOutput? == "Adaptive Paint Pressure Control")' "$file")
        if $?; then
            :
            # This isn't working yet, want to look at num pump inputs per color that matches llama being enabled above
#           local pumpInputsForColor
#           pumpInputsForColor=$(jq -e "recurse | select(numPumpInputs.$(echo "$llama_info" | jq 'select(.color)').materialPressureOutput? == "Adaptive Paint Pressure Control")" "$file")
        fi
    done < <(find "$HOME/skiprepo/production/systems" -type f -name "*.truck" -print0)
}
helper_yes_no_dialog()
{
    local prompt="Continue?"
    if [ $# -gt 0 ]; then
        prompt="$1"
    fi
    local answer="N"
    read -r -p "$(echo -e $prompt) (Yy/Nn): " answer
    case "$answer" in
        Y|y)
            ;;
        *) return 1;
    esac
}
svncommit()
{
    command_options=("$@")
    for (( i=0; i<${#command_options[@]}; i++ )); do
        if [[ ${command_options[i]} == "-m" ]]; then
            unset "command_options[i]"
            unset "command_options[i+1]"
        fi
    done
    svn status "${command_options[@]}"
    local answer="N"
    helper_yes_no_dialog "Do you want to commit these files?" || return 1;
    svn commit "$@"
}
start_SetupNewGrinderHDVO()
{
    ( ~/hdvo-318/code/hdvo-318/scripts/production/hdvo_config_deploy.py --pigeonize "$@")
    # Then copy any gc configs from another system
}
start_DownloadSnapshots()
{
    # 1. Have to jump through different IP as org server limits access based on IP address
    # 2. Using skipline account after Doug added my public key under the skip-line account
    #
    # Example start_DownloadSnapshots 'CVO_1706/2024/04/17/*' .
    if [ $# -eq 0 ]; then
        echo 'Usage start_DownloadSnapshots '\''CVO_1706/2024/04/17/*'\'' /directory/to/place/files'
        return 1
    fi
    scp -J burner@192.168.3.6 "skipline@reportgen2-online.skip-line.com:/var/www/rg2web/media/datafiles/$1" "$2"
}
start_mountUSBBinFile()
{
    binfile="_Release_PC/master/usbfat.bin"
    if [ $# -gt 0 ]; then
        binfile="$1"
    fi
    mkdir -p /tmp/usb
    sudo mount -t vfat -o "uid=$(id -u),rw" "$binfile" /tmp/usb
    echo "unmount with: sudo umount /tmp/usb"
    xdg-open /tmp/usb
}
start_activate_sim_card()
{
    if [ $# -ne 3 ]; then
        echo Usage: start_activate_sim_card hdvo_serial_number cvo_id sim_id
        return 1;
    fi
    local PROGSERNUM
    local CVO_ID
    local SIMID
    PROGSERNUM="$1"
    CVO_ID="$2"
    SIMID="$3"
    local HOLOGRAM_ORG_ID=32801
    local HOLOGRAM_API_KEY=4izrmTIpQWFKLqNXrY4GgcfAdXMWas
    local HOLOGRAM_PLAN_ID=1046
    local HOLOGRAM_ZONE=global
    local HOLOGRAM_TAG=8995
    curl -f --header "Content-Type: application/json" --data "{\"username\":\"hdvoDeployScript\",\"password\":\"hFVWvSX7DTLu\",\"truck_id\":\"${CVO_ID}\",\"serial_num\":\"${PROGSERNUM}\",\"sim\":\"${SIMID}\"}" https://reportgen2-online.skip-line.com/trucks/append_sim/
    ACTIVATION_RESPONSE=$(curl -f --request POST --header "Content-Type: application/json" --data-binary "{\"plan\":${HOLOGRAM_PLAN_ID},\"zone\":\"${HOLOGRAM_ZONE}\",\"orgid\":${HOLOGRAM_ORG_ID},\"tagid\":${HOLOGRAM_TAG}}" "https://dashboard.hologram.io/api/1/links/cellular/sim_${SIMID}/claim" -u apikey:${HOLOGRAM_API_KEY})
    if [ $? -eq 0 ] && [ "x$(echo $ACTIVATION_RESPONSE | jq '.success')" == "xtrue" ]; then
        # Parse the JSON response to get a device ID back out of it
        DEVICEID="$(echo "$ACTIVATION_RESPONSE" | jq '.data[0].device')"
        if [ "x$DEVICEID" != "x" ]; then
            # Now tell hologram to name this device
            curl -f --request PUT --header "Content-Type: application/json" --data-binary "{\"name\":\"${CVO_ID} (${SIMID: -5})\",\"orgid\":${HOLOGRAM_ORG_ID}}" "https://dashboard.hologram.io/api/1/devices/${DEVICEID}" -u apikey:${HOLOGRAM_API_KEY}
        fi
    else
        "SIM card activation failed. An error occurred while trying to contact Hologram. SIM ID = $SIMID. Try again?"
    fi
}
start_setupVCan()
{
    local num=0
    if [ $# -eq 1 ]; then
        num=$1
    fi
    sudo modprobe vcan
    sudo ip link add dev "can$num" type vcan
    sudo ip link set up "can$num"
}
start_setupHWCan()
{
    local num=0
    if [ $# -eq 1 ]; then
        num=$1
    fi
    sudo modprobe can
    sudo ip link set "can$num" up txqueuelen 1000 type can bitrate 250000 sample-point 0.7 restart-ms 500
}
start_startWireguard()
{
    sudo wg-quick up /etc/wireguard/wg0.conf
}
start_QtCreator()
{
    if [ $# -gt 1 ]; then
        echo "Please pass 0 or 1 files into this command"
        return 1;
    elif [ $# -eq 1 ]; then
        file=$(pwd)"/$1"
        echo -e "Opening $file in QtCreator...\n"

        ( cd ~/qt_versions/5.15.2/Tools/QtCreator/bin/ && ./qtcreator "$file") &
    else
        ( cd ~/qt_versions/5.15.2/Tools/QtCreator/bin/ && ./qtcreator) &
    fi
}
start_mountHDVOUpdate()
{
    if [ $# -ne 1 ]; then
        echo "Please pass 1 update.bin file to mount."
        return 1;
    fi

    echo "Attempting to mount $1..."

    # Mount the update file
    (cd ~/workspace/skipline/projects/utils/UpdateCreator && ./mount_update.sh "$1")
    ret=$?

    if [ $ret -eq 0 ]; then
        echo -e "\nSuccessfully mounted $1! Opening up /tmp/hdvoupdate/ in VSCode."
        # Open up the folder in code to quickly look at the contents
        (code /tmp/hdvoupdate/)
    else
        echo "\nUnsuccessfully mounted $1..."
    fi


}
start_unmountHDVOUpdate()
{
    (cd ~/workspace/skipline/projects/utils/UpdateCreator && ./unmount_update.sh)
}
start_ORGCatLatestUIConfig()
{
    # ex: start_ORGCatLatestUIConfig CVO_1849
    # requires key added to skipline account on ORG
    if [ $# -lt 1 ]; then
        echo "Usage: start_ORGCatLatestUIConfig [cvo_id]" >&2
        return 1
    fi
    local cvo_id="$1"

    ssh -J burner@apollo.skip-line.com skipline@reportgen2-online.skip-line.com "
    for file in \$(find /var/www/rg2web/media/datafiles/$cvo_id -type f -iregex '.*\.sklData' -printf '%T@ %p\n' | sort -n --reverse | cut -d' ' -f2-); do
        zcat \$file | grep --max-count=1 'UIConfig' && break
    done" | jq -j '."70"."UIConfig"'
}
start_ORGDownload()
{
#    ex: start_ORGDownload CVO_1261 2025/03/15 '*sklData'
    local cvo_id="$1"
    local YYYYslashMMslashDD="$2"
    local pattern="$3"
    local output_location="/tmp/$cvo_id"

    # Various checks which give feedback if there is a syntax issue
    if [ $# -eq 0 ]; then
        # Provide info if there are no arguments
        echo -e "No arguments provided. Usage is:\n\t${FUNCNAME[0]} <CVO_ID> <YYYY/MM/DD> <Pattern>"
        echo -e "Example:\n\t${FUNCNAME[0]} CVO_1261 2025/03/15 '*sklData'"
        return 1
    elif [[ ! "$cvo_id" =~ ^CVO_[0-9]+$ ]]; then
        # Check that CVO ID is only a number
        echo -e "CVO ID must be in the format of \"CVO_####\". You entered: $cvo_id.\n\nBailing..."
        return 1
    elif [[ "$DATE" =~ ^[0-9]{4}/[0-9]{2}/[0-9]{2}$ ]]; then
        # Check the string format of the date provided
        echo -e "Invalid date format. Format needed is: YYYY/MM/DD\n\nBailing..."
        return 1
    elif [ -z "$output_location" ]; then
        # Check that CVO ID is only a number
        echo -e "Output Folder must not be blank.\n\nBailing..."
        return 1
    fi

    # Make directory if it doesn't exist
    if [ ! -d "$output_location" ]; then
        echo "$output_location does not exist. Making now..."
        mkdir "$output_location"
    fi

    echo -e "Attempting to pull data from:\n\tskipline@reportgen2-online.skip-line.com:/var/www/rg2web/media/datafiles/$cvo_id/$YYYYslashMMslashDD/$pattern\nand put it in the output folder:\n\t$output_location\n"

    scp -J burner@apollo.skip-line.com skipline@reportgen2-online.skip-line.com:/var/www/rg2web/media/datafiles/"$cvo_id"/"$YYYYslashMMslashDD"/"$pattern" "$output_location"

    # If successful, ask if they want to open DisplayGCData
    if [ $? -eq 0 ]; then
        read -p "Would you like to open DisplayGCData? " ans;
        if [[ "$ans" =~ ^[Yy]([Ee][Ss])?$ ]]; then
            ~/workspace/skipline/projects/canutils/DisplayGCData/DisplayGCData
        fi
    fi
}
start_EchoTruckInfo()
{
    local sklDataFolderPath="$1"

    # Provide info if there are bad arguments
    if [ $# -ne 1 ]; then
        echo -e "No arguments provided. Usage is:\n\t${FUNCNAME[0]} <PATH_TO_SKLDATA_FOLDER>"
        echo -e "Example:\n\t${FUNCNAME[0]} /tmp/CVO_1486/"
        return 1
    elif [ ! -d "$sklDataFolderPath" ]; then
        echo -e "$sklDataFolderPath does not exist.\n\nBailing..."
        return 1
    fi

    # Keys
    local keyConfig=25
    local keyVersion=26
    local keyTruckID=27
    local keyTruckName=28
    local keyDeviceVersions=64
    local keyNodeID=65
    local keySerialNumber=66
    local keySHA=134

    # IDs
    local idCoreSkipper=26

    # Returns
    local GCVersion="Unknown"
    local truckID="Unknown"
    local truckName="Unknown"
    local skipperVersion="Unknown"
    local skipperSerial="Unknown"
    local shaHex="Unknown"
    local shaDecimal

    # Make the temporary file to put the received json information into
    tmpFile=$(mktemp)

    # This could take some of the work from start_ORGDownload() by scp the data in this function as well
    # ssh -J burner@apollo.skip-line.com -oPort=5754 skipline@reportgen2.skip-line.com

    # We want to get the device skipper information so keep looking until we find a snapshot with that info
    for file in $(find "$sklDataFolderPath" -type f -iregex '.*\.sklData' -printf '%T@ %p\n' | sort -n --reverse | cut -d' ' -f2-); do
        zcat "$file" | grep --max-count=1 "\"$keyNodeID\":$keyVersion" && break;
    done > "$tmpFile"

    # Collect the general system info
    GCVersion=$(jq -j ".\"$keyConfig\".\"$keyVersion\" " "$tmpFile")    # Config/Version
    truckID=$(jq -j ".\"$keyConfig\".\"$keyTruckID\" " "$tmpFile")      # Config/TruckID
    truckName=$(jq -j ".\"$keyConfig\".\"$keyTruckName\" " "$tmpFile")  # Config/TruckName

    # Loop through all of the devices until the core skipper is found and get it's information
    totalDevices=$(jq ".\"$keyConfig\".\"$keyDeviceVersions\" | length" "$tmpFile")

    for (( i=0; i<"$totalDevices"; i++ )); do
        if [[ $(jq ".\"$keyConfig\".\"$keyDeviceVersions\"[$i].\"$keyNodeID\"" "$tmpFile") == "$idCoreSkipper" ]]; then
            skipperVersion=$(jq -j ".\"$keyConfig\".\"$keyDeviceVersions\"[$i].\"$keyVersion\"" "$tmpFile")     # Config/DeviceVersions/Version
            skipperSerial=$(jq -j ".\"$keyConfig\".\"$keyDeviceVersions\"[$i].\"$keySerialNumber\"" "$tmpFile") # Config/DeviceVersions/Serial
            shaDecimal=$(jq -j ".\"$keyConfig\".\"$keyDeviceVersions\"[$i].\"$keySHA\"" "$tmpFile")             # Config/DeviceVersions/SHA
            shaHex=$(printf "%x" "$shaDecimal")
            break;
        fi
    done

    echo -e "
Glass Cockpit Version:  $GCVersion
Truck ID:               $truckID
Truck Name:             $truckName
Skipper Version:        $skipperVersion
Skipper Serial Number:  $skipperSerial
Git SHA:                $shaHex
"

    rm "$tmpFile"
}
start_SendFilesToPrinter()
{
    # Check that there was at least one file provided
    if [ $# -eq 0 ]; then
        echo "Please pass in the name of the files you want to send to the printer";
        return 1;
    fi

    # Check that all of the files exist first
    for file in "$@"; do
        if [ ! -f "$file" ]; then
            echo "$file does not exist";
            return 1;
        fi
    done

    # Ask if the list is correct
    local prompt="---------------------------------\n"
    for file in "$@"; do
        prompt+="$file\n"
    done
    prompt+="---------------------------------\nIs the above file list correct?"
    helper_yes_no_dialog "$prompt" || return 1;

    # put the files onto the printer one at a time
    for file in "$@"; do
        echo "put \"$file\"" | tee | sftp -b - -i ~/.cancfg/id_rsa_cancfg_apollo cancfg@printstation.skip-line.com
    done
}
start_DisplayGCData()
{
    ( ~/workspace/skipline/projects/canutils/DisplayGCData/DisplayGCData) &
}
start_RunGC()
{
    # Check that there was at least one file provided
    if [ $# -eq 0 ]; then
        echo "Please pass the system name of the GC simulator you would like to simulate (must already exist)"
        echo -e "Usage is:\n\t${FUNCNAME[0]} <PATH_TO_GC_FOLDER> [OPTIONAL_CAN_BUS_NUM]\nExample:\n\t${FUNCNAME[0]} SC12_A25119_MANUAL 1"
        return 1
    fi

    # Vars
    sysName=$1
    sysPath=/tmp/supportsim-1000/$sysName
    GCProgram=~/workspace/skipline/projects/GlassCockpit/build/src/GlassCockpit

    # Gather the CAN BUS index if it was passed
    canBusIdx=0
    if [ $# -eq 2 ]; then
        canBusIdx=$(($2))
    fi

    # Check that the simulator folder exists
    if [ -d "$sysPath/dl18/" ]; then
        envPath=$sysPath/dl18/
    elif [ -d "$sysPath/hdvo/" ]; then
        envPath=$sysPath/hdvo/
    else
        echo "Neither $sysPath/hdvo/ nor $sysPath/dl18/ exist. Please make sure the simulator exists..."
        return 1
    fi

    # Check that the GC program exists
    if [ ! -f "$GCProgram" ]; then
        echo "The GC program at $GCProgram does not exist. Please build it..."
        return 1
    fi

    # Actually run the GC program with the provided environment path
    SKLCORE_ROOT="$envPath" CAN_BUS="can$canBusIdx" "$GCProgram"
}
start_MongoEquipmentInfo()
{
    if [ $# -lt 1 ]; then
        echo "Usage: start_MongoEquipmentInfo system_name" 1>&2;
        return 1;
    fi;
    local cvo_id="$(extract_cvo_id "$1")"
    if [ -z "$cvo_id" ]; then
        echo "Failed to extract cvo_id"
        return 1
    fi
    echo '====== SRO ORGS ======'
    mongosh "mongodb+srv://srp-prod.4yw3k.mongodb.net/Skip-Line" --apiVersion 1 --username "$MONGO_USERNAME" --password "$MONGO_PASSWORD" --eval "
    printjson(db.organizations.find({ \"equipment\": \"$cvo_id\" }).toArray())
    " | grep -E '^\s+name: '
    echo '====== EQUIPMENT INFO ======'
    mongosh "mongodb+srv://srp-prod.4yw3k.mongodb.net/Skip-Line" --apiVersion 1 --username "$MONGO_USERNAME" --password "$MONGO_PASSWORD" --eval "
    printjson(db.equipment.find({ \"serial_number\": \"$cvo_id\" }).toArray())
    "
}

start_MongoFindRecordWithDeviceSerialNumber()
{
    if [ $# -lt 1 ]; then
        echo "Usage: start_MongoEquipmentInfo serial" 1>&2;
        return 1;
    fi;

    local serial_number="$1"

    mongosh "mongodb+srv://srp-prod.4yw3k.mongodb.net/Skip-Line" --apiVersion 1 --username "$MONGO_USERNAME" --password "$MONGO_PASSWORD" --eval "
    printjson(db.equipment.find({ \"devices\": { \$elemMatch: { \"serial_number\": \"$serial_number\" } } }).toArray())
    "
}

extract_cvo_id() {
    local folder_name="$(basename $1)"
    local base_dir="$HOME/skiprepo/production/systems"
    local target_dir="$base_dir/$folder_name/variants"
    local cvo_id=""

    if [[ -d "$target_dir" ]]; then
        # Check for logging folder first
        if [[ -f "$target_dir/logging/loggingconfig.json" ]]; then
            cvo_id=$(jq -r '.truckID' "$target_dir/logging/loggingconfig.json")
        elif [[ -f "$target_dir/cellular_hdvo/logging/loggingconfig.json" ]]; then
            cvo_id=$(jq -r '.truckID' "$target_dir/cellular_hdvo/logging/loggingconfig.json")
        fi
    fi

    if [[ -n "$cvo_id" ]]; then
        echo "$cvo_id"
    else
        return 1
    fi
}
code_Projects()
{
    (code ~/workspace/skipline/projects &>/dev/null) &
}
code_Skipper()
{
    (code ~/workspace/skipline/projects/skipper &>/dev/null) &
}
code_GlassCockpit()
{
    (code ~/workspace/skipline/projects/GlassCockpit &>/dev/null) &
}
code_TruckDesigner()
{
    (code ~/workspace/skipline/projects/can-cfg &>/dev/null) &
}
code_CANLogger()
{
    (code ~/workspace/skipline/projects/canutils/CANLogger &>/dev/null) &
}
code_Systems()
{
    (code ~/skiprepo/production/systems &>/dev/null) &
}
code_SkipperSystems()
{
    (code ~/workspace/skipline/projects/skipper/systems &>/dev/null) &
}
code_Simulator()
{
    (code /tmp/supportsim-1000/ && code ~/workspace/SupportSimUtil/mainwindow.py) &
}
code_Bash()
{
    (
        code -n;
        code ~/.bashrc;
        code ~/.bash_aliases;
    ) &
}
code_Legacy()
{
    code ~/skiprepo/legacy;
}
build_TruckDesigner()
{
    cd ~/workspace/skipline/projects/can-cfg || exit;
    ./scripts/command_line_dev_build -q;
    cd - &> /dev/null;
}
build_GlassCockpit()
{
    cd ~/workspace/skipline/projects/GlassCockpit || exit;
    ./scripts/command_line_dev_build -q;
    cd - &> /dev/null;
}
build_Skipper()
{
    cd ~/workspace/skipline/projects/skipper || exit;

    # If --select is passed, then run the select system first
    if [ "$1" == "--select" ]; then
        ./systems/select_system.py
    fi

    ./scripts/command_line_dev_build -q;
    cd - &> /dev/null;
}
sstatus()
{
    # SVN status
    (cd $SYS_DIR; svn status)
}
scommit()
{
    # SVN commit
    # Putting it all in a seperate thread
    (
        cd $SYS_DIR;

        # Check that there was at least one system provided
        if [ $# -eq 0 ]; then
            echo "Please pass in the name of the systems you want to commit";
            return 1;
        fi

        # Check that the systems exist and add them to the systems list
        systems=();
        for system in "$@"; do
            find $SYS_DIR/$system -maxdepth 0 &> /dev/null;

            if [[ "$?" != "0" ]]; then
                echo "$system not found. Aborting...";
                return 1;
            fi
            systems+=($(cd $SYS_DIR; echo "$SYS_DIR/$system"*;));
        done
        systemsStr="${systems[@]}";

        # Create the full message for the SVN commit
        echo "Please provide the commit message below:";
        read -e msg;

        if [ $# -eq 1 ]; then
            fullMsg="$1: $msg";
        else
            fullMsg="$msg";
        fi

        # Perform the commit
        echo -e "\nCommitting...";

        echo "$systemsStr";
        svn commit -m "$fullMsg" $systemsStr;

        # Prompt to upload to Apollo
        read -p "Would you like to upload to Apollo? [y/N] " rspns;

        if [[ "$rspns" =~ ^[Yy]$ ]]; then
            echo -e "\nUploading to Apollo...";
            start_UpdateApollo;
        fi
    )
}
slog()
{
    # SVN log
    (
        cd $SYS_DIR;
        if [ $# -eq 0 ]; then
            svn log -l 10;
        else
            svn log -l "$1";
        fi
    )
}
supdate()
{
    # SVN update
    (cd $SYS_DIR; svn up;)
}
git_branches()
{
    (
        cd $MONO_DIR;
        mono_branch=$(git branch --show-current);
        cd $SIM_DIR;
        sim_branch=$(git branch --show-current);

        echo -e "${_BOLD}Mono-repo branch:${_RESET}\t$mono_branch";
        echo -e "${_BOLD}SupportSimUtil branch:${_RESET}\t$sim_branch";
    )
}
git_new()
{
    if [ ! $# -eq 1 ]; then
        echo "Please provide only one argument, that being the name of the branch to create"
    fi

    (
        cd $MONO_DIR
        git checkout main > /dev/null
        git pull > /dev/null

        # Check to make sure something already made doesn't have an attempt at being readded
        check_remote=$(git branch -r --list "origin/$1")
        check_all=$(git branch -a --list "$1")

        if [[ -n "$check_remote" || -n "$check_all" ]]; then
            echo "There already exists a branch with that name. Exiting..."
            return 1
        fi

        # Create the new branch
        echo -e "Creating the $1 branch in the monorepo directory...\n"
        git checkout -b "$1" > /dev/null

        # Prompt to upload to origin (GitHub)
        read -p "Would you like to push the new branch to GitHub? [y/N] " rspns

        if [[ "$rspns" =~ ^[Yy]$ ]]; then
            echo -e "\nUploading to GitHub...\n"
            git push -u origin "$1" > /dev/null
        fi
    )
}
######## END WORK SECTION #########
