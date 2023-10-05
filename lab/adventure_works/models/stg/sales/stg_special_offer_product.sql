with source as (
      select * from {{ source('adventure_works_sales', 'SpecialOfferProduct') }}
),
renamed as (
    select
        SpecialOfferID::int as id_special_offer,
        ProductID::int as id_product,
        rowguid::varchar as rowguid,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed
  