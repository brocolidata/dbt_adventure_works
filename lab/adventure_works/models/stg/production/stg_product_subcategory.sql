with source as (
    select * from {{ source('adventure_works_production', 'ProductSubcategory') }}
),
renamed as (
    select
        ProductSubcategoryID::int as id_product_subcategory,
        ProductCategoryID::int as id_product_category,
        Name::varchar(50) as product_subcategory_name,
        rowguid::varchar as rowguid,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed