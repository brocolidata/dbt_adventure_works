with sales_territory_stg as (
    select
        id_sales_territory,
        territory_name,
        country_region_code,
        territory_group,
        sales_ytd,
        sales_last_year,
        cost_ytd,
        cost_last_year
    from {{ ref('stg_sales_territory') }}
),

country_region_stg as (
    select
        country_region_code,
        country_region_name
    from {{ ref('stg_country_region') }}
),

joined_sales_territory as (
    select
        sales_territory_stg.id_sales_territory as id_sales_territory,
        sales_territory_stg.territory_name as territory_name,
        country_region_stg.country_region_name as country_region_name,
        sales_territory_stg.territory_group as territory_group,
        sales_territory_stg.sales_ytd as sales_ytd,
        sales_territory_stg.sales_last_year as sales_last_year,
        sales_territory_stg.cost_ytd as cost_ytd,
        sales_territory_stg.cost_last_year as cost_last_year
    from sales_territory_stg
    inner join country_region_stg using (country_region_code)
)

select * from joined_sales_territory