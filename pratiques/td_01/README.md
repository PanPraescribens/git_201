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

- `git` installé et configuré (`git config --global user.name` / `user.email`).
- Un terminal bash (Linux, macOS, ou WSL sous Windows).

## Déroulé

Durée : ~45 minutes. Tout se fait en local, aucun dépôt distant nécessaire.

1. [`td_01.md`](td_01.md) — l'énoncé des exercices, à suivre pas à pas.
