#!/bin/bash

timestamp() {
  date +"%Y-%m-%d_%H-%M-%S"
}

suffix=$1

thetime=timestamp
echo $thetime

# why the fuck does the timestamp not translate into the fucking docker run command. for fucks sake
docker run --interactive --tty --rm --publish=7474:7474 --publish=7687:7687 --mount type=volume,src=sbml4j-compose_sbml4j_neo4j_vol,dst=/vol --mount type=bind,src=$PWD/db_backups,dst=/backups --user="7474:7474" --env NEO4J_CONF=/vol/conf neo4j:4.1.6 neo4j-admin dump --database=neo4j --to=/backups/neo4j-$suffix.dump

docker run --interactive --tty --rm --publish=7474:7474 --publish=7687:7687 --mount type=volume,src=sbml4j-compose_sbml4j_neo4j_vol,dst=/vol --mount type=bind,src=$PWD/db_backups,dst=/backups --user="7474:7474" --env NEO4J_CONF=/vol/conf neo4j:4.1.6 neo4j-admin dump --database=system --to=/backups/system-$suffix.dump
