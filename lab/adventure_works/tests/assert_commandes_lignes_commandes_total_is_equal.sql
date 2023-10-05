with commandes_grouped as (
    select
        id_bon_de_commande,
        total_commande
    from {{ ref('fct_commandes') }}
),

lignes_commandes_grouped as (
    select
        id_bon_de_commande,
        sum(total_ligne) as total_lignes
    from {{ ref('fct_lignes_commandes') }}
    group by id_bon_de_commande
),

joined_commandes as (
    select
        commandes_grouped.id_bon_de_commande as id_bon_de_commande,
        commandes_grouped.total_commande as total_commande,
        lignes_commandes_grouped.total_lignes as total_lignes
    from commandes_grouped
    inner join lignes_commandes_grouped using (id_bon_de_commande)
)

select *
from joined_commandes
where total_commande != total_lignes