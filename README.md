# SBML4j Docker compose system

Welcome to the docker-compose system for managing a SBML4j installation.
SBML4j is a Java Spring-based application for persisting biological models described in the Systems Biology Markup Language (SBML) in a neo4j Graph Database.
It offers various network mapping options for creating network representations of the loaded models.
These networks can be annotated with arbitrary data on nodes and edges, filtered by nodes and edges and their repspective types and are returned by the service in the versatile GraphML format.
In addition various types of graph algorithms and searches can be performed.
To find out more about SBML4j head over to https://github.com/thortiede/sbml4j

This Repository offers a docker-compose based setup for initialising, running and managing a SBML4j installation including the neo4j database instance needed to store the networks and run the graph algorithms.
 
We rely on the following docker images to install and run the service:
1. alpine
2. neo4j:4.1.6
3. thortiede/sbml4j:1.0

The SBMl4j service does not come with preloaded models.
To learn more about how to load a database, check the section below. TODO: Add link to loading.

To learn more about the REST-API endpoints and experiment with them, you can head over to
http://sbml4j.informatik.uni-tuebingen.de
to learn more.

### 0. Prerequisits
The following requirements need to be met to install and run sbml4j-compose on your local machine:

1. An up-to date docker daemon needs to be running
2. Around 4 GB of disk-space available
3. Have the ports 8080, 7474, 7687, 8989 available in your docker-setup (if you need those ports otherwise they can be configured in the docker-compose.yaml file, or the neo4j configuration file in conf/neo4j.conf)

### 1. Initialisation
To install and run a local version of sbml4j-compose follow the steps below:

#### 1.1 Clone repository
First, clone this repository to a desired location on your local machine:

    git clone https://github.com/thortiede/sbml4j-compose.git

#### 1.2 Run the setup script
In order for the components of sbml4j-compose to run, we need to create several volumes first.
This can be done using the provided script as follows:
In the main folder of the cloned repository execute
    
    ./sbml4j.sh -i

This will create all necessary volumes using default options which should be all you need.
To learn more about the options for initialisation, run:

    ./sbml4j.sh -h

This will show you the help information of the provided script, giving details on the various options.

In case you are on a Microsoft(R) Windows(R)-based operating system, this install script will not work for you.
Unfortunately at this time we do not provide a pre-built installation script for Microsoft(R) Windows(R) or other non-linux based operating systems.
For now your only option is to manually edit and run the *docker run* commands needed:

1. Setup the volume for the neo4j database (Replace the ${PWD} directives with your local folders and the ${prefix_name} by the current folder in all small letters (i.e. sbml4j-compose)) 

        docker run --rm --detach --mount type=bind,src=${PWD}/scripts,dst=/scripts --mount type=bind,src=${PWD}/conf,dst=/conf --mount type=volume,src=${prefix_name}\_sbml4j_neo4j_vol,dst=/vol alpine /scripts/setup_neo4j.sh

2. Setup the volume for the api-documentation page (again replace as above, and in addition replace ${api_def} with *sbml4j.yaml* or your custom api-definition file if you made changes):

        docker run --rm --detach --mount type=bind,src=${PWD}/api_doc,dst=/api --mount type=volume,src=${prefix_name}\_sbml4j_api_doc_vol,dst=/definition alpine cp /api/$api_def /definition/sbml4j.yaml

3. Setup the volume for the sbml4j service (replace as above)

        docker run --rm --detach --mount type=volume,src=${prefix_name}\_sbml4j_service_vol,dst=/logs alpine touch /logs/root.log

This should leave you with three volumes prefixed with the folder-name in lower-case (i.e. sbml4j-compose), which is all you need to start the service.

If you have trouble completing this step, feel free to reach out to us via the Issue Tracker here on github.
We are happy to help you troubleshoot.
If you are willing to help implement a Windows(R) compatible version of the *sbml4j.sh* script let us know and we are happy to get you started in contributing to this project.


### 2. Starting and stopping the service
To start sbml4j service run:

    docker-compose up --attach-dependencies sbml4j

or, to not attach the console at all:

    docker-compose up --detach sbml4j

Be advised that the console provides valuable output about the operation of SBML4j and it is therefore encouraged to attach to the output of sbml4j.
As the neo4j database takes a couple of seconds to start and we currently can not manually wait on it to be available, the sbml4j service will keep restarting until the database is up.

To shutdown the system again use:

    docker-compose down

either in a separate terminal window (but same directory of course)
or use the same terminal if you ran it with *--detach*

### 3. Test the system
You can test the service by sending a GET request to

<http://localhost:8080/sbml4j/dbStatus>

### 4. Backup the database
You can create a backup of the last used database. Shutdown the system then run:

    ./sbml4j.sh -b myname

This will create two dump files in the local *db_backups* directory that are prefixed with *myname*

### 5. Restore a previously save database backup
To restore a database backup you created earlier, shutodwn the system and run:

    ./sbml4j.sh -r myname

This will overwrite the current database with the dump found in the backups prefixed with *myname*

### 6. API information
Once running the sbml4j-compose services provide an interactive API-Documentation to try out the various features and learn about the options.
You can navigate to this swagger-based documentation by visiting the following url in your browser:

    http://localhost:8080/sbml4j/api

When you at one point have loaded your database and want to enable easier use of this page, you can copy the provided *sbml4j.yaml* api defintion file to create your own version.
In there replace the uuids of the examples with actual uuids of your networks in the database to make the examples work out-of-box.
Be sure to provide your custom api definition file on setting up the volumes and remember to first create backup of your database.
After setting up the new environment, you can restore your backup and your /api endpoint should now work with your own database.
If you feel the install script can use a separate option to only update the api-definition file loaded, feel free to fork this repository and open a pull request with the addition.
We are more than happy to assist you in contributing to this project.

### 7. Setting up a database
After initialising and starting sbml4j-compose for the first time, the database will be empty and therefore not contain any models or networks.
You need to upload SBML-files and create network-mappings from these models.
The following sections will guide you through the process of downloading KEGG pathway maps, translating them to SBML and uploading them to this service.
Then a network mapping will be created and for demonstration purposes a Drug-Target file (which you will have to get from Drugbank.ca yourself due to licensing) will be uploaded to the service, cerating an annotated version of the aforementioned network-mapping containig this data.
This database will then replicate the sample database that you can find at:

> https://sbml4j.informatik.uni-tuebingen.de

This sample database consists of 61 KEGG pathways related to cancer and all changes you make to this instance will be reset every night.
Of course your own local version of the database will not be reset nightly.
Due to licensing constraints we can however not provide you with a pre-built database containing these pathways.


#### 7.1 Communicating with the SBML4j service

The following instructions provide examples for the communication with the REST interface of SBML4j using curl and python.
Alternatively you can use a tool of your choice to issue GET and POST http requests to the SBML4j service, like Postman.
You can find the API definition for initialising the requests in your tool of choice at https://github.com/kohlbacherlab/sbml4j-compose/api_doc/sbml4j.yaml

Please note, that file-names, argument values and UUIDs used are only for demonstration pruposes  and need to replaced with the actual values from your installation.
Also note, that the '\' character in the examples below is used to signify line breaks to make the blocks more readable and might need to be removed before executing the snippets, depending on your system.

To use the python code examples you need python 3 and  install the 'pysbml4j' python package:

```bash
pip install pysbml4j
```

Then use it in your python environment of choice with:

```python
import pysbml4j

client = pysbml4j.Sbml4j()
```

If you are not running the service on you local system, you need to configure pysbml4j accordingly:

```python
import pysbml4j
from pysbml4j import Configuration

client = pysbml4j.Sbml4j(Configuration("http://mysbml4jhost:8080"))
```

We will need to store uuids of pathways created from the uploaded SBML models.
In the python examples below we will use the following list variable for this:

```python
pathwayUUIDs = []
```

For more details see the pysbml4j documentation at https://github.com/kohlbacherlab/pysbml4j .

---

#### 7.2 Get the KEGG pathway files
[Section KEGG Pathway Maps used in the demo version](#kegg-pathway-maps-used-in-the-demo-version) shows the pathway identifiers of the KEGG pathways used in this publication.
KEGG provides their own markup language files for their pathways.
You can download these kgml files directly from their website (kegg.jp) or through their API.
Make sure you understand the license requirements before starting the download (see https://www.kegg.jp/kegg/rest/ for details).

#### 7.3 Translate pathway files
In order for SBML4j to be able to process the KEGG pathway models they need to be translated to the SBML format.
We used the KEGGtranslator version 2.5 \[[1](#keggtranslator)\] for this.
Please find more info on KEGGtranslator here: http://www.cogsys.cs.uni-tuebingen.de/software/KEGGtranslator/.
Go to http://www.cogsys.cs.uni-tuebingen.de/software/KEGGtranslator/downloads/index.htm and download the version 2.5 executable jar file, which you can run using your local java runtime installation.
We used the following command line options for translating the pathway maps in addition to providing input and output directories for the kgml and sbml files respectively:

	--format SBML_CORE_AND_QUAL 
	--remove-white-gene-nodes TRUE 
	--autocomplete-reactions TRUE 
	--gene-names FIRST_NAME 
	--add-layout-extension FALSE 
	--use-groups-extension FALSE 
	--remove-pathway-references TRUE

#### 7.4 Upload models to SBML4j
Make sure the sbml4j-compose system is initialised and running before continuing with the next steps.

By issuing a POST request to the '/sbml' endpoint one or multiple SBML formatted xml files can be uploaded to SBML4j.
For best performance we recommend uploading the model files one by one or in small chunks of 5 models or less.
Choose the same organism, source and version parameters for all pathway maps to ensure proper integration in the next step.
For details on the RESTful interface visit https://app.swaggerhub.com/apis-docs/tiede/sbml4j/1.1.7

An illustrative  curl command for uploading SBML models to a local service is shown below (you can upload multiple files at once by providing multiple *-F files=@* parameters to the curl command, but can also just use one at a time) :
```bash
curl -v \
     -F files=@/absolute/path/to/sbml/model/file1.xml \
     -F files=@/absolute/path/to/sbml/model/file2.xml \
     -F "organism"="hsa" \
     -F "source"="KEGG" \
     -F "version"="97.0" \ 
     -o response.file \
   http://localhost:8080/sbml4j/sbml
```
We redirect the response of the service here into the file 'response.file' using the '-o' option.
This file will then contain a json-formatted response containing basic information about the uploaded model(s).
Be sure to at least save the provided 'uuid' (or 'UUID', they are identical) for each model as we will need those later.

Using the pysbml4j package uploading SBML models with python is as easy as:

```python
resp = client.uploadSBML([/absolute/path/to/sbml/model/file1.xml, 
                          /absolute/path/to/sbml/model/file2.xml], 
                          "hsa", 
                          "KEGG",
                          "97.0")
print("The UUID of pathway in file1.xml is {}, of file2.xml it is {}"
      .format(resp[0].get("uuid"), resp[1].get("uuid")))
pathwayUUIDs.add(resp[0].get("uuid"))
pathwayUUIDs.add(resp[1].get("uuid"))
```

Please note that the files provided need to be in a list, even when uploading only a single file as is shown here:

```python
resp = client.uploadSBML([/absolute/path/to/sbml/model/onlyfile.xml], "hsa", "KEGG", "97.0")
```

#### 7.5 Create pathway collection
A network mapping always refers to one pathway instance in the database.
In order to build network mappings for multiple KEGG pathways we combine all entities, relations and reactions in a collection pathway element which can be used subsequently to generate network mappings.
The endpoint /pathwayCollection accepts a POST request with a JSON formatted body containing the elements: name, description and sourcePathwayUUIDs.
Name and description are used as pathwayIdString and pathwayDescription respectively.
The field sourcePathwayUUIDs has to be an array of character strings, each string being one UUID of a pathway that shall be added to the collection element.

```bash
curl -v \
     -H "Content-Type: application/json" \
     -d '{"name":"KEGG61_97.0", \
          "description":"This Collection contains 61 cancer-related pathways", \
          "sourcePathwayUUIDs":["909520db-8ca9-40df-bffe-af9e48e93c48", \
                                "9d959b42-f1da-4061-960b-4b58e1ba3c16" \
                               ] \
         }' \
     -o response.pwcoll \
   http://localhost:8080/sbml4j/pathwayCollection 
```

A simple python call making use of pysbml4j can look like this:
```python
collUUID = client.createPathwayCollection("KEGG61-97.0", 
                  "This Collection contains 61 cancer-related pathways", 
                  pathwayUUIDs
           )
print(collUUID)
```
The endpoint returns the UUID of the created collection pathway, which can be used in the following calls to create the network mappings.

#### 7.6 Create network mappings 
To create the network mappings from a pathway a POST request to the /mapping endpoint has to be issued.
The UUID of the pathway is part of the URL as can be seen here:

```bash
curl -v \
     -d "mappingType"="PATHWAYMAPPING" \
     -d "networkname"="PWM-KEGG61" \
     -o response.mapping \
   http://localhost:8080/sbml4j/mapping/b6da7dc5-4dc4-4991-85c0-5ab75e2bf929
```

```python
resp = client.mapPathway(collUUID, "PATHWAYMAPPING", "PWM-KEGG61")
print("The created mapping has the uuid: {}".format(resp.get("uuid")))
```


The last part of the url (b6da7dc5-4dc4-4991-85c0-5ab75e2bf929) is the collUUID generated in the previous step. Be sure to fill in the UUID of your installation when creating the pathway collection.
The UUIDs are generated by SBML4j and will differ every time you run this procedure.

The artifical mapping type 'PATHWAYMAPPING' can be used to not restrict the elements or relations being mapped and will map every entity, relation and reaction into a network mapping instance.
Such a network mapping has been used for the SBM4j-demo to allow for the most broad view on the network context of the genes of interest.

#### 7.7 Prepare the Drugbank csv file
You can find the drugtarget information used at: https://go.drugbank.com/releases/latest#protein-identifiers
You will need a free account on drugbank.ca to gain access to this file, which is released under the 'Creative Common’s Attribution-NonCommercial 4.0 International License.'
You will have to agree to these terms and conditions to continue with the next steps described here.
We used the 'Drug target identifiers' file for all drug groups to get a broad view on available and possible drugs and the genes and geneproducts they target.
In order to reproduce the results found in the publication two preprocessing steps need to be performed:
  1. Filter out all rows that are not targeting genes in Humans (column 'Species').
  2. Consolidate rows with the same 'ID' into one row, combining the elements in the 'Drug IDs' of all those rows into one.

Here we provide an exemplary R script to perform Step 2 above:

```R
csv <- read.csv("all.csv", header=TRUE, stringsAsFactors = FALSE)
csv <- csv[order(csv$Name),]

newcsv <- csv[0,]

i <- 1
j <- 2

drugids <- csv[i,"Drug.IDs"]

while(j<=nrow(csv) && i <= (nrow(csv)-1)) {
  gene1 <- csv[i,"Name"]
  gene2 <- csv[j,"Name"]
  species1 <- csv[i,"Species"]
  species2 <- csv[j,"Species"]
  if(gene1 == gene2 && 
     (is.na(csv[i,"Species"])||is.na(csv[j,"Species"]) || species1 == species2)){

    drugids <- paste(drugids, as.character(csv[j,"Drug.IDs"]),sep=";")

    j <- j+1
  }
  else{
    newcsv[nrow(newcsv) + 1,] = list(csv[i,"ID"],
                                     csv[i,"Name"],
                                     csv[i,"Gene.Name"],
                                     csv[i,"GenBank.Protein.ID"],
                                     csv[i,"GenBank.Gene.ID"],
                                     csv[i, "UniProt.ID"],
                                     csv[i, "Uniprot.Title"],
                                     csv[i, "PDB.ID"],
                                     csv[i, "GeneCard.ID"],
                                     csv[i, "GenAtlas.ID"],
                                     csv[i, "HGNC.ID"],
                                     csv[i,"Species"],
                                     drugids)
    i <- j
    j <- j+1
    
    drugids <- csv[i,"Drug.IDs"]
  }
}
    

write.csv(newcsv,"all_hsa_cleaned.csv", row.names = FALSE)
```

#### 7.8 Add the Drugbank csv file to the network mappings
Using the csv upload functionality of SBML4j arbitrary data can be annotated onto network nodes.
The endpoint expects a 'type' parameter, giving a character string describing the type of annotation that is added, in our example the term 'Drugtarget' is used, as the csv marks every genesymbol given as a drug target for the provided list of 'Drug IDs'.

Please note, that since there can be multiple Drugs targeting the same gene or gene-product, the annotation-names will include a numbering scheme in addition to the column names given in the csv file.

Make sure to set the 'networkname' to "Overview-Base" (case-sensitive).
SBML4j is configured by default to use the network with this name as basis for calculating the networks using the /overview-endpoint by default.
If you want to use a different name, make sure to also change the appropriate config parameter in the 'docker-compose.yaml' file.

You can use the curl command to upload a csv file and annotate the created network mapping with the contained data:
```bash
curl -v \
     -F upload=@all_hsa_cleaned.csv \
     -F "type"="Drugtarget" \
     -F "networkname"="Overview-Base" \
     -o response.drugbank \
   http://localhost:8080/sbml4j/networks/a68645cb-f3bb-49d3-b05f-7f6f05debba3/csv
```

The uuid in the url (here a68645cb-f3bb-49d3-b05f-7f6f05debba3 as example) is the uuid of the *PATHWAYMAPPING* created in [Step 7.6 Create network mappings](#76-create-network-mappings) and can be found in the response.mapping file created in that section using the curl command. Be sure to replace the uuid shown here with your own uuid as it is specific to your database.

The python package also offers this functionality:
```python
net = client.getNetworkByName("PWM-KEGG61")
net.addCsvData("all_hsa_cleaned.csv", "Drugtarget", 
               networkname="Overview-Base")
```

Now your installation of SBML4j should contain the same base network-database that can be found in the demo-version at 

> https://sbml4j.informatik.uni-tuebingen.de


#### 7.9. Save the network database to reset your networks in the future
Before backing up the network database you need to stop the service with

    docker-compose down

Then you can use the provided script to backup the database: 

```
./sbml4j.sh -b kegg61-base
```

This will create two '.dump' files in the **db_backups** folder containing the database backup you just created.

#### 7.10 Restoring the state of the database
Before restoring the network database you need to stop the service with

    docker-compose down

Then you can revert your database back to the previously saved state by using:

```
./sbml4j.sh -r kegg61-base 
```

---
### 8. KEGG Pathway Maps used in the demo version
Here is a list of the KEGG pathway maps used in the SBML4j Demo-version.
The KEGG Release used is: 97.0+/02-16, Feb 21.

- hsa03320 PPAR signaling pathway
- hsa04010 MAPK signaling pathway
- hsa04012 ErbB signaling pathway
- hsa04014 Ras signaling pathway
- hsa04015 Rap1 signaling pathway
- hsa04020 Calcium signaling pathway
- hsa04022 cGMP-PKG signaling pathway
- hsa04024 cAMP signaling pathway
- hsa04060 Cytokine-cytokine receptor interaction
- hsa04064 NF-kappa B signaling pathway
- hsa04066 HIF-1 signaling pathway
- hsa04068 FoxO signaling pathway
- hsa04070 Phosphatidylinositol signaling system
- hsa04071 Sphingolipid signaling pathway
- hsa04072 Phospholipase D signaling pathway
- hsa04080 Neuroactive ligand-receptor interaction
- hsa04110 Cell cycle
- hsa04115 p53 signaling pathway
- hsa04150 mTOR signaling pathway
- hsa04151 PI3K-Akt signaling pathway
- hsa04152 AMPK signaling pathway
- hsa04210 Apoptosis
- hsa04218 Cellular senescence
- hsa04310 Wnt signaling pathway
- hsa04330 Notch signaling pathway
- hsa04340 Hedgehog signaling pathway
- hsa04350 TGF-beta signaling pathway
- hsa04370 VEGF signaling pathway
- hsa04371 Apelin signaling pathway
- hsa04390 Hippo signaling pathway
- hsa04510 Focal adhesion
- hsa04512 ECM-receptor interaction
- hsa04520 Adherens junction
- hsa04630 JAK-STAT signaling pathway
- hsa04915 Estrogen signaling pathway
- hsa05200 Pathways in cancer
- hsa05202 Transcriptional misregulation in cancer
- hsa05203 Viral carcinogenesis
- hsa05204 Chemical carcinogenesis
- hsa05205 Proteoglycans in cancer
- hsa05206 MicroRNAs in cancer
- hsa05210 Colorectal cancer
- hsa05211 Renal cell carcinoma
- hsa05212 Pancreatic cancer
- hsa05213 Endometrial cancer
- hsa05214 Glioma
- hsa05215 Prostate cancer
- hsa05216 Thyroid cancer
- hsa05217 Basal cell carcinoma
- hsa05218 Melanoma
- hsa05219 Bladder cancer
- hsa05220 Chronic myeloid leukemia
- hsa05221 Acute myeloid leukemia
- hsa05222 Small cell lung cancer
- hsa05223 Non-small cell lung cancer
- hsa05224 Breast cancer
- hsa05225 Hepatocellular carcinoma
- hsa05226 Gastric cancer
- hsa05230 Central carbon metabolism in cancer
- hsa05231 Choline metabolism in cancer
- hsa05235 PD-L1 expression and PD-1 checkpoint pathway in cancer

---
### 8. Contact

This project is developed at the University if Tuebingen and is currently maintained by Thorsten Tiede.
Contact via the email provided on github or the Issue Tracker.

### 9. More information

Find more information on SBML4j here:
<https://github.com/thortiede/sbml4j>

Learn about the SBML4j API at Swagger:
<https://app.swaggerhub.com/apis-docs/tiede/sbml4j/1.1.7>

### References
#### KEGGtranslator
\[1\] Wrzodek C, Dräger A, Zell A. KEGGtranslator: visualizing and converting the KEGG PATHWAY database to various formats. Bioinformatics. 2011 Aug 15;27(16):2314-5.
