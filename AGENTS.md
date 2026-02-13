# EduQuest Agent Guide

## But
Livrer vite des features Flutter + Supabase pour EduQuest (Togo d'abord, Afrique ensuite) avec forte flexibilite metier.

## Demarrage
1. Lire `CLAUDE.md`.
2. Lire `docs/06-ROADMAP.md`.
3. Ouvrir seulement le fichier lie a la demande (feature ou bug).

## Arborescence de reference
- `docs/00-ARCHITECTURE.md`: vision technique.
- `docs/01-FONCTIONNALITES.md`: catalogue fonctionnel.
- `docs/02-STRATEGIES-ACCES-TICKETS.md`: monetisation sans paiement in-app.
- `docs/03-CONCOURS-EVENEMENTS.md`: concours, parrainage, evenements.
- `docs/04-OFFLINE-CONTENU.md`: mode hors ligne.
- `docs/05-ANALYTICS-ML.md`: tracking et data.
- `backend/schema/*.sql`: schema SQL source de verite.

## Regles de travail
- Chaque nouveau fichier markdown doit faire moins de 100 lignes.
- Aucun nouveau fichier de code (Dart, SQL, TS, etc.) ne doit depasser 100 lignes.
- Favoriser du code reutilisable (widgets/services/shared), pas de duplication.
- Appliquer de bons principes de codage: simplicite, responsabilite unique, nommage explicite, faible couplage.
- Pour les integrations sensibles (OAuth, notifications, widgets natifs, paiement, securite), faire une recherche web approfondie sur docs officielles avant implementation.
- Eviter les gros blocs abstraits: documenter en decisions concretes.
- Favoriser une architecture feature-first partagee, pas de surcouche "clean architecture" stricte.
- Interface ultra moderne obligatoire, avec usage Cupertino quand pertinent.
- Palette produit imposee: bleu principal + orange accent; theme sombre activable.
- Avant toute nouvelle feature: analyser d'abord le schema de base de donnees existant.
- Si une feature implique un changement schema: fournir d'abord SQL de migration incrementale.
- Ensuite mettre a jour le schema clean complet pour permettre un reset total sans erreur.
- Pour sections sensibles (cours, quiz, epreuves): activer protection capture ecran/video.
- Apres chaque fonctionnalite: faire une mini review technique (risques + impacts).
- Toute feature doit definir:
  - droits d'acces (ticket, role, campagne),
  - comportement offline,
  - evenements analytics.

## Roles plateforme
- `admin`: pilote global.
- `editor`: publie contenus/epreuves/corrections.
- `teacher`: anime cours live, quiz, correction.
- `student`: consomme, participe, progresse.
- `partner_manager`: gere partenariats ecoles.

## Definition of done
- Migration SQL ajoutee ou mise a jour.
- Ecran Flutter livre (web + mobile responsive).
- Logs analytics minimaux poses.
- Documentation `docs/` mise a jour.
