#!/bin/bash

set -e

if [ ! -d "/server/data/data" ]
then
  echo -e "Data folder empty, populating with CoreScripts"
  cp -a /server/CoreScripts/. /server/data/
fi

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

./tes3mp-server $@
