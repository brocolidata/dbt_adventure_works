with source as (
      select * from {{ source('adventure_works_sales', 'SalesPerson') }}
),
renamed as (
    select
        BusinessEntityID::int as id_business_entity,
        TerritoryID::int as id_sales_territory,
        SalesQuota::double as sales_quota,
        Bonus::double as bonus,
        CommissionPct::double as commission_pct,
        SalesYTD::double as sales_ytd,
        SalesLastYear::double as sales_last_year,
        rowguid::varchar as rowguid,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed
  