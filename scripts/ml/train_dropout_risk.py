"""Squelette du futur classifieur de risque de décrochage.

CE SCRIPT NE FAIT ENCORE RIEN D'UTILE — c'est un point de départ pour quand
il y aura assez de données réelles pour entraîner un modèle avec un sens
(voir RUACHEDU_AI_AUTOMATION_VISION.md, section "Ce qui reste à construire").

Pourquoi ce script existe en dehors de Supabase (GitHub Actions, pas une
Edge Function) : les Edge Functions Supabase ont un budget de 2 secondes de
temps CPU par appel. Une simple agrégation SQL (comme la calibration de
difficulté, voir backend/schema/184_*.sql) tient largement dans ce budget
car le calcul est fait par Postgres, pas par la fonction elle-même. Mais un
entraînement itératif de modèle (Random Forest, gradient boosting) est un
calcul CPU-bound qui dépasserait probablement cette limite dès que le
nombre de lignes/arbres devient réaliste. GitHub Actions n'a pas cette
limite (jusqu'à 6h par job en plan gratuit) — c'est le "serveur à part"
dont on a besoin UNIQUEMENT pour cette étape, pas pour le reste du produit.

Ce qui manque avant de remplir ce script :
1. Suffisamment de lignes dans `quiz_attempts`/`app_events` pour définir un
   vrai signal de "décrochage" (ex. : élève inactif >14 jours après avoir
   été actif) — actuellement quasi nul.
2. Une décision produit sur la définition exacte du label (à quel moment
   un élève est-il considéré "à risque" ?).
3. Les features d'entrée : probablement tirées des CSV déjà exportés par
   le pipeline DataOps (bucket `ml-datasets`, voir
   backend/schema/183_ml_dataset_export_governance.sql) plutôt que de
   re-agréger depuis zéro.

Flux prévu une fois rempli :
  GitHub Actions (planifié) -> ce script -> lit les CSV du bucket
  ml-datasets via l'API Storage -> entraîne -> écrit les scores dans une
  table Postgres (pas le modèle appelé en direct — voir la note sur le
  "batch scoring" dans RUACHEDU_AI_AUTOMATION_VISION.md) -> l'app/le
  backoffice lit cette table directement, zéro appel de modèle en temps réel.
"""

import os

from supabase import create_client


def main() -> None:
    url = os.environ["SUPABASE_URL"]
    key = os.environ["SUPABASE_SERVICE_ROLE_KEY"]
    client = create_client(url, key)

    # TODO (quand il y aura des données) :
    # 1. Télécharger les derniers CSV pertinents depuis le bucket
    #    `ml-datasets` (client.storage.from_("ml-datasets").list(...) /
    #    .download(...)).
    # 2. Construire les features + le label de décrochage.
    # 3. Entraîner (ex. sklearn.ensemble.RandomForestClassifier ou une
    #    simple régression logistique — pas plus complexe que nécessaire).
    # 4. Écrire les scores dans une table Postgres dédiée (ex.
    #    `dropout_risk_scores(profile_id, score, computed_at)`), en un seul
    #    batch upsert — jamais d'appel de modèle en temps réel depuis l'app.
    print("train_dropout_risk: rien à faire pour l'instant (pas de données).")


if __name__ == "__main__":
    main()
