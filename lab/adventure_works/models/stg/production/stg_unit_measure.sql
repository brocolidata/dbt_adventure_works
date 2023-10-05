with source as (
    select * from {{ source('adventure_works_production', 'UnitMeasure') }}
),
renamed as (
    select
        UnitMeasureCode::varchar(3) as unit_measure_code,
        Name::varchar(50) as unit_measure_name,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed