{{ 
    config(
        materialized='external',
        location="{{ env_var('DWH_DATA') }}/{{ model.config.database }}/{{ model.config.group }}/{{ model.name }}.csv"
    ) 
}}

with orders_stg as (
    select
        id_sales_order,
        order_date,
        due_date,
        ship_date,
        order_status,
        is_online_order,
        sales_order_number,
        purchase_order_number,
        account_number,
        id_customer,
        id_sales_person,
        id_sales_territory,
        id_ship_method,
        id_currency_rate,
        subtotal,
        tax_amt,
        freight,
        total_due
    from {{ ref('stg_sales_order_header') }}
),

ship_method_stg as (
    select
        id_ship_method,
        ship_method_name,
        ship_base,
        ship_rate
    from {{ ref('stg_ship_method') }}

),

joined_commandes as (
    select
        orders_stg.id_sales_order as id_bon_de_commande,
        orders_stg.order_date as date_commande,
        orders_stg.due_date as date_echeance,
        orders_stg.ship_date as date_expedition,
        orders_stg.order_status as statut_commande,
        orders_stg.is_online_order as est_commande_en_ligne,
        orders_stg.sales_order_number as numero_bon_de_commande,
        orders_stg.purchase_order_number as numero_bon_achat,
        orders_stg.id_customer as id_client,
        orders_stg.account_number as numero_compte,
        orders_stg.id_sales_person as id_representant_commercial,
        orders_stg.id_sales_territory as id_territoire,
        ship_method_stg.ship_method_name as methode_expedition,
        ship_method_stg.ship_base as tarif_expedition_minimum,
        ship_method_stg.ship_rate as tarif_expedition_au_kilo,
        orders_stg.id_currency_rate as id_taux_de_change,
        orders_stg.subtotal as sous_total,
        orders_stg.tax_amt as montant_taxes,
        orders_stg.freight as fret,
        orders_stg.total_due as total_commande
    from orders_stg
    left join ship_method_stg using (id_ship_method)

)

select * from joined_commandes