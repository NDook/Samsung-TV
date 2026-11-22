# Mon Accueil TV 📺✨

> Lanceur d'applications moderne, ultra-rapide (60 FPS) et épuré pour Smart TV Samsung sous Tizen OS. Conçu pour remplacer le hub d'accueil encombré par une expérience fluide, sans publicité et personnalisable de type Apple TV / console.

---

## 🌟 Fonctionnalités

- ⚡ **Navigation 60 FPS ultra-fluide** : Défilement accéléré matériellement par le GPU (`translate3d`), aucune saccade, zéro recalcul de layout lourd.
- 🎨 **Fond d'ambiance réactif (Ambient Lighting)** : Éclairage feutré plein écran qui s'adapte subtilement à la couleur de l'application sélectionnée (temporisé pour ne jamais impacter la fluidité).
- 📜 **Pensée & Citation philosophique du jour** : Une citation inspirante aléatoire à chaque allumage de la TV ou retour à l'accueil parmi un recueil soigné de 64 pensées (Sénèque, Marc Aurèle, Lao Tseu, Socrate, Nietzsche, Camus, Saint-Exupéry, Confucius, Oscar Wilde, Einstein...). Un algorithme de *tirage sans remise (deck Fisher-Yates)* stocké localement garantit zéro répétition avant épuisement complet du cycle.
- 🕒 **Horloge & Date en temps réel** : Affichage discret et actualisé avec l'heure exacte et la date du jour en français.
- ⛅ **Météo en direct** : Widget météo discret indiquant la température et l'état du ciel en temps réel.
- 🎮 **Détection dynamique PS5 (HDMI 3)** : La tuile PlayStation 5 n'apparaît dans le dock que lorsque la console est branchée et allumée sur le port HDMI 3. Dès son extinction ou débranchement, le dock s'ajuste automatiquement sans laisser de tuile inutile.
- 🗂️ **Dock entièrement personnalisable** :
  - **Ajout d'applications** : Catalogue intégré répertoriant toutes les applications installées sur la TV avec découverte automatique.
  - **Déplacement / Réorganisation** : Mode réorganisation à la télécommande (appui long sur `OK` ou flèches).
  - **Suppression rapide** : Retrait d'une application du dock d'un simple clic (touche rouge ou flèche bas en mode édition).
  - **Persistance locale** : Vos préférences d'ordre et d'applications restent mémorisées dans le stockage local de la TV.
- 🧠 **Gestion intelligente de la RAM (Reprise instantanée + Anti-freeze)** :
  - Respecte la mise en veille native de Tizen pour garder vos applications (Canal+, FreeTV, Netflix...) prêtes en mémoire et permettre une **reprise instantanée**.
  - Réglage noyau optimisé (`vm.swappiness=60`, `vfs_cache_pressure=80`) et garde-fou anti-freeze en arrière-plan (ne ferme un processus en veille que s'il sature anormalement le CPU, comme `GIBBON_MAIN`).
- 🚀 **Ouverture instantanée** : Raccourcis directs sur les touches numériques `1` à `7` de la télécommande.

---

## 📂 Structure du projet

```
mon-accueil-tv/
├── CHANGELOG.md                     # Historique des versions et modifications
├── config.xml                       # Manifeste de l'application Tizen (privilèges, nom, autorisations)
├── icon.png                         # Icône officielle du lanceur
├── index.html                       # Interface complète HTML5 / CSS3 / JavaScript (GPU 60 FPS)
├── icons/                           # Logos officiels vectoriels et PNG haute définition
│   ├── canal.png
│   ├── netflix.png
│   ├── primevideo.png
│   ├── disney.png
│   ├── jellyfin.png
│   ├── youtube.png
│   └── ...
├── plugins/
│   └── mon-accueil-metrics/         # Plugin persistant Vetro (métriques RAM/batterie en tmpfs, VM tuning, anti-freeze CPU)
│       ├── index.js
│       └── manifest.json
├── scripts/
│   ├── deploy_launcher.ps1          # Script de déploiement à chaud du lanceur sur la TV
│   ├── deploy_plugin.ps1            # Script de déploiement du plugin persistant Vetro
│   ├── update_changelog.ps1         # Script de gestion de version et de génération du changelog
│   └── run_tv_cmd.ps1               # Utilitaire d'exécution de commandes sur la TV via l'agent
└── README.md
```

---

## 🚀 Déploiement sur la TV

### Prérequis
- Une Smart TV Samsung (Tizen 6.5+ ou compatible).
- Le service d'administration local (port `8089`) ou l'outil Tizen CLI / SDB connecté à l'adresse IP de la TV *(paramétrable via `$env:SAMSUNG_TV_IP`)*.

### Déploiement rapide
1. Ouvrir PowerShell dans le dossier `scripts/`
2. Déployer la dernière version de l'interface :
   ```powershell
   .\deploy_launcher.ps1
   ```
3. Déployer et activer le plugin persistant (batterie, HDMI 3, RAM en tmpfs, anti-freeze CPU) :
   ```powershell
   .\deploy_plugin.ps1
   ```

---

## 🎮 Raccourcis télécommande

| Bouton | Action |
|---|---|
| **◀ / ▶** | Naviguer entre les applications dans le dock |
| **OK (court)** | Lancer l'application sélectionnée / Ouvrir la tuile |
| **OK (long)** | Entrer / Sortir du mode réorganisation des tuiles |
| **▲ / ▼** *(en mode modif)* | Sortir du mode édition (▲) ou Retirer la tuile du dock (▼) |
| **Touche Rouge** | Retirer immédiatement l'application sous le curseur |
| **Touche Verte** | Raccourci direct pour ouvrir le catalogue d'applications |
| **Touches 1 à 7** | Lancement direct des 7 premières applications du dock |
| **Retour** | Fermer le catalogue / Revenir à l'accueil |

---

## 📄 Licence
Projet personnel sous licence MIT.
