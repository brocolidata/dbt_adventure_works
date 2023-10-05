with source as (
    select * from {{ source('adventure_works_person', 'Person') }}
),
renamed as (
    select
        BusinessEntityID::int as id_business_entity,
        PersonType::varchar(2) as person_type,
        NameStyle::boolean as name_style,
        Title::varchar(8) as title,
        FirstName::varchar(50) as first_name,
        MiddleName::varchar(50) as middle_name,
        LastName::varchar(50) as last_name,
        Suffix::varchar(10) as suffix,
        EmailPromotion::int as email_promotion,
        AdditionalContactInfo::varchar as additional_contact_info,
        Demographics::varchar as demographics,
        rowguid::varchar as rowguid,
        ModifiedDate::datetime as modified_date
    from source
)
select * from renamed