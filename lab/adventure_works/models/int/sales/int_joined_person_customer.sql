with customer_stg as (
    select 
        id_customer,
        id_person,
        id_store,
        id_sales_territory,
        account_number
    from {{ ref('stg_customer') }}
),

person_stg as (
    select 
        id_business_entity as id_customer,
        person_type,
        concat_ws(
            ' ',
            first_name,
            middle_name,
            last_name
        ) as full_name
    
    from {{ ref('stg_person') }}
),

customer as (
    select 
        customer_stg.id_customer as id_customer,
        person_stg.person_type as person_type,
        person_stg.full_name as customer_full_name,
        customer_stg.id_store as id_store,
        customer_stg.id_sales_territory as id_sales_territory,
        customer_stg.account_number as account_number
    from customer_stg
    inner join person_stg using (id_customer)
)

select * from customer