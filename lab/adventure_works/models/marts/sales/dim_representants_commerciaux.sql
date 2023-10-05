{{ 
    config(
        materialized='external',
        location="{{ env_var('DWH_DATA') }}/{{ model.config.database }}/{{ model.config.group }}/{{ model.name }}.csv"
    ) 
}}

with joined_person_sales_person as (
    select
        id_sales_person as id_representant_commercial,
        full_name as nom_representant_commercial,
        person_type as type_contact,
        id_sales_territory as id_territoire,
        sales_quota as quota_ventes,
        bonus,
        commission_pct as pct_commission,
        sales_ytd as ventes_ytd,
        sales_last_year as ventes_annee_precedente
    from {{ ref('int_joined_person_sales_person') }}
)

select * from joined_person_sales_person