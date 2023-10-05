{{
    config(
        materialized = 'table',
    )
}}

with days as (

    {{
        dbt_utils.date_spine(
            'day',
            "strptime('01/01/2000','%d/%m/%Y')",
            "strptime('01/01/2027','%d/%m/%Y')"
        )
    }}

),

final as (
    select cast(date_day as date) as date_day
    from days
)

select * from final