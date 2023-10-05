from collections import OrderedDict
from io import StringIO
import json
import logging
import pathlib
import os
import pandas as pd
from pandas.io.parsers.readers import is_float
from bs4 import BeautifulSoup
import requests as rq
from ruamel.yaml import YAML
from ruamel.yaml.scalarstring import LiteralScalarString

logger = logging.getLogger('generate_sources')
logger.setLevel(logging.INFO)

ROOT_GITHUB_URL = "https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/databases/adventure-works/oltp-install-script/{table}.csv"
ROOT_URL = "https://dataedo.com/samples/html/AdventureWorks"
BASE_URL = f"{ROOT_URL}/doc/AdventureWorks_2/tables.html"
DBT_SOURCE_PREFIX = "adventure_works"
DBT_PROJECT_DIR = os.getenv('DBT_PROJECT_DIR')


def get_table_columns(table_url: str) -> list:
    df_raw_table = pd.read_html(table_url)[1]
    df_table = df_raw_table.query("Key!=Key")[["Key", "Name", "Data type", "Null", "Attributes", "References", "Description"]]
    return df_raw_table.query("Key!=Key")["Name"].tolist()

def get_table_description_df(table_url: str) -> pd.DataFrame:
    response = rq.get(table_url)
    soup = BeautifulSoup(response.text, features='lxml')
    table_name = soup.find('h1', attrs={"class":"sticky-header"}).get_text()
    table_description = soup.find('div', attrs={"class":"html user-description"}).find('span').get_text()
    columns_table_str = str(soup.find('div', attrs={"data-key":"columns"}).find('table'))
    relations_table_str = str(soup.find('div', attrs={"data-key":"relations"}).find('table'))
    df_raw_col_table = pd.read_html(columns_table_str)[0]
    df_raw_rel_table = pd.read_html(relations_table_str)[0]
    dc_col_rename = {c:c.replace(' ', '_') for c in df_raw_col_table.columns}
    dc_rel_rename = {c:c.replace(' ', '_') for c in df_raw_rel_table.columns}
    df_col = (
        df_raw_col_table
        .rename(columns=dc_col_rename)
        .query("Key!=Key")
        [["Key", "Name", "Data_type", "Null", "Attributes", "References", "Description"]]
    )
    DF_REL_FINAL_COLS = ['fk', 'ref_source', 'ref_table', 'ref_column']
    if not df_raw_rel_table.empty:
        df_rel = (
            df_raw_rel_table
            .rename(columns=dc_rel_rename)
            .query('Foreign_table == @table_name')
        )
        if not df_rel.empty:
            df_rel = (
                df_rel
                .assign(
                    fk = lambda df: df.Join.str.split(' = ', expand=True)[0].str.split('.', expand=True)[2],
                    ref_fqn = lambda df: df.Join.str.split(' = ', expand=True)[1]
                )
                .assign(
                    ref_source = lambda df: df.ref_fqn.str.split('.', expand=True)[0],
                    ref_table = lambda df: df.ref_fqn.str.split('.', expand=True)[1],
                    ref_column = lambda df: df.ref_fqn.str.split('.', expand=True)[2]
                )
                [DF_REL_FINAL_COLS]
            )
        else:
            df_rel = pd.DataFrame(columns=DF_REL_FINAL_COLS)
    else:
        df_rel = pd.DataFrame(columns=DF_REL_FINAL_COLS)

    return df_col, df_rel, table_description


dc_sserver_duckdb_map = {
    'smallint':'smallint',
    'nvarchar(50)':'varchar(50)',
    'datetime':'datetime',
    'int':'int',
    'nvarchar(15)':'varchar(15)',
    'nvarchar(256)':'varchar(256)',
    'hierarchyid':'blob',
    'date':'date',
    'nchar(1)':'varchar(1)',
    'bit':'boolean',
    'uniqueidentifier':'varchar',
    'tinyint':'tinyint',
    'money':'double',
    'xml':'varchar',
    'time(7)':'varchar',
    'nvarchar(60)':'varchar(60)',
    'nvarchar(30)':'varchar(30)',
    'geography':'blob',
    'nvarchar(3)':'varchar(3)',
    'varchar(128)':'varchar(128)',
    'varchar(10)':'varchar(10)',
    'nchar(2)':'varchar(2)',
    'nvarchar(8)':'varchar(8)',
    'nvarchar(10)':'varchar(10)',
    'nvarchar(25)':'varchar(25)',
    'nchar(3)':'varchar(3)',
    'decimal(8, 2)':'double',
    'nchar(6)':'varchar(6)',
    'nvarchar(400)':'varchar(400)',
    'nchar(5)':'varchar(5)',
    'nvarchar(MAX)':'varchar',
    'varbinary(MAX)':'blob',
    'smallmoney':'double',
    'nvarchar(5)':'varchar(5)',
    'nvarchar(3850)':'varchar',
    'decimal(9, 4)':'double',
    'decimal(9, 2)':'double',
    'nvarchar(1024)':'varchar',
    'numeric(38, 6)':'double',
    'varchar(15)':'varchar(15)',
    'nvarchar(128)':'varchar(128)',
    'nvarchar(255)':'varchar(255)',
}



def apply_schema_to_df(df: pd.DataFrame, schema: dict) -> pd.DataFrame:
    for k, v in schema.items():
        if v == 'int64':
            df[k] = df[k].fillna(0)
        df = df.astype({k:v})
    return df.astype(schema)


def get_table_catalog_url_map():
    response = rq.get(BASE_URL)
    soup = BeautifulSoup(response.text, features='lxml')
    all_elements = soup.find_all('td', attrs={"class":"display-name"})
    dc_dbo = {}
    dc_domains = {}
    for element in all_elements:
        url_raw = element.find("a", attrs={"class":"ajax"})["href"]
        url = f"{ROOT_URL}/{'/'.join(url_raw.split('/')[2:])}"
        dbo_name = element.find("a", attrs={"class":"ajax"}).text
        if not dbo_name.startswith("dbo."):
            domain, table_name = dbo_name.split('.')
            if domain in dc_domains:
                dc_domains[domain].append(table_name)
            else:
                dc_domains[domain] = [table_name]
            dc_dbo[table_name] = url

    # ls_to_remove = ["JobCandidate", "BusinessEntity", "BusinessEntityAddress", "BusinessEntityContact",
    #                 "EmailAddress", "Password", "PersonPhone", "PhoneNumberType",
    #                 "Document", "Illustration", "ProductDescription", "ProductModel", "ProductPhoto", "ProductReview"]
    # for table in ls_to_remove:
    #     dc_dbo.pop(table)
    return dc_dbo, dc_domains



def get_columns_duckdb_type_map(df_table):
    return {row.Name:row.duckdb_data_type for row in df_table.itertuples()}


def get_external_location(df_col, table_name):
    
    external_location_str =  LiteralScalarString(
        "read_csv(\n"
        f"""  '{{{{ env_var("ADVENTURE_WORKS_SOURCE_URL") }}}}/{table_name}.csv',\n"""
        f"  columns={json.dumps(get_columns_duckdb_type_map(df_col))},\n"
        r"  sep='\t'"
        "\n)"
    )

    return external_location_str


def get_source_columns_ls(df_col, df_rel):
    ls_cols = []
    ls_fks = df_rel.fk.to_list()
    for col in df_col.itertuples():
        dc_col = {
            "name" :col.Name,
            "data_type": col.duckdb_data_type,
            "description": LiteralScalarString(col.Description)
        }
        if col.Name in ls_fks:
            relation = df_rel.query('fk == @col.Name').iloc[0]
            dbt_source = f"{DBT_SOURCE_PREFIX}_{relation.ref_source.lower()}"
            dc_col["tests"] = [{
                "relationships":{
                    "to": f"source('{dbt_source}', '{relation.ref_table}')",
                    "field": relation.ref_column
                }
            }]

        # if not is_float(col.References):
        #     source_ref, table_ref = col.References.split('.')
        #     if is_float(col.Description):
        #         col_ref = "BusinessEntityID"
        #     elif "Foreign key to" in col.Description:
        #         col_ref = col.Description.split('.')[-2]
        #     else:
        #         col_ref = f"{table_ref}Code"
        #     source = f"{DBT_SOURCE_PREFIX}_{source_ref.lower()}"
        #     dc_col["tests"] = [{
        #         "relationships":{
        #             "to": f"source('{source}', '{table_ref}')",
        #             "field": col_ref
        #         }
        #     }]
        ls_cols.append(dc_col)
    return ls_cols


def get_source_description(
    df_col, 
    df_rel,
    table_name, 
    table_description
):
    dc_source = OrderedDict()
    dc_source["name"] = table_name
    dc_source["description"] = LiteralScalarString(table_description)
    dc_source["meta"] =  {
        "external_location":get_external_location(df_col, table_name),
        "formatter": "oldstyle"
    }
    dc_source["columns"] = get_source_columns_ls(df_col, df_rel)
    return dc_source


def prepare_source_dict(dbt_source_name, domain):
    dc_sources = OrderedDict()
    dc_source = OrderedDict()
    dc_source["name"] = dbt_source_name
    dc_source["description"] = f"Adventure Works data for the {domain} domain"
    dc_source["tables"] = []
    return dc_sources, dc_source


def object_to_yaml_file(obj:dict|OrderedDict, options={}) -> str:
    yaml = get_yaml_class()
    with open() as string_stream:
        yaml.dump(obj, string_stream, **options)
        output_str = string_stream.getvalue()
    return output_str


def get_yaml_class():
    yaml = YAML()
    yaml.Representer.add_representer(
        OrderedDict, 
        yaml.Representer.represent_dict
    )
    return yaml


def load_source_file(dc_sources, group_name, options={}):
    path = pathlib.Path(DBT_PROJECT_DIR, 'models', 'stg', group_name, 'sources.yml')
    if not path.parent.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
    yaml = get_yaml_class()
    with open(path, 'w') as file_buffer:
        yaml.dump(dc_sources, file_buffer, **options)


def get_table_domain_map(dc_domains):
    dc_map = {}
    for domain, domain_tables in dc_domains.items():
        dc_map.update(
            {table:domain for table in domain_tables}
        )
    return dc_map


if __name__ == "__main__":
    DOMAIN_TO_GENERATE = "Purchasing"
    dbt_source_name = f"{DBT_SOURCE_PREFIX}_{DOMAIN_TO_GENERATE.lower()}"
    dc_dbo, dc_domains = get_table_catalog_url_map()
    dc_table_domain = get_table_domain_map(dc_domains)
    logger.info('Successfully fetched catalog data')
    dc_sources, dc_source = prepare_source_dict(dbt_source_name, DOMAIN_TO_GENERATE)
    for table_name in dc_domains[DOMAIN_TO_GENERATE]:
        logger.info(f'Processing {table_name}..')
        table_url = dc_dbo[table_name]
        df_col, df_rel, table_description = get_table_description_df(table_url)
        df_col["duckdb_data_type"] = df_col["Data_type"].map(dc_sserver_duckdb_map)
        dc_source["tables"].append(
            get_source_description(
                df_col=df_col, 
                df_rel=df_rel,
                table_name=table_name,
                table_description=table_description
            )
        )
    dc_sources["sources"] = [dc_source]
    load_source_file(dc_sources, DOMAIN_TO_GENERATE.lower())
