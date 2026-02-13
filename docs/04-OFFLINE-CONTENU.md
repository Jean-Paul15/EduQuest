# Strategie Offline

## Objectif
Permettre l'apprentissage meme avec reseau instable.

## Contenus offline
- Telechargement manuel ou auto des cours PDF.
- Pack par matiere/chapitre.
- Quiz disponibles offline avec synchro differree des resultats.
- Historique progression stocke localement puis synchronise.

## Regles produit
- Afficher taille, statut et date de version de chaque ressource.
- Bloquer capture d'ecran sur ecrans sensibles (cours, quiz, annales).
- Detecter contenu obsolete et proposer mise a jour.

## Technique Flutter
- Index SQLite/Hive pour metadata locale.
- Fichiers via `path_provider` + checksum SHA-256.
- Queue de sync robuste (retry exponentiel).
- Resolution conflit: serveur prioritaire sauf notes brouillon utilisateur.

## Monitoring
- Taux de telechargement reussi.
- Temps moyen de sync.
- Taux de completion offline vs online.

