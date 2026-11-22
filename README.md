# Lisez-moi avant de vous lancer bille en tête

Normalement vous ne pouvez que télécharger ce dépôt, et c'est normal on ne veut que travailler localement pour le moment, sans faire de git push.

Souvenez-vous que vous pouvez toujours tout effacer et recommencer avec un `git clone` si vous avez vraiment tout foutu en l'air.
Rien de grave !

## Le dépôt

```
cours/       → les présentations, pour revoir la leçon
pratiques/   → un dossier autoportant par TD (énoncé + matériel)
divers/      → l'environnement de travail, scripts utiles
```

## Mise en route (une fois pour toutes)

Depuis votre clone du dépôt :

```bash
cd divers && bash td-env.sh
```

puis **ouvrez un nouveau terminal**. Vous avez alors :

- `td` — le menu (tapez **un numéro**, ou `q` pour quitter) ;
- `td go 1` — va dans l'exercice n°1 (le crée et y dépose `A_FAIRE.md`, la liste de ce que vous devez faire) ;
- les exercices sont numérotés par **cours** : dossier `01_01` = Cours 1, exercice 1
  (affiché « Cours 1 - Exercice 1 » dans le menu) ;
- `td todo` — revoir « que dois-je faire ? » ;
- `td check` — où suis-je ? (dépôt ? branche ? modifs en cours ?)

Vos exercices vivent dans `~/td-git201/` — **jamais dans le clone du dépôt** :
jamais de repo dans le repo !

## Les énoncés

Chaque TD : `pratiques/td_XX/` (le `README.md` du dossier donne objectifs et durée,
l'énoncé détaillé est dans `td_XX.md`). La version en ligne, avec ancres par
exercice : [pratiques/td_01/td_01.md](pratiques/td_01/td_01.md).

## Le reste

1. Suivez l'énoncé du TD, étape par étape.

2. Si vous êtes bloqués, demandez de l'aide à vos voisins de rangée qui ont peut-être déjà fini.
   N'oubliez pas que collaborer sur un projet, c'est savoir demander de l'aide à ses collègues. Et bien sûr les aider quand on peut. Des fois c'est moi le boulet de l'équipe, des fois c'est moi qui *carry* tout le monde. Chacun participe à sa mesure mais tout le monde doit passer la ligne d'arrivée !

3. Sinon bien sûr je suis là, et je suis même payé pour !

4. Si vous avez fini en avance, regardez si vos voisins y arrivent, ou ont besoin d'aide.
   Sinon vous pouvez aussi expérimenter, tester votre compréhension en modifiant un paramètre, etc.
   Si vous faites une erreur, ça tombe bien, on est là pour en faire et les gérer !
   (et oui vous pouvez m'appeler même si vous êtes en train de bidouiller !)
