# Changelog

Toutes les modifications notables apportées à **Mon Accueil TV** sont documentées dans ce fichier.

---

## [v4.2.2] - 2026-11-16
### Modifications
- Indicateur système dynamique en temps réel selon la RAM libre : vert « Système fluide » (≥ 35 %), orange « Mémoire chargée » (20–34 %), rouge « RAM saturée (▶⏸) » (< 20 %).

---

## [v4.2.1] - 2026-11-16
### Modifications
- Purge RAM manuelle en 1 clic via la touche Play/Pause (ou 0), mise à jour immédiate de la RAM affichée et message de retour précis (Mo libérés + nombre d'applis fermées).

---

## [v4.2.2] - 2026-11-16
### Modifications
- Indicateur système dynamique en temps réel selon la RAM libre : vert « Système fluide » (≥ 35 %), orange « Mémoire chargée » (20–34 %), rouge « RAM saturée (▶⏸) » (< 20 %).

---

## [v4.2.0] - 2026-11-16
### Modifications
- Optimisation majeure des performances TV : purge instantanée ciblée au lancement d'une app (?keep=), détection rapide des apps actives via app_launcher -S, réglage noyau vm.swappiness=60 / vfs_cache_pressure=80 et désactivation de HbbTV (-40 Mo RAM).

---

## [v4.2.2] - 2026-11-16
### Modifications
- Indicateur système dynamique en temps réel selon la RAM libre : vert « Système fluide » (≥ 35 %), orange « Mémoire chargée » (20–34 %), rouge « RAM saturée (▶⏸) » (< 20 %).

---

## [v4.2.1] - 2026-11-16
### Modifications
- Purge RAM manuelle en 1 clic via la touche Play/Pause (ou 0), mise à jour immédiate de la RAM affichée et message de retour précis (Mo libérés + nombre d'applis fermées).

---

## [v4.2.2] - 2026-11-16
### Modifications
- Indicateur système dynamique en temps réel selon la RAM libre : vert « Système fluide » (≥ 35 %), orange « Mémoire chargée » (20–34 %), rouge « RAM saturée (▶⏸) » (< 20 %).

---

## [v4.1.0] - 2026-11-16
### Ajouté
- Affichage discret de la version de l'application (`v4.1.0`) dans la barre inférieure de l'interface.
- Génération automatique et suivi structuré des changelogs (`CHANGELOG.md` + script `scripts/update_changelog.ps1`).

### Corrigé
- **Purge RAM & survie au redémarrage** (`e20edde`) : contournement du blocage CORS sur `/exec` en passant par le plugin persistant `mon-accueil-metrics` (`/plugins/mon-accueil-metrics/api/purge`), avec fermeture automatique des applications lourdes (Netflix `GIBBON_MAIN`, Canal+, FreeTV/OQEE, TF1+, france.tv, Prime Video...) après 2 minutes d'inactivité sur l'accueil.
- Correction des chemins relatifs dans `scripts/deploy_launcher.ps1`.

---

## [v4.2.2] - 2026-11-16
### Modifications
- Indicateur système dynamique en temps réel selon la RAM libre : vert « Système fluide » (≥ 35 %), orange « Mémoire chargée » (20–34 %), rouge « RAM saturée (▶⏸) » (< 20 %).

---

## [v4.2.1] - 2026-11-16
### Modifications
- Purge RAM manuelle en 1 clic via la touche Play/Pause (ou 0), mise à jour immédiate de la RAM affichée et message de retour précis (Mo libérés + nombre d'applis fermées).

---

## [v4.2.2] - 2026-11-16
### Modifications
- Indicateur système dynamique en temps réel selon la RAM libre : vert « Système fluide » (≥ 35 %), orange « Mémoire chargée » (20–34 %), rouge « RAM saturée (▶⏸) » (< 20 %).

---

## [v4.2.0] - 2026-11-16
### Modifications
- Optimisation majeure des performances TV : purge instantanée ciblée au lancement d'une app (?keep=), détection rapide des apps actives via app_launcher -S, réglage noyau vm.swappiness=60 / vfs_cache_pressure=80 et désactivation de HbbTV (-40 Mo RAM).

---

## [v4.2.2] - 2026-11-16
### Modifications
- Indicateur système dynamique en temps réel selon la RAM libre : vert « Système fluide » (≥ 35 %), orange « Mémoire chargée » (20–34 %), rouge « RAM saturée (▶⏸) » (< 20 %).

---

## [v4.2.1] - 2026-11-16
### Modifications
- Purge RAM manuelle en 1 clic via la touche Play/Pause (ou 0), mise à jour immédiate de la RAM affichée et message de retour précis (Mo libérés + nombre d'applis fermées).

---

## [v4.2.2] - 2026-11-16
### Modifications
- Indicateur système dynamique en temps réel selon la RAM libre : vert « Système fluide » (≥ 35 %), orange « Mémoire chargée » (20–34 %), rouge « RAM saturée (▶⏸) » (< 20 %).

---

## [v4.0.1] - 2026-11-12
### Ajouté
- **Pensée & Citation philosophique du jour** (`33f1dc9`) : remplacement de la salutation par 64 citations philosophiques et inspirantes tirées sans remise via un deck **Fisher-Yates** stocké en `localStorage` (zéro répétition avant la fin du cycle).
- Mise à jour de la documentation (`README.md`) avec la nouvelle fonctionnalité (`90e6905`).

---

## [v4.2.2] - 2026-11-16
### Modifications
- Indicateur système dynamique en temps réel selon la RAM libre : vert « Système fluide » (≥ 35 %), orange « Mémoire chargée » (20–34 %), rouge « RAM saturée (▶⏸) » (< 20 %).

---

## [v4.2.1] - 2026-11-16
### Modifications
- Purge RAM manuelle en 1 clic via la touche Play/Pause (ou 0), mise à jour immédiate de la RAM affichée et message de retour précis (Mo libérés + nombre d'applis fermées).

---

## [v4.2.2] - 2026-11-16
### Modifications
- Indicateur système dynamique en temps réel selon la RAM libre : vert « Système fluide » (≥ 35 %), orange « Mémoire chargée » (20–34 %), rouge « RAM saturée (▶⏸) » (< 20 %).

---

## [v4.2.0] - 2026-11-16
### Modifications
- Optimisation majeure des performances TV : purge instantanée ciblée au lancement d'une app (?keep=), détection rapide des apps actives via app_launcher -S, réglage noyau vm.swappiness=60 / vfs_cache_pressure=80 et désactivation de HbbTV (-40 Mo RAM).

---

## [v4.2.2] - 2026-11-16
### Modifications
- Indicateur système dynamique en temps réel selon la RAM libre : vert « Système fluide » (≥ 35 %), orange « Mémoire chargée » (20–34 %), rouge « RAM saturée (▶⏸) » (< 20 %).

---

## [v4.2.1] - 2026-11-16
### Modifications
- Purge RAM manuelle en 1 clic via la touche Play/Pause (ou 0), mise à jour immédiate de la RAM affichée et message de retour précis (Mo libérés + nombre d'applis fermées).

---

## [v4.2.2] - 2026-11-16
### Modifications
- Indicateur système dynamique en temps réel selon la RAM libre : vert « Système fluide » (≥ 35 %), orange « Mémoire chargée » (20–34 %), rouge « RAM saturée (▶⏸) » (< 20 %).

---

## [v4.0.0] - 2026-11-12
### Ajouté
- **Version initiale** (`2d8793d`) : lanceur personnalisé Samsung Tizen 60 FPS accéléré GPU (`translate3d`), fond d'ambiance réactif, météo en direct, horloge, détection dynamique PS5 sur HDMI 3, catalogue complet d'applications, réorganisation à la télécommande et purge RAM manuelle (touche `0`).
