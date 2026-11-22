#!/usr/bin/env bash
# État de départ de l'exercice 03 (= fin de l'exercice 02) :
# main.txt et .gitignore commités, A_FAIRE.md suivi-ignoré, dossier secrets/ à l'abri.
git init -q
touch main.txt
printf '/secrets/**\nA_FAIRE.md\n' > .gitignore
mkdir -p secrets
echo 'MonSecret' > secrets/secrets.txt
git add main.txt .gitignore
git commit -q -m "Ajoute .gitignore"
git tag ex02
