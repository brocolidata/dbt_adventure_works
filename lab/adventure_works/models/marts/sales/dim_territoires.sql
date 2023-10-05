{{ 
    config(
        materialized='external',
        location="{{ env_var('DWH_DATA') }}/{{ model.config.database }}/{{ model.config.group }}/{{ model.name }}.csv"
    ) 
}}

with joined_sales_territory_country_region as (
    select
        id_sales_territory as id_territoire,
        territory_name as nom_territoire,
        country_region_name as nom_region,
        territory_group as groupe_territorial,
        sales_ytd as ventes_ytd,
        sales_last_year as ventes_annee_precedente,
        cost_ytd as couts_ytd,
        cost_last_year couts_annee_precedente
    from {{ ref('int_joined_sales_territory_country_region') }}
)

select * from joined_sales_territory_country_region