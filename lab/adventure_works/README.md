# Using dbt

## Fast dbt
- See [fast_dbt](/docker_build/scripts/fast_dbt/README.md)

## dbt Conventions
- See [dbt Style Guide](dbt_guide.md)

## dbt project structure
```
── dbt_repo                        
   ├── profiles                    
   │   └── profiles.yml            # settings for database connection
   └── src                        # repo for the dbt project
       ├── README.md
       ├── analysis               # 
       ├── data                   #
       ├── dbt_modules            #
       ├── dbt_project.yml        # main settings file
       ├── docs                   # documentation blocks (.md)
       ├── logs
       ├── macros                 #                  
       ├── models                 # models and sources ( .sql, .yml)
       ├── packages.yml           # additional dbt packages
       ├── snapshots
       ├── target                 # compiled files
       └── tests                  # data tests
```



## Basic local dbt usage:

1. Attach shell by running `docker exec -it dbt bash` (skip if you are using the dev environment)
(**N.B: Run dbt commands in the folder containing *dbt_project.yml***)
2. Activate dbt virtualenv (cf. step **3** of **Initialize Goblet project**)
3. Check if the project is valid by running `dbt debug`
3. Install dependencies (specified in *packages.yml*) by running `dbt deps`
4. Follow instructions to **Generate the content of *stg.yml*** (see below) in order to define the sources of your future models
5. Follow instructions to **Stage STG Tables defined in *stg.yml***
6. In */models*, write SQL queries inside `.sql` scripts to create your tables from sources or other tables *(optionally, you can add documentation to your tables and sources in **.yml** files)* 
7. Run `dbt run` to create your tables in the Data Warehouse

## Generate the content of *stg.yml*
1. Fill in the Worksheet *sources* in the Project Google Sheets
2. Attach shell then run the following command (replace *https://docs.google.com/spreadsheets/d/rest_of_the_spreadsheet_id* by the Project Google Sheets URl
```
python3 -m brocolib_utils.fast_dbt.cli
```

## Stage STG Tables defined in *stg.yml* 
*In order to create external tables from files in GCS Bucket (datalake)*
*See [dbt-labs/dbt-external-tables](https://github.com/dbt-labs/dbt-external-tables)*
Run one of the following commands : 
```
# iterate through all source nodes, create if missing, refresh metadata
 dbt run-operation stage_external_sources

# iterate through all source nodes, create or replace (+ refresh if necessary)
 dbt run-operation stage_external_sources --vars "ext_full_refresh: true"

# stage all Snowplow and Logs external sources:
 dbt run-operation stage_external_sources --args "select: snowplow logs"

# stage a particular external source table:
 dbt run-operation stage_external_sources --args "select: snowplow.event"
```


## Stage STG seeds defined in */seeds* 

Run the following command : 
```
dbt seed --select SEED_FILE_WITHOUT_EXTENSION
```


## Generate the *.sql* file content for a table from a source table:
1. Run the following command by replacing :
- **source** by the name of the schema (Postgres) or dataset (BigQuery)
- **stg_table_name** by the name of the table in the **source** 
2. Copy the generated code and paste it into a newly created .sql file
```
dbt run-operation generate_base_model --args '{"source_name": "source", "table_name": "your_table_name"}'
```

## Generate the *.yml* to describe a table
1. Run the following command by replacing :
- **table_name** by the name of the table you want to describe
2. Copy the generated code and paste it into a newly created .yml file
*the table should already exist in the database*
```
dbt run-operation generate_model_yaml --args '{"model_names": ["table_name"], "upstream_descriptions":True}'
```

## Generate the *.yml* to describe ods sources
```
dbt run-operation generate_source --args '{"schema_name": "ods", "database_name": "brocolitest-internal-back", "generate_columns": True}
```

## Remote launch of documentation website
1. Run 
```
python3 -m brocolib_utils.catalog_gen.cli
```

2. Access the website at **https://storage.cloud.google.com/brocoli.tech/index.html**

## Launch locally documentation website
1. Run :
```
dbt docs generate && dbt docs serve --port 4444 --no-browser
```
2. Access the website at **http://localhost:4444**

## Generate ER diagram using dbterd
```
dbterd run -t mermaid --dbt --resource-type source
```
