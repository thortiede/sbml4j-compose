#!/bin/bash

timestamp() {
  date +"%Y-%m-%d_%H-%M-%S"
}

thetime= timestamp
# why the fuck does the timestamp not translate into the fucking docker run command. for fucks sake
docker run --interactive --tty --rm --publish=7474:7474 --publish=7687:7687 --mount type=volume,src=sbml4j-compose_sbml4j_neo4j_vol,dst=/vol --mount type=bind,src=$PWD/db_backups,dst=/backups --user="7474:7474" --env NEO4J_CONF=/vol/conf neo4j:4.1.6 neo4j-admin load --from=/backups/neo4j-$thetime.dump --database=neo4j --force

docker run --interactive --tty --rm --publish=7474:7474 --publish=7687:7687 --mount type=volume,src=sbml4j-compose_sbml4j_neo4j_vol,dst=/vol --mount type=bind,src=$PWD/db_backups,dst=/backups --user="7474:7474" --env NEO4J_CONF=/vol/conf neo4j:4.1.6 neo4j-admin load --from=/backups/system-$thetime.dump --database=system --force
