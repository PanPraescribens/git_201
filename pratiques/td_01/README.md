# TD 1 — Cours 1 : l'index, `.gitignore` et revenir en arrière

Premier TD du cours Git 201. Il accompagne la leçon 1 : l'index git (`git add`),
les fichiers non désirés (`.gitignore`), la correction de commit (`--amend`),
les manœuvres de retour en arrière (`reset --soft/--mixed/--hard`, `reflog`).

Les exercices sont numérotés par **cours** : `01_01` = Cours 1, exercice 1.
Le plus simple est de passer par `td go 1`, `td go 2`… (création du dossier +
dépôt de la liste de tâches `A_FAIRE.md`).

## Objectifs

- Comprendre ce que fait `git add` et maîtriser le retrait de l'index.
- Protéger son dépôt avec un `.gitignore` — et savoir déprotéger un fichier déjà suivi.
- Corriger un commit avec `git commit --amend`.
- Découvrir que *rien n'est perdu* avec git : `git reflog`.
- (Bonus) Comprendre `reset --soft` / `--mixed` / `--hard` par la pratique.

## Prérequis

- `git` installé, **et identifié** (`git config --global user.name` / `user.email`) —
  sans ça, aucun commit ne fonctionnera.
- Un terminal bash (Linux, macOS, ou Git Bash / WSL sous Windows).

## Installation de l'environnement (recommandé)

Depuis le clone du cours :

```bash
cd divers && bash td-env.sh
```

puis **ouvrez un nouveau terminal**. Vous disposez alors de :

- la commande `td` (menu interactif : `td`, `td go 1`, `td todo` —
  « que dois-je faire ? » —, `td check`),
- un prompt qui affiche la branche et l'état du dépôt,
- les exercices dans `~/td-git201/` — **jamais dans le clone du cours**
  (on évite ainsi le repo-dans-le-repo).

## Déroulé

Durée : ~1h pour les exercices 1 à 4. L'exercice 5 est un bonus
pour les plus rapides. Tout se fait en local, aucun dépôt distant nécessaire.

1. [`td_01.md`](td_01.md) — l'énoncé des exercices, à suivre pas à pas.
