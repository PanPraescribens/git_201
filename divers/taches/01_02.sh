#!/usr/bin/env bash
# État de départ de l'exercice 02 (= fin de l'exercice 01, rangé) :
# main.txt et A_FAIRE.md commités. (Le secrets.txt de l'ex01 est rangé —
# c'est le dossier secrets/ qui joue ce rôle dans cet exercice.)
git init -q
touch main.txt
git add main.txt A_FAIRE.md
git commit -q -m "Ajoute main.txt"
