with source as (
      select * from {{ source('adventure_works_sales', 'SalesOrderDetail') }}
),
renamed as (
    select
        SalesOrderID::int as id_sales_order,
        SalesOrderDetailID::int as id_sales_order_detail,
        CarrierTrackingNumber::varchar(25) as carrier_tracking_number,
        OrderQty::smallint as order_qty,
        ProductID::int as id_product,
        SpecialOfferID::int as id_special_offer,
        UnitPrice::double as unit_price,
        UnitPriceDiscount::double as unit_price_discount,
        LineTotal::double as line_total,
        rowguid::varchar as rowguid,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed
  