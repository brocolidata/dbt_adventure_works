{{ 
    config(
        materialized='external',
        location="{{ env_var('DWH_DATA') }}/{{ model.config.database }}/{{ model.config.group }}/{{ model.name }}.csv"
    ) 
}}

with joined_person_customer as (
    select
        id_customer as id_client,
        person_type as type_personne,
        customer_full_name as nom_complet_client,
        id_store as id_revendeur,
        id_sales_territory as id_territoire,
        account_number as numero_client
    from {{ ref('int_joined_person_customer') }} 
)

select * from joined_person_customer