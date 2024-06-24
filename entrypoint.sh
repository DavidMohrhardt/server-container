#!/bin/bash

set -e

if [ ! -d "/server/data/data" ]
then
  echo -e "Data folder empty, populating with CoreScripts"
  cp -a /server/CoreScripts/. /server/data/
fi

printenv | grep 'TES3MP_SERVER_' | while read -r envvar
do
  declare -a envvar_exploded=(`echo "$envvar" | sed 's/=/ /g'`)
  section_and_variable="${envvar_exploded[0]}"
  value="${envvar_exploded[@]:1}"
  section_and_variable=$(echo "$section_and_variable" \
    | sed -e 's/TES3MP_SERVER_\([^_]*\)_\(.*\)/\1:\2/' \
    | tr '[:upper:]' '[:lower:]' \
    | awk -F "_" \
      '{printf "%s", $1; \
        for(i=2; i<=NF; i++) printf "%s", toupper(substr($i,1,1)) substr($i,2); print"";}')
  declare -a section_and_variable_exploded=(`echo "$section_and_variable" | sed 's/:/ /g'`)
  section="${section_and_variable_exploded[0]}"
  variable="${section_and_variable_exploded[1]}"
  echo "Applying \"[$section] $variable = $value\" to the configuration"
  sed -i \
     "/\[$section\]/I,/\[/ s/\($variable =\).*$/\1 $value/" \
    ./tes3mp-server-default.cfg
done

./tes3mp-server $@
