#!/usr/bin/env bash
########################################################################################################################
# - Description: Ensures the placement of the configuration files into /etc/cas for the execution of the project       #                                                                                                       #
# - Creation Date: 11/10/23                                                                                            #
# - Last Modified: 11/10/23                                                                                            #
# - Author & Maintainer: Aleix Mariné-Tena                                                                             #
# - Email: amarine@iciq.es                                                                                             #
# - Permissions: Needs root permissions explicitly given by sudo (to access the SUDO_USER variable, not present when   #
# logged as root) to install some of the features.                                                                     #
# - Usage: bash ensure_conf.sh                                                                                         #
# - License: GPL v3.0                                                                                                  #
########################################################################################################################

# Find absolute path of directory containing our project
export PROJECT_FOLDER="$(cd "$(dirname "$(realpath "$0")")/.." &>/dev/null && pwd)"

# Remove old config from previous runs
rm -rf /etc/cas

# Copy config
cp -r "${PROJECT_FOLDER}/etc/cas" /etc

# Set permissions for the user invoking sudo
chown ${SUDO_USER}:${SUDO_USER} -R /etc/cas
sudo chmod 776 -R /etc/cas
