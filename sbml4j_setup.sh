#!/bin/bash

# Default volume name should be prefixed with sbml4j-compose
default_volume_prefix=sbml4j-compose
# Default api defintion file name
default_api_def=sbml4j.yaml

function show_usage() {
  echo "Usage: "
  echo "${0} -h | -b | -i | -s | -p {argument}"
  echo "Details:"
  echo "This script is used to either setup the SBML4J volumes, setup the database from database dumps, or backup the databases into a database dump."
  echo "You can either use any one option alone, or use the -i and -s options together."
  echo "  -h : Print this help"
  echo "  -b {argument} :"
  echo "     Backup the current database into the backup files named by the {argument}"
  echo "  -i :"
  echo "     Install prerequisits for SBML4J."
  echo "     This will recreate the volumes used for SBML4J, the (empty) neo4j database and the api documentation using the default api-documentation file ${default_api_doc} found in the api_doc subfolder."
  echo "  -a : {argument} :"
  echo "     Used only in conjunction with -i to provide the filename of an alternative api-documentation file, which has to be placed in the api_doc subfolder. "
  echo "  -s {argument} :"
  echo "     Setup the neo4j database from the database dumps from the files named by the {argument}"
  echo "  -p {argument} :"
  echo "     Use {argument} as prefix for the volumes created, i.e. argument_sbml4j_service_vol"
  echo "     Use in conjuction with the -b, -i, -s flags."
  echo " "
  echo "Examples:"
  echo "${0} -i :"
  echo "   This will (re)-create the volumes for SBML4J and use the default api definition file ${default_api_def} as source for the api page"
  echo "${0} -i -a myapidef.yaml :"
  echo "   This will (re)-create the volumes for SBML4J and use the provided api definition file myapidef.yaml as source for the api page"
  echo "${0} -b mydbbackup"
  echo "   This will create a database dump of the neo4j and system database in the files mydbbackup-neo4j.dump and mydbbackup-system.dump respectively"
  echo "${0} -s mydbbackup"
  echo "   This will load a database dump from the neo4j and system database dump files mydbbackup-neo4j.dump and mydbbackup-system.dump."
  echo "   WARNING: Any data currently stored in the database will be overwritten"
  echo "${0} -i -s mydbbackup"
  echo "   This will (re-)create the volumes for SBML4J (as described above) and load the database backup from the database dunmp files as described above."
  echo "${0} -i -s mydbbackup -p my-compose"
  echo "   This will (re-)create the volumes with names my-compose_sbml4j_neo4j_vol instead of the default name sbml4j-compose_sbml4j_neo4j_vol for SBML4J (as described above) and load the database backup from the database dunmp files as described above."
  echo "   This needs to be used when you want to use these volumes in a different compose setup"
}

function install() {
    api_def=$1
    prefix_name=$2
    # Steps to do:
    # Start a docker container running a shell
    # mount the /vol dir to create all prerequisits for neo4j
    # run script inside container that
    #	creates plugin dir
    #   downloads apoc plugin
    #   creates logs dir
    #   creates data dir
    #   creates conf dir
    #   copies conf file in volume
    #   fixes permissions
    echo "Creating volume for neo4j database"
    docker run --rm --detach --mount type=bind,src=${PWD}/scripts,dst=/scripts --mount type=bind,src=${PWD}/conf,dst=/conf --mount type=volume,src=${prefix_name}_sbml4j_neo4j_vol,dst=/vol alpine /scripts/setup_neo4j.sh
    # Start a docker container running a shell
    # mount the api-doc volume to create all prerequisits for the api doc 
    # copy api definition file in volume
    echo "Creating volume for api documentation"
    if [ -a ${PWD}/api_doc/$api_def ] 
        then
          echo "Using API definition file $api_def"
          docker run --rm --detach --mount type=bind,src=${PWD}/api_doc,dst=/api --mount type=volume,src=${prefix_name}_sbml4j_api_doc_vol,dst=/definition alpine cp /api/$api_def /definition/sbml4j.yaml
        else
          echo "Could not find provided API definition file $api_def, trying the default file ${default_api_def}"
          docker run --rm --detach --mount type=bind,src=${PWD}/api_doc,dst=/api --mount type=volume,src=${prefix_name}_sbml4j_api_doc_vol,dst=/definition alpine cp /api/${default_api_def} /definition/sbml4j.yaml
    fi
    # Start a docker container running a shell
    # mount the /sbml4j dir to create all prerequisits for sbml4j
    # basically create the logs folder in the volume
    echo "Creating volume for the sbml4j service"
    docker run --rm --detach --mount type=volume,src=${prefix_name}_sbml4j_service_vol,dst=/logs alpine touch /logs/root.log
}

function setup_db() {
    backup_base_name=$1
    prefix_name=$2
    # Start neo4j for restoring the neo4j backup (twice: one neo4j, one system)
    docker run --interactive --tty --rm --publish=7474:7474 --publish=7687:7687 --mount type=volume,src=${prefix_name}_sbml4j_neo4j_vol,dst=/vol --mount type=bind,src=$PWD/db_backups,dst=/backups --user="7474:7474" --env NEO4J_CONF=/vol/conf neo4j:4.1.6 neo4j-admin load --from=/backups/${backup_base_name}-neo4j.dump --database=neo4j --force    
# 
    docker run --interactive --tty --rm --publish=7474:7474 --publish=7687:7687 --mount type=volume,src=${prefix_name}_sbml4j_neo4j_vol,dst=/vol --mount type=bind,src=$PWD/db_backups,dst=/backups --user="7474:7474" --env NEO4J_CONF=/vol/conf neo4j:4.1.6 neo4j-admin load --from=/backups/${backup_base_name}-system.dump --database=system --force    

}

function backup_db() {
    backup_base_name=$1
    prefix_name=$2
    # Start neo4j for backing upthe neo4j database (twice: one neo4j, one system)
    #
    docker run --interactive --tty --rm --publish=7474:7474 --publish=7687:7687 --mount type=volume,src=${prefix_name}_sbml4j_neo4j_vol,dst=/vol --mount type=bind,src=$PWD/db_backups,dst=/backups --user="7474:7474" --env NEO4J_CONF=/vol/conf neo4j:4.1.6 neo4j-admin dump --database=neo4j --to=/backups/${backup_base_name}-neo4j.dump 

    docker run --interactive --tty --rm --publish=7474:7474 --publish=7687:7687 --mount type=volume,src=${prefix_name}_sbml4j_neo4j_vol,dst=/vol --mount type=bind,src=$PWD/db_backups,dst=/backups --user="7474:7474" --env NEO4J_CONF=/vol/conf neo4j:4.1.6 neo4j-admin dump --database=system --to=/backups/${backup_base_name}-system.dump 
}

declare -i i=0

while getopts a:hb:is:p: flag
do
   case "${flag}" in
       a) api_def=${OPTARG}
          is_custom_api_def=True
	  ;;
       h) show_usage
          exit 0
          ;;
       b) backup_name=${OPTARG}
          do_backup=True
          i=i+100
          #echo "Performing database backup into file: $backup_name"
          ;;
       i) do_install=True
          i=i+1
          ;;
       s) backup_name=${OPTARG}
          do_setup=True
          #echo "Performing database setup from file: $backup_name"
          i=i+10
          ;;
       p) prefix_name=${OPTARG}
          is_prefix_set=True
          ;;
   esac
done

echo $i

function check_api_def() {
  # Do we have a custom api defintion file
  if [ "$is_custom_api_def" = True ]
    then
      echo "Using custom API definition file ${api_def}"
    else
      echo "Using default API defintion file ${default_api_def}"
      api_def=${default_api_def}
   fi
}

function check_prefix_name() {
  # Do we have a custom prefix set
  if [ "$is_prefix_set" = True ]
    then
      echo "Using custom prefix name ${prefix_name}"
    else
      echo "Using default prefix name ${default_volume_prefix}"
      prefix_name=$default_volume_prefix
  fi
}

if [ "$i" -lt "1" ]
   then
     echo "No argument given. Please give one or two arguments."
     show_usage
     exit 
elif [ "$i" -lt "10" ]
   then
     echo "Performing installation of prerequisits for running sbml4j"
     check_api_def
     check_prefix_name
     install $api_def $prefix_name
     exit
elif [ "$i" -lt "11" ]
   then
     echo "Performing database setup from file: $backup_name"
     check_prefix_name  
     setup_db $backup_name $prefix_name
     exit
elif [ "$i" -lt "12" ]
   then
     echo "Performing installation of prerequisits for running sbml4j"
     check_api_def
     check_prefix_name
     install $api_def $prefix_name
     echo "Restoring database state from backup files with base-name: ${backup_name}"
     setup_db $backup_name $prefix_name
     exit
elif [ "$i" -lt "101" ]
   then
     echo "Performing database backup into files with base-name: $backup_name"
     check_prefix_name
     backup_db $backup_name $prefix_name
     exit
fi
         

