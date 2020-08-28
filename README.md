Use this docker compose file to get sbml4j set up and start it using docker containers

### 1. Setup Database
Put database backup file (database.tar.gz) in folder database_backups
Then run the following command to extract it into the database volume for neo4j

    docker-compose up db_setup

### 2. Get the required plugins
SBML4j uses the APOC plugin for Neo4j

    docker-compose up apoc_install

### 3. You are ready to start the service
Starts the neo4j databse as well as the sbml4j service

    docker-compose up sbml4j


You can test the service by sending a GET Request to

<http://localhost:8080/sbml4j/dbStatus>

Find more information on SBML4j here:
<https://github.com/thortiede/sbml4j>

Learn about the SBML4j API at Swagger:
<https://app.swaggerhub.com/apis-docs/tiede/sbml4j/1.1.2>
