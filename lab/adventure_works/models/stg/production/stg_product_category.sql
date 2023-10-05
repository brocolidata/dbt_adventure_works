with source as (
    select * from {{ source('adventure_works_production', 'ProductCategory') }}
),
renamed as (
    select
        ProductCategoryID::int as id_product_category,
        Name::varchar(50) as product_category_name,
        rowguid::varchar as rowguid,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed