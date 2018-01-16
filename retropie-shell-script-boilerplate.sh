#!/usr/bin/env bash
# [SCRIPT_NAME] (e.g.: script_template.sh)
#
# [SCRIPT_TITLE] (e.g.: RetroPie Shell Script Boilerplate)
# [SCRIPT_DESCRIPTION] (e.g. A template for building shell scripts for RetroPie.)
#
# Author: [AUTHOR] (e.g. hiulit)
# Repository: [REPO_URL] (e.g. https://github.com/hiulit/RetroPie-Shell-Script-Boilerplate)
# License: [LICENSE] [LICENSE_URL] (e.g. MIT https://github.com/hiulit/RetroPie-Shell-Script-Boilerplate/blob/master/LICENSE)
#
# Requirements:
# - RetroPie x.x.x (e.g. RetroPie 4.x.x)
# - [PACKAGE_NAME] (e.g. libav-tools)

# Globals ####################################################################

# If the script is called via sudo, detect the user who called it and the homedir.
user="$SUDO_USER"
[[ -z "$user" ]] && user="$(id -un)"
home="$(eval echo ~$user)"

# If you really need that the script is run by root user (e.g. script called
# from '/etc/rc.local') the approach below can work better to get the homedir
# of the RetroPie user.
# Comment the code above and uncomment the code below.
#home="$(find /home -type d -name RetroPie -print -quit 2>/dev/null)"
#home="${home%/RetroPie}"

readonly RP_DIR="$home/RetroPie"
readonly CONFIG_DIR="/opt/retropie/configs"
readonly SCRIPT_DIR="$(cd "$(dirname $0)" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_TITLE="[SCRIPT_TITLE]"
readonly SCRIPT_DESCRIPTION="[SCRIPT_DESCRIPTION]"
readonly SCRIPT_FULL="$SCRIPT_DIR/$SCRIPT_NAME"

# Other variables that can be useful
#readonly SCRIPT_CFG="$SCRIPT_DIR/[CONFIG_FILE]"
#readonly GIT_REPO="[REPO_URL]"
#readonly SCRIPT_URL="[REPO_URL]/[path/to/script.sh]
#readonly ROMS_DIR="$RP_DIR/roms"


# Variables ##################################################################

# Add your own variables here.


# dialog functions ##########################################################
# If you want to provide dialog boxes similar to those used on retropie_setup
# you can use the functions below.
# See the examples of usage on right above functions declarations.

# adapt it as you wish
BACKTITLE="$SCRIPT_DESCRIPTION"

# dialogMenu example of usage:
#options=( tag1 option1 tag2 option2 N optionN )
#dialogMenu "Text describing the options" "${options[@]}"
function dialogMenu() {
    local text="$1"
    shift
    dialog --no-mouse \
        --backtitle "$BACKTITLE" \
        --cancel-label "Back" \
        --ok-label "OK" \
        --menu "$text\n\nChoose an option." 17 75 10 "$@" \
        2>&1 > /dev/tty
}

# dialogMenuHelp example of usage:
#options=(1 option1 "Help message 1" 2 option2 "Help message 2" N optionN "Help message N")
#dialogMenuHelp "Text explaining the options" "${options[@]}"
function dialogMenuHelp() {
    local text="$1"
    shift
    dialog --no-mouse \
        --backtitle "$BACKTITLE" \
        --cancel-label "Back" \
        --ok-label "OK" \
        --item-help \
        --menu "$text\n\nChoose an option." 17 75 10 "$@" \
        2>&1 > /dev/tty
}

# dialogYesNo example of usage:
#dialogYesNo "Do you want to continue?"
function dialogYesNo() {
    dialog --no-mouse --backtitle "$BACKTITLE" --yesno "$@" 15 75 2>&1 > /dev/tty
}

# dialogMsg example of usage
#dialogMsg "Failed to install package_name. Try again later."
function dialogMsg() {
    dialog --no-mouse --ok-label "OK" --backtitle "$BACKTITLE" --msgbox "$@" 20 70 2>&1 > /dev/tty
}

# dialogInfo example of usage:
#dialogInfo "Please wait. Installing package_name..."
function dialogInfo {
    dialog --infobox "$@" 8 50 2>&1 >/dev/tty
}

# end of dialog functions ###################################################


# Functions ##################################################################

function is_retropie() {
    [[ -d "$home/RetroPie" && -d "$home/.emulationstation" && -d "/opt/retropie" ]]
}


function check_dependencies() {
    if ! which [COMMAND_TO_TEST] > /dev/null; then # (e.g if ! which git > /dev/null)
        echo "ERROR: The [NAME_OF_THE_PACKAGE] package is not installed!" >&2 # (e.g. git)
        echo "Please, install it with 'sudo apt-get install [NAME_OF_THE_PACKAGE]'." >&2 # (e.g. git)
        exit 1
    fi
}


function check_argument() {
    # This method doesn't accept arguments starting with '-'.
    if [[ -z "$2" || "$2" =~ ^- ]]; then
        echo >&2
        echo "ERROR: '$1' is missing an argument." >&2
        echo >&2
        echo "Try '$0 --help' for more info." >&2
        echo >&2
        return 1
    fi
}


# If you are using the config file, uncomment set_config() and get_config().
# USAGE:
# set_config "[KEY]" "[VALUE]" - Sets the VALUE to the KEY in $SCRIPT_CFG.
# get_config "[KEY]" - Returns the KEY's VALUE in $SCRIPT_CFG.

# function set_config() {
#     sed -i "s|^\($1\s*=\s*\).*|\1\"$2\"|" "$SCRIPT_CFG"
#     echo "\"$1\" set to \"$2\"."
# }

# function get_config() {
#     local config
#     config="$(grep -Po "(?<=^$1 = ).*" "$SCRIPT_CFG")"
#     config="${config%\"}"
#     config="${config#\"}"
#     echo "$config"
# }


function usage() {
    echo
    echo "USAGE: $0 [OPTIONS]" # Add 'sudo' before '$0' if the script needs to be run under sudo (e.g. USAGE: sudo $0 [OPTIONS]). Don't change [OPTIONS]! Remember to remove this comment.
    echo
    echo "Use '--help' to see all the options."
    echo
}

# Add your own functions here.

# You can add as many options as you want.
# To add a new option -> Copy and paste from '#H -[O], --[OPTION] ...' until ';;' and make the desired changes.
# If you want to align the descriptions of the options, just play with adding/removing spaces/tabs :P
function get_options() {
    if [[ -z "$1" ]]; then
        usage
        exit 0
    else
        case "$1" in
#H -h, --help                               Print the help message and exit.
            -h|--help)
                echo
                echo "$SCRIPT_TITLE"
                echo "$SCRIPT_DESCRIPTION"
                echo
                echo "USAGE: $0 [OPTIONS]" # Add 'sudo' before '$0' if the script needs to be run under sudo (e.g. USAGE: sudo $0 [OPTIONS]). Don't change [OPTIONS]! Remember to remove this comment.
                echo
                echo "OPTIONS:"
                echo
                sed '/^#H /!d; s/^#H //' "$0"
                echo
                exit 0
                ;;

#H -[O], --[OPTION] (e.g '-v, --version')       [OPTION_DESCRIPTION] (e.g. Show script version.).
            -[O]|--[OPTION])
                # If the option has arguments, uncomment the code below.
                # check_argument "$1" "$2" || exit 1
                # shift

                # Add the functions for this options here.
                ;;
            *)
                echo "ERROR: invalid option '$1'" >&2
                exit 2
                ;;
        esac
    fi
}

function main() {
    if ! is_retropie; then
        echo "ERROR: RetroPie is not installed. Aborting ..." >&2
        exit 1
    fi

    check_dependencies

    # If you need to check if sudo is used, uncomment the code below.
    # Remember to add 'sudo' in 'usage' and 'help'.
    # if [[ "$(id -u)" -ne 0 ]]; then
    #     echo "ERROR: Script must be run under sudo." >&2
    #     usage
    #     exit 1
    # fi

    get_options "$@"
}

main "$@"
