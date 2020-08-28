Use this docker compose file to get sbml4j set up and start it using docker containers

### 1. Setup Database
We provide a sample database file derived from KEGG's cancer-related pathways,
enriched with drug-target interactions mostly derived from Drugbank.

Run the following command to extract it into the database volume for neo4j.

    docker-compose up db_setup

To use a different database for your service, replace the file
    database.tar.gz
in the folder database_backups prior to running the above command.

### 2. Get the required plugins
SBML4j uses the APOC plugin for Neo4j. We need to download it, if not already
done. The following command does just that.

    docker-compose up apoc_install

### 3. You are ready to start the service
Start the neo4j database as well as the sbml4j service with:

    docker-compose up --attach-dependencies sbml4j


You can test the service by sending a GET Request to

<http://localhost:8080/sbml4j/dbStatus>

Find more information on SBML4j here:
<https://github.com/thortiede/sbml4j>

Learn about the SBML4j API at Swagger:
<https://app.swaggerhub.com/apis-docs/tiede/sbml4j/1.1.2>
