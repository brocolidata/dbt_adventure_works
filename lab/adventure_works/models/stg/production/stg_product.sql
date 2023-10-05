with source as (
    select * from {{ source('adventure_works_production', 'Product') }}
),
renamed as (
    select
        ProductID::int as id_product,
        "Name"::varchar(50) as product_name,
        ProductNumber::varchar(25) as product_number,
        MakeFlag::boolean as is_manufactured_in_house,
        FinishedGoodsFlag::boolean as is_sellable,
        Color::varchar(15) as product_color,
        SafetyStockLevel::smallint as safety_stock_level,
        ReorderPoint::smallint as reorder_point,
        StandardCost::double as standard_cost,
        ListPrice::double as list_price,
        Size::varchar(5) as product_size,
        SizeUnitMeasureCode::varchar(3) as size_unit_measure_code,
        WeightUnitMeasureCode::varchar(3) as weight_unit_measure_code,
        "Weight"::double as product_weight,
        DaysToManufacture::int as days_to_manufacture,
        ProductLine::varchar(2) as product_line,
        Class::varchar(2) as product_class,
        Style::varchar(2) as product_style,
        ProductSubcategoryID::int as id_product_subcategory,
        ProductModelID::int as id_product_model,
        SellStartDate::datetime as sell_start_date,
        SellEndDate::datetime as sell_end_date,
        DiscontinuedDate::datetime as discontinued_date,
        rowguid::varchar as rowguid,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed