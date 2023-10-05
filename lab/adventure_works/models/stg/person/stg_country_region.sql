with source as (
    select * from {{ source('adventure_works_person', 'CountryRegion') }}
),
renamed as (
    select
        CountryRegionCode::varchar(3) as country_region_code,
        "Name"::varchar(50) as country_region_name,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed