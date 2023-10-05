with source as (
    select * from {{ source('adventure_works_production', 'BillOfMaterials') }}
),
renamed as (
    select
        BillOfMaterialsID::int as id_bill_of_materials,
        ProductAssemblyID::int as id_product_assembly,
        ComponentID::int as id_component,
        StartDate::datetime as bom_start_date,
        EndDate::datetime as bom_end_date,
        UnitMeasureCode::varchar(3) as unit_measure_code,
        BOMLevel::smallint as bom_level,
        PerAssemblyQty::double as per_assemby_qty,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed