with sales_person_stg as (
    select 
        id_business_entity,
        id_sales_territory,
        sales_quota,
        bonus,
        commission_pct,
        sales_ytd,
        sales_last_year
    from {{ ref('stg_sales_person') }}
),

person_stg as (
    select 
        id_business_entity,
        person_type,
        concat_ws(
            ' ',
            first_name,
            middle_name,
            last_name
        ) as full_name
    
    from {{ ref('stg_person') }}
),

sales_person as (
    select 
        sales_person_stg.id_business_entity as id_sales_person,
        person_stg.full_name as full_name,
        person_stg.person_type as person_type,
        sales_person_stg.id_sales_territory as id_sales_territory,
        sales_person_stg.sales_quota as sales_quota,
        sales_person_stg.bonus as bonus,
        sales_person_stg.commission_pct as commission_pct,
        sales_person_stg.sales_ytd as sales_ytd,
        sales_person_stg.sales_last_year as sales_last_year
    from sales_person_stg
    inner join person_stg using (id_business_entity)
)

select * from sales_person