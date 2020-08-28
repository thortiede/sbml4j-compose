Use this docker compose file to get sbml4j set up and start it using docker containers.

This project uses the following docker images, make sure you have the latest version,
or no version at all (in which case the latest version will be fetched on first startup):

1. alpine
2. neo4j
3. thortiede/sbml4j

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


### 4. Test the system
You can test the service by sending a GET Request to

<http://localhost:8080/sbml4j/dbStatus>

### 5. Example Data and User information

There are two example network available in the database.
Use the user 'pecax' to retrieve or derive from them.

### 6. Drivergenes endpoint

The /drivergenes endpoint will create an overview network for a set of genename
given in the request body. The baseNetworkUUID can be omitted. The Default network
will then be used.

The user you send in the request header will be attributed to the created overview network
and needs to be used to retrieve the network in a subsequent call.

The /drivergenes endpoint returns an networkInventoryItem giving general information
about the created network. The fields "UUID" and "uuid" both hold the UUID that can be used
to retrieve the network using the /networks endpoint.

For details please check the swagger documentation linked below.

### 7. Contact

This project is maintained by Thorsten Tiede.
Contact via the email provided on github and swaggerhub.

### 8. More information

Find more information on SBML4j here:
<https://github.com/thortiede/sbml4j>

Learn about the SBML4j API at Swagger:
<https://app.swaggerhub.com/apis-docs/tiede/sbml4j/1.1.2>
