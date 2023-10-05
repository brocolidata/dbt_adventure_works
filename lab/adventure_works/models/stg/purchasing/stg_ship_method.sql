with source as (
    select * from {{ source('adventure_works_purchasing', 'ShipMethod') }}
),
renamed as (
    select
        ShipMethodID::int as id_ship_method,
        Name::varchar(50) as ship_method_name,
        ShipBase::double as ship_base,
        ShipRate::double as ship_rate,
        rowguid::varchar as rowguid,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed