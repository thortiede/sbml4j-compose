#!/bin/bash




function show_usage() {
  echo "Usage: "
  echo "${0} -h | -b | -i | -s {argument}"
  echo "Details:"
  echo "This script is used to either setup the SBML4J volumes, setup the database from database dumps, or backup the databases into a database dump."
  echo "You can either use any one option alone, or use the -i and -s options together."
  echo "  -h : Print this help"
  echo "  -b {argument} :"
  echo "     Backup the current database into the backup files named by the {argument}"
  echo "  -i {argument} :"
  echo "     Install prerequisits for SBML4J."
  echo "     This will recreate the volumes used for SBML4J, the neo4j database and the api documentation."
  echo "  -s {argument} :"
  echo "     Setup the neo4j database from the database dumps from the files named by the {argument}"
  echo " "
  echo "Examples:"
  echo "${0} -i sbml4j.yaml"
  echo "   This will (re)-create the volumes for SBML4J and use sbml4j.yaml as source for the api page"
  echo "${0} -b mydbbackup"
  echo "   This will create a database dump of the neo4j and system database in the files mydbbackup-neo4j.dump and mydbbackup-system.dump respectively"
  echo "${0} -s mydbbackup"
  echo "   This will load a database dump from the neo4j and system database dump files mydbbackup-neo4j.dump and mydbbackup-system.dump."
  echo "   WARNING: Any data currently stored in the database will be overwritten"
  echo "${0} -i sbml4j.yaml -s mydbbackup"
  echo "   This will (re-)create the volumes for SBML4J (as described above) and load the database backup from the database dunmp files as described above."
}

function install(api_def) {
    # Steps to do:
    # Start a docker container running a bash
    # mount the /vol dir to create all prerequisits for neo4j
    # run script inside container that
    #	creates plugin dir
    #   downloads apoc plugin
    #   creates logs dir
    #   creates data dir
    #   creates conf dir
    #   copies conf file in volume
    #   fixes permissions

    # Start a docker container running a bash
    # mount the api-doc volume to create all prerequisits for the api doc 
    # copy api definition file in volume

    # Start a docker container running a bash
    # mount the /sbml4j dir to create all prerequisits for sbml4j
    # basically create the logs folder in the volume
 
    #db_backup=$1
    # 1. create the /vol dir
    #mkdir -p /vol

    # 2a. create /vol/plugins folder
    #mkdir -p /vol/plugins
    # 2b. Download Apoc

    #[ ! -e /vol/plugins/apoc-4.1.0.2-all.jar ] && wget -P /vol/plugins https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/4.1.0.2/apoc-4.1.0.2-all.jar

    # 3. create /vol/logs
    #mkdir -p /vol/logs

    # 4. create /vol/conf
    #mkdir -p /vol/conf
    #[ -e /conf/neo4j.conf ] && cp /conf/neo4j.conf /vol/conf

    # 5. check if data is there and copy it
    #cd /
    #mkdir -p /vol/data
    #[ -e /data/${db_backup} ] && tar x -C /vol/data -z -f /data/${db_backup} --strip 1  

    # 6. Fix permission settings
    #chown -R 7474:7474 /vol
    #chmod 600 /vol/conf/neo4j.conf

}

function setup_db(backup_base_name) {

    # Start neo4j for restoring the neo4j backup (twice: one neo4j, one system)
    # 

}

function backup_db(backup_base_name) {

    # Start neo4j for backing upthe neo4j database (twice: one neo4j, one system)
    # 

}

declare -i i=0

while getopts hb:i:s: flag
do
   case "${flag}" in
       h) show_usage
          exit 0
          ;;
       b) backup_name=${OPTARG}
          do_backup=True
          i=i+100
          #echo "Performing database backup into file: $backup_name"
          ;;
       i) api_def=${OPTARG};
          do_install=True
          i=i+1
          ;;
       s) backup_name=${OPTARG}
          do_setup=True
          #echo "Performing database setup from file: $backup_name"
          i=i+10
          ;;
   esac
done

echo $i

if [ "$i" -lt "1" ]
   then
     echo "No argument given. Please give one or two arguments."
     show_usage
     exit 
elif [ "$i" -lt "10" ]
   then
     echo "Performing installation of prerequisits for running sbml4j with api definition file: $api_def"
     exit
elif [ "$i" -lt "11" ]
   then
     echo "Performing database setup from file: $backup_name"
elif [ "$i" -lt "12" ]
   then
     echo "First: Performing installation of prerequisits for running sbml4j with api definition file: $api_def"
     echo "Then : Performing database setup from file: $backup_name"
     exit
elif [ "$i" -lt "101" ]
   then
     echo "Performing database backup into file: $backup_name"
     exit
fi
         

