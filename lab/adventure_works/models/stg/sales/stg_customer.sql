with source as (
      select * from {{ source('adventure_works_sales', 'Customer') }}
),
renamed as (
    select        
        CustomerID::int as id_customer,
        PersonID::int as id_person,
        StoreID::int as id_store,
        TerritoryID::int as id_sales_territory,
        AccountNumber::varchar(10) as account_number,
        rowguid::varchar as rowguid,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed
  