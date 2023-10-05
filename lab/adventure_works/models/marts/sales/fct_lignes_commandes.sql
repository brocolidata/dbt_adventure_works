{{ 
    config(
        materialized='external',
        location="{{ env_var('DWH_DATA') }}/{{ model.config.database }}/{{ model.config.group }}/{{ model.name }}.csv"
    ) 
}}

with sales_order_detail_stg as (
    select
        id_sales_order,
        id_sales_order_detail,
        order_qty,
        id_product,
        id_special_offer,
        unit_price,
        unit_price_discount,
        line_total
    from {{ ref('stg_sales_order_detail') }}
),

special_offer_stg as (
    select
        id_special_offer,
        special_offer_description
    from {{ ref('stg_special_offer') }}
),

joined_lignes_commandes as (
    select
        sales_order_detail_stg.id_sales_order as id_bon_de_commande,
        sales_order_detail_stg.id_sales_order_detail as id_ligne_de_commande,
        sales_order_detail_stg.order_qty as quantite_commande,
        sales_order_detail_stg.id_product as id_produit,
        special_offer_stg.special_offer_description as offre_speciale,
        sales_order_detail_stg.unit_price as prix_unitaire,
        sales_order_detail_stg.unit_price_discount as montant_remise,
        sales_order_detail_stg.line_total as total_ligne
    from sales_order_detail_stg
    left join special_offer_stg using (id_special_offer)
)

select * from joined_lignes_commandes