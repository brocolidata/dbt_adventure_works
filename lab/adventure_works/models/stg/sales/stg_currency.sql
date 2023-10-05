with source as (
      select * from {{ source('adventure_works_sales', 'Currency') }}
),
renamed as (
    select
        CurrencyCode::varchar(3) as currency_code,
        Name::varchar(50) as currency_name,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed
  