#! /bin/bash
# Ensures that dependencies are installed and corrects them if that is not the case.

#space-separated list of required GLOBAL SWIZZIN dependencies (NOT application specific ones)
dependencies="whiptail git sudo curl wget lsof fail2ban apache2-utils vnstat tcl tcl-dev build-essential dirmngr apt-transport-https bc jq sl uuid-runtime net-tools fortune libpam-cracklib"

missing=()
for dep in $dependencies; do
    if ! check_installed "$dep"; then 
        missing+=("$dep")
    fi
done

if [[ ${missing[1]} != "" ]]; then 
    echo_info "Installing the following dependencies: ${missing[*]}"
    apt_install "${missing[@]}"
else
    echo_log_only "No dependencies required to install"
fi