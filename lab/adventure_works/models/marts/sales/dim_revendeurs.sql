{{ 
    config(
        materialized='external',
        location="{{ env_var('DWH_DATA') }}/{{ model.config.database }}/{{ model.config.group }}/{{ model.name }}.csv"
    ) 
}}

with store_stg as (
    select 
        id_business_entity as id_revendeur,
        store_name as nom_revendeur,
        id_sales_person as id_representant_commercial,
        demographics as données_demographiques
    from {{ ref('stg_store') }}
)

select * from store_stg