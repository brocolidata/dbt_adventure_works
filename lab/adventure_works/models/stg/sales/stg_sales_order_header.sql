with source as (
      select * from {{ source('adventure_works_sales', 'SalesOrderHeader') }}
),
renamed as (
    select
        SalesOrderID::int as id_sales_order,
        RevisionNumber::tinyint as revision_number,
        OrderDate::datetime as order_date,
        DueDate::datetime as due_date,
        ShipDate::datetime as ship_date,
        "Status"::tinyint as order_status,
        OnlineOrderFlag::boolean as is_online_order,
        SalesOrderNumber::varchar(25) as sales_order_number,
        PurchaseOrderNumber::varchar(25) as purchase_order_number,
        AccountNumber::varchar(15) as account_number,
        CustomerID::int as id_customer,
        SalesPersonID::int as id_sales_person,
        TerritoryID::int as id_sales_territory,
        BillToAddressID::int as id_bill_to_address,
        ShipToAddressID::int as id_ship_to_address,
        ShipMethodID::int as id_ship_method,
        CreditCardID::int as id_credit_card,
        CreditCardApprovalCode::varchar(15) as credit_card_approval_code,
        CurrencyRateID::int as id_currency_rate,
        SubTotal::double as subtotal,
        TaxAmt::double as tax_amt,
        Freight::double as freight,
        TotalDue::double as total_due,
        Comment::varchar(128) as comment,
        rowguid::varchar as rowguid,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed
  