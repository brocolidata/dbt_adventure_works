with source as (
    select * from {{ source('adventure_works_human_resources', 'Employee') }}
),
renamed as (
    select
        BusinessEntityID::int as id_business_entity,
        NationalIDNumber::varchar(15) as national_id_number,
        LoginID::varchar(256) as id_login,
        OrganizationNode::blob as organization_node,
        OrganizationLevel::smallint as organization_level,
        JobTitle::varchar(50) as job_title,
        BirthDate::date as birth_date,
        MaritalStatus::varchar(1) as marital_status,
        Gender::varchar(1) as gender,
        HireDate::date as hire_date,
        SalariedFlag::boolean as is_salaried,
        VacationHours::smallint as vacation_hours,
        SickLeaveHours::smallint as sick_leave_hours,
        CurrentFlag::boolean as is_active,
        rowguid::varchar as rowguid,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed