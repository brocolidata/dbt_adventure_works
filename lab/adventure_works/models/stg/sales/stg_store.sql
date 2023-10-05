with source as (
    select * from {{ source('adventure_works_sales', 'Store') }}
),
renamed as (
    select
        BusinessEntityID::int as id_business_entity,
        "Name"::varchar(50) as store_name,
        SalesPersonID::int as id_sales_person,
        Demographics::varchar as demographics,
        rowguid::varchar as rowguid,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed