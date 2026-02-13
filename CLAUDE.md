# EduQuest Execution Manual

## Priorite produit
EduQuest doit accompagner l'eleve de maniere quotidienne: cours, exercices, quiz, epreuves, concours, evenements, orientation, offline fiable.

## Contraintes cle
- Pas de paiement in-app.
- Deblocage par tickets achetes sur site externe.
- Tickets de type `FULL` et `HALF` avec date d'expiration visible.
- Marketing dynamique: gratuit total, gratuit partiel, fenetre temporaire, packs partenaires ecoles.
- Multi-pays: classes, series, examens parametrables sans changer la base.

## Ou chercher l'information
1. Produit: `docs/01-FONCTIONNALITES.md`
2. Acces/tickets: `docs/02-STRATEGIES-ACCES-TICKETS.md`
3. Concours/evenements: `docs/03-CONCOURS-EVENEMENTS.md`
4. Offline: `docs/04-OFFLINE-CONTENU.md`
5. Data/ML: `docs/05-ANALYTICS-ML.md`
6. SQL: `backend/schema/*.sql`

## Standards implementation
- Flutter: architecture par features avec un module `shared`.
- Supabase: RLS active partout, policies minimales par role.
- Contenus: PDF/video/quiz versionnes et telechargeables.
- Analytics: aucun ecran critique sans evenement de tracking.
- Aucun fichier de code ne depasse 100 lignes.
- Toujours reutiliser le code via composants/services partages.
- UI ultra moderne avec base Cupertino quand utile.
- Bleu principal et orange accent obligatoires, dark mode activable.
- Avant toute feature: verifier schema DB et impacts.
- Si schema change: livrer migration incrementale executable d'abord.
- Puis mettre a jour le schema clean complet pour reset base sans conflit.
- Sections sensibles (cours, quiz, epreuves): proteger capture ecran/video.
- Apres chaque fonctionnalite: mini review technique (qualite, risques, impacts).
- Avant toute integration critique, verifier la doc officielle la plus recente sur le web.

## Sequence recommandee pour developper
1. Creer tables + RLS.
2. Generer client Supabase et repositories.
3. Livrer UI feature + logique offline.
4. Brancher analytics.
5. Ajouter test de non-regression (au moins service + parser).
