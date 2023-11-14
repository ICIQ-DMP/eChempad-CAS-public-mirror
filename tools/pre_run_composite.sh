#!/usr/bin/env bash
########################################################################################################################
# - Description: Prepares env to run apereo CAS. This file is used to reduce the number of times our password is       #
#   required by sudo                                                                                                   #
# - Creation Date: 18/10/23                                                                                            #
# - Last Modified: 18/10/23                                                                                            #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Email: amarine@iciq.es                                                                                             #
# - Permissions: Needs root permissions explicitly given by sudo (to access the SUDO_USER variable, not present when   #
# logged as root) to install some of the features.                                                                     #
# - Usage: sudo bash pre_run_composite.sh                                                                                         #
# - License: GPL v3.0                                                                                                  #
########################################################################################################################

# Find absolute path of directory containing our project
export PROJECT_FOLDER="$(cd "$(dirname "$(realpath "$0")")/.." &>/dev/null && pwd)"

# Run scripts
bash "${PROJECT_FOLDER}/tools/kill_process_by_port.sh"
bash "${PROJECT_FOLDER}/tools/ensure_conf.sh"
