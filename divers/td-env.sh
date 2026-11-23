#!/usr/bin/env bash
# td-env.sh — installe l'environnement TD Git 201
#
# À lancer UNE FOIS depuis le clone du cours :
#     cd divers && bash td-env.sh
#
# Ce que fait l'installateur :
#   0. décide où vit le workspace exercices : à côté du clone du cours
#      (~/git_201/td-git201 plutôt qu'un ~/td-git201 perdu à la racine)
#   1. copie les outils (td.sh, git-prompt.sh, complétion) dans ~/.local/share/td-git201
#   2. git config init.defaultBranch main   (plus de warnings "master")
#   3. ajoute un bloc idempotent dans ~/.bashrc : commande `td` + prompt avec branche
#   4. sous Git Bash : crée ~/.bash_profile si absent (sinon .bashrc n'est pas lu)
#
# Réinstallable sans risque : il ne modifie ~/.bashrc qu'entre ses marqueurs.

set -e

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.local/share/td-git201"
BASHRC="$HOME/.bashrc"
MARK_START="# >>> td-git201 >>>"
MARK_END="# <<< td-git201 <<<"

echo "=== Installation de l'environnement TD Git 201 ==="

# 0. Workspace exercices à côté du clone du cours, pas à la racine du home
TD_HOME_DEF="$(dirname "$SRC")/td-git201"
if [ "$TD_HOME_DEF" != "$HOME/td-git201" ] && [ -d "$HOME/td-git201" ] \
   && [ -n "$(ls -A "$HOME/td-git201" 2>/dev/null)" ]; then
  echo "⚠️  Ancien workspace non vide : $HOME/td-git201"
  echo "   Le workspace vit désormais à côté du clone du cours : $TD_HOME_DEF"
  echo "   Déplacez-le pour retrouver vos exercices :"
  echo "     mv \"$HOME/td-git201\" \"$TD_HOME_DEF\""
  echo
fi

# 1. Copie des outils (indépendante du clone : peut être effacé/recloné sans casse)
mkdir -p "$DEST"
cp -f "$SRC/td.sh" "$DEST/td.sh"
mkdir -p "$DEST/taches"
if [ -d "$SRC/taches" ]; then
  cp -f "$SRC/taches/"*.md "$DEST/taches/"
  cp -f "$SRC/taches/"*.sh "$DEST/taches/" 2>/dev/null || true
  echo "✓ $(ls "$SRC/taches/" | wc -l) liste(s) de tâches installée(s)"
fi
if [ -f "$SRC/git-prompt.sh" ]; then
  cp -f "$SRC/git-prompt.sh" "$DEST/git-prompt.sh"
elif command -v git >/dev/null && [ -f "$(git --exec-path)/git-prompt.sh" ]; then
  cp -f "$(git --exec-path)/git-prompt.sh" "$DEST/git-prompt.sh"
else
  echo "⚠️  git-prompt.sh introuvable — le prompt n'affichera pas la branche" >&2
fi
if [ -f "$SRC/.git-completion.bash" ]; then
  cp -f "$SRC/.git-completion.bash" "$DEST/git-completion.bash"
fi

# 2. Config git : les nouveaux repos démarrent sur main
git config --global init.defaultBranch main && echo "✓ init.defaultBranch = main"

# 2bis. Erreur étudiante n°1 : git non identifié (impossible de committer)
if ! git config --get user.name >/dev/null || ! git config --get user.email >/dev/null; then
  echo "⚠️  Votre identité git n'est pas configurée : aucun commit ne fonctionnera !"
  echo "   Corrigez avec (mettez VOTRE nom et email) :"
  echo "     git config --global user.name  \"Prénom Nom\""
  echo "     git config --global user.email \"prenom.nom@example.fr\""
  echo
fi

# 2ter. Erreur « dubious ownership » : Git refuse un dépôt dont le propriétaire
# du dossier n'est pas l'utilisateur courant (home réseau, session précédente…).
# L'entrée « <chemin>/* » couvre tous les repos SOUS le workspace — un repo par
# exercice — une fois pour toutes.
if ! git config --global --get-all safe.directory 2>/dev/null | grep -Fxq "$TD_HOME_DEF/*"; then
  git config --global --add safe.directory "$TD_HOME_DEF"
  git config --global --add safe.directory "$TD_HOME_DEF/*" \
    && echo "✓ workspace TD déclaré sûr (safe.directory)"
fi

# 3. Bloc ~/.bashrc (idempotent : on retire l'ancien bloc avant de réécrire)
[ -f "$BASHRC" ] && cp -f "$BASHRC" "$BASHRC.bak-td"
if [ -f "$BASHRC" ] && grep -qF "$MARK_START" "$BASHRC"; then
  sed -i "/$MARK_START/,/$MARK_END/d" "$BASHRC"
fi
cat >> "$BASHRC" << BLOC

$MARK_START
export TD_HOME="\${TD_HOME:-$TD_HOME_DEF}"
[ -f "$DEST/td.sh" ] && source "$DEST/td.sh"
[ -f "$DEST/git-prompt.sh" ] && source "$DEST/git-prompt.sh"
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASH=1
case "\$PS1" in
  *__git_ps1*) ;;  # Git Bash : le prompt affiche déjà la branche, on ne touche pas
  *) PS1='\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\]\$(__git_ps1 " (%s)")\\\$ ' ;;
esac
$MARK_END
BLOC
echo "✓ bloc ajouté à $BASHRC (sauvegarde : $BASHRC.bak-td)"

# 4. Git Bash : .bashrc n'est lu que si .bash_profile l'inclut
if [ ! -f "$HOME/.bash_profile" ]; then
  cat > "$HOME/.bash_profile" << 'BP'
# créé par td-env.sh : sans ce fichier, Git Bash ignore ~/.bashrc
[ -f ~/.bashrc ] && . ~/.bashrc
BP
  echo "✓ ~/.bash_profile créé (requis par Git Bash)"
fi

echo
echo "✅ Environnement installé dans $DEST"
echo "   Workspace exercices : $TD_HOME_DEF"
echo "   Ouvrez un nouveau terminal, ou tapez :  source ~/.bashrc"
echo "   Ensuite :  td help"
