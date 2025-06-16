#!/bin/bash

set -e

if [ ! -d "/server/data/data" ]
then
  echo -e "Data folder empty, populating with CoreScripts"
  cp -a /server/CoreScripts/. /server/data/
fi

if [ -z "${TES3MP_SERVER_CONFIGURATION_FILE}" ]; then
    echo "TES3MP_SERVER_CONFIGURATION_FILE is not set."
    printenv | grep 'TES3MP_SERVER_' | while read -r envvar
  do
    envvar_split=$(sed -e "s/TES3MP_SERVER_\([^_]*\)_\([^=]*\)=\(.*\)/\1::\2::\3/" <<< "$envvar")
    declare -a envvar_split_array=(`sed 's/::/ /g' <<< "$envvar_split"`)
    section="${envvar_split_array[0]}"
    variable="${envvar_split_array[1]}"
    value="${envvar_split_array[2]}"
    echo "Applying \"[$section] $variable = $value\" to the configuration"
    sed -i "/\[$section\]/I,/\[/ s/\($variable =\).*$/\1 $value/I" ./tes3mp-server-default.cfg
  done
else
    echo "TES3MP_SERVER_CONFIGURATION_FILE is set to: ${TES3MP_SERVER_CONFIGURATION_FILE}"
    rm -f ./tes3mp-server-default.cfg
    if [ "$(dirname "${TES3MP_SERVER_CONFIGURATION}")" != "$(pwd)" ]; then
      # If not in the current directory, symbolically link it
      ln -s ${TES3MP_SERVER_CONFIGURATION_FILE} ./tes3mp-server-default.cfg
    fi
fi



./tes3mp-server $@
