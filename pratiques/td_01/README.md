# TD 1 — L'index, les fichiers indésirables et revenir en arrière

Premier TD du cours Git 201. Il accompagne la leçon 1 : l'index git (`git add`),
les fichiers non désirés (`.gitignore`) et les premières manœuvres de retour
en arrière (`restore --staged`, `rm --cached`, `commit --amend`, `reset --hard`, `reflog`).

## Objectifs

- Comprendre ce que fait `git add` et maîtriser le retrait de l'index.
- Corriger un commit avec `git commit --amend`.
- Découvrir que *rien n'est perdu* avec git : `git reflog`.
- Protéger son dépôt avec un `.gitignore`.

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

- la commande `td` (menu interactif : `td`, `td go td01ex01`, `td todo` —
  « que dois-je faire ? » —, `td check`),
- un prompt qui affiche la branche et l'état du dépôt,
- les exercices dans `~/td-git201/` — **jamais dans le clone du cours**
  (on évite ainsi le repo-dans-le-repo).

## Déroulé

Durée : ~45 minutes. Tout se fait en local, aucun dépôt distant nécessaire.

1. [`td_01.md`](td_01.md) — l'énoncé des exercices, à suivre pas à pas.
