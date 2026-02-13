# Strategie Acces & Tickets

## Sources d'acces cumulables
- Ticket actif (`FULL` ou `HALF`).
- Campagne marketing active (gratuit total/partiel sur periode).
- Avantage partenariat ecole.
- Exception admin (support, test, moderation).

## Tickets
- `FULL`: acces total selon scope (classe/serie/modules).
- `HALF`: acces partiel (modules limites ou quota).
- Un ticket contient: type, scope, date expiration, canal achat.
- Activation par code unique, genere sur site externe.

## Campagnes marketing
- Type: `FREE_ALL`, `FREE_PARTIAL`, `DISCOUNTED_TICKET`, `BONUS_DAYS`.
- Ciblage: pays, classe, serie, ecole, utilisateur.
- Priorite: campagne > partenariat > ticket > blocage.
- Historique obligatoire pour audit.

## Partenariats lycees
- Contrat avec fenetre de validite.
- Regles possibles:
  - acces complet pour tous les eleves verifies,
  - acces partiel par module,
  - prix ticket reduit sur le site externe.

## Regle de decision (runtime)
1. Evaluer blocages explicites.
2. Evaluer campagnes actives.
3. Evaluer contrat partenariat.
4. Evaluer ticket actif.
5. Retourner droit final + raison.

