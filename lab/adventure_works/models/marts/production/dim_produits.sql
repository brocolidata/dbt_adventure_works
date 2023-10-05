{{ 
    config(
        materialized='external',
        location="{{ env_var('DWH_DATA') }}/{{ model.config.database }}/{{ model.config.group }}/{{ model.name }}.csv"
    ) 
}}

with product_stg as (
    select
        id_product,
        product_name,
        product_number,
        is_manufactured_in_house,
        product_color,
        safety_stock_level,
        reorder_point,
        standard_cost,
        list_price,
        product_size,
        size_unit_measure_code,
        product_weight,
        weight_unit_measure_code,
        days_to_manufacture,
        product_line,
        product_class,
        product_style,
        id_product_subcategory,
        id_product_model,
        sell_start_date,
        sell_end_date,
        discontinued_date
    from {{ ref('stg_product') }}
    where is_sellable is true
),

product_category_stg as (
    select
        id_product_category,
        product_category_name
    from {{ ref('stg_product_category') }}
),

product_subcategory_stg as (
    select
        id_product_subcategory,
        id_product_category,
        product_subcategory_name,
    from {{ ref('stg_product_subcategory') }}
),

unit_measure_stg as (
    select
        unit_measure_code,
        unit_measure_name
    from {{ ref('stg_unit_measure') }}
),

joined_products as (
    select 
        product_stg.id_product as id_produit,
        product_stg.product_name as nom_produit,
        product_stg.product_number as numero_produit,
        product_stg.is_manufactured_in_house as est_manufacture,
        product_stg.product_color as couleur_produit,
        product_stg.safety_stock_level as niveau_stock_securite,
        product_stg.reorder_point as niveau_stock_alerte,
        product_stg.standard_cost as cout_standard,
        product_stg.list_price as liste_prix,
        product_stg.product_size as taille_produit,
        size_unit_measure.unit_measure_name as unite_mesure_taille_produit,
        product_stg.product_weight as poids_produit,
        weight_unit_measure.unit_measure_name as unite_mesure_poids_produit,
        product_stg.days_to_manufacture as jours_fabrication,
        product_stg.product_line as gamme_produit,
        product_stg.product_class as classe_produit,
        product_stg.product_style as style_produit,
        product_subcategory_stg.product_subcategory_name as sous_categorie_produit,
        product_category_stg.product_category_name as categorie_produit,
        product_stg.sell_start_date as date_debut_commercialisation,
        product_stg.sell_end_date as date_fin_commercialisation,
        product_stg.discontinued_date as date_arret
    from product_stg
    left join product_subcategory_stg using (id_product_subcategory)
    left join product_category_stg using (id_product_category)
    left join unit_measure_stg as weight_unit_measure
        on product_stg.weight_unit_measure_code = weight_unit_measure.unit_measure_code
    left join unit_measure_stg as size_unit_measure
        on product_stg.size_unit_measure_code = size_unit_measure.unit_measure_code
)

select * from joined_products