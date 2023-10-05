with source as (
      select * from {{ source('adventure_works_sales', 'CurrencyRate') }}
),
renamed as (
    select
        CurrencyRateID::int as id_currency_rate,
        CurrencyRateDate::datetime as currency_rate_date,
        FromCurrencyCode::varchar(3) as from_currency_code,
        ToCurrencyCode::varchar(3) as to_currency_code,
        AverageRate::double as average_rate,
        EndOfDayRate::double as end_of_day_rate,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed
  