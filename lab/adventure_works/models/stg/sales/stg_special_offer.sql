with source as (
      select * from {{ source('adventure_works_sales', 'SpecialOffer') }}
),
renamed as (
    select
        SpecialOfferID::int as id_special_offer,
        "Description"::varchar(255) as special_offer_description,
        "DiscountPct"::double as discount_pct,
        "Type"::varchar(50) as special_offer_type,
        Category::varchar(50) as special_offer_category,
        StartDate::datetime as special_offer_start_date,
        EndDate::datetime as special_offer_end_date,
        MinQty::int as min_qty,
        MaxQty::int as max_qty,
        rowguid::varchar as rowguid,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed
  