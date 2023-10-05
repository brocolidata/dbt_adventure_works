with source as (
      select * from {{ source('adventure_works_sales', 'SalesTerritory') }}
),
renamed as (
    select
        TerritoryID::int as id_sales_territory,
        "Name"::varchar(50) as territory_name,
        CountryRegionCode::varchar(3) as country_region_code,
        "Group"::varchar(50) as territory_group,
        SalesYTD::double as sales_ytd,
        SalesLastYear::double as sales_last_year,
        CostYTD::double as cost_ytd,
        CostLastYear::double as cost_last_year,
        rowguid::varchar as rowguid,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed
  