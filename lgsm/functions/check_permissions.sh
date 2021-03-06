#!/bin/bash
# LGSM check_permissions.sh
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Checks script, files and folders ownership and permissions.

local commandname="CHECK"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_check_ownership(){
	if [ $(find "${rootdir}" -not -user $(whoami)|wc -l) -ne "0" ]; then
		fn_print_fail_nl "Permissions issues found"
		fn_script_log_fatal "Permissions issues found"
		fn_print_infomation_nl "The current user ($(whoami)) does not have ownership of the following files:"
		fn_script_log_info "The current user ($(whoami)) does not have ownership of the following files:"
		{
			echo -e "User\tGroup\tFile\n"
			find "${rootdir}" -not -user $(whoami) -printf "%u\t\t%g\t%p\n"
		} | column -s $'\t' -t | tee -a "${scriptlog}"
		core_exit.sh
	fi
}

fn_check_permissions(){
	if [ -n "${functionsdir}" ]; then
		if [ $(find "${functionsdir}" -type f -not -executable|wc -l) -ne "0" ]; then
			fn_print_fail_nl "Permissions issues found"
			fn_script_log_fatal "Permissions issues found"
			fn_print_infomation_nl "The following files are not executable:"
			fn_script_log_info "The following files are not executable:"
			{
				echo -e "File\n"
				find "${functionsdir}" -type f -not -executable -printf "%p\n"
			} | column -s $'\t' -t | tee -a "${scriptlog}"
			core_exit.sh
		fi
	fi

	# Check rootdir permissions
	if [ -n "${rootdir}" ]; then
		# Get permission numbers on folder under the form 775
		rootdirperm="$(stat -c %a "${rootdir}")"
		# Grab the first and second digit for user and group permission
		userrootdirperm="${rootdirperm:0:1}"
		grouprootdirperm="${rootdirperm:1:1}"
		if [ "${userrootdirperm}" != "7" ] && [ "${grouprootdirperm}" != "7" ]; then
			fn_print_fail_nl "Permissions issues found"
			fn_script_log_fatal "Permissions issues found"
			fn_print_infomation_nl "The following directorys does not have the correct permissions:"
			fn_script_log_info "The following directorys does not have the correct permissions:"
			ls -l "${rootdir}"
			core_exit.sh
		fi
	fi
}

fn_check_ownership
fn_check_permissions