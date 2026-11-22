# td.sh — le moteur de l'environnement TD Git 201
#
# Ce fichier définit la commande `td`. Il n'est pas exécuté directement :
# il est *sourcé* par votre ~/.bashrc (voir td-env.sh), pour que `td` puisse
# changer de répertoire — impossible pour un simple script.
#
# Compatible Git Bash (Windows) et Linux/WSL.

# Racine du workspace exercices. Chaque TD vit ICI, jamais dans le clone du
# cours : on évite ainsi les repos-dans-le-repo.
TD_HOME="${TD_HOME:-$HOME/td-git201}"

# Où l'installateur a posé les outils (listes de tâches, prompt, etc.)
TD_SHARE="${TD_SHARE:-$HOME/.local/share/td-git201}"

_td_usage() {
  cat << 'USAGE'
td                 — menu interactif (liste vos exercices)
td go <dossier>    — va dans un exercice, le crée si besoin (ex: td go td01ex01)
td todo            — « que dois-je faire ? » : les tâches de l'exercice courant
td check           — où suis-je ? (dépôt git ? branche ? modifs en cours ?)
td help            — cette aide

Les exercices vivent dans $TD_HOME (par défaut ~/td-git201),
JAMAIS dans le clone du cours : jamais de repo dans le repo.
USAGE
}

# Liste des répertoires d'exercices existants
_td_list() {
  [ -d "$TD_HOME" ] || return 0
  for d in "$TD_HOME"/*/; do
    [ -d "$d" ] && basename "$d"
  done
}

# Où suis-je ? Dépôt, branche, modifs en attente, et garde-fou anti repo-dans-repo
td_check() {
  local top branch n
  if top=$(git rev-parse --show-toplevel 2>/dev/null); then
    echo "Dépôt git       : $top"
    branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
      echo "Branche         : $branch"
    else
      echo "Branche         : (HEAD détaché !)"
    fi
    n=$(git status --porcelain 2>/dev/null | wc -l)
    echo "Modifs en cours : $n fichier(s)"
    case "$top" in
      *git_201*)
        echo "⚠️  ATTENTION : vous êtes dans le clone du COURS, pas dans un exercice !"
        echo "   Un git init ici créerait un repo dans le repo. Faites : td go <exercice>"
        ;;
    esac
  else
    echo "Pas dans un dépôt git. (Répertoire courant : $PWD)"
    echo "Pour commencer un exercice : td go td01ex01"
  fi
}

# La liste de tâches de l'exercice courant (A_FAIRE.md, posé par td go)
td_todo() {
  if [ -f "A_FAIRE.md" ]; then
    cat "A_FAIRE.md"
    return
  fi
  local dirs=()
  while IFS= read -r d; do dirs+=("$d"); done < <(_td_list)
  if [ ${#dirs[@]} -eq 0 ]; then
    echo "Aucun exercice. Créez-en un avec : td go td01ex01"
    return
  fi
  echo "De quel exercice voulez-vous les tâches ?"
  PS3="Votre choix (q = annuler) : "
  select c in "${dirs[@]}" "Annuler"; do
    case "$REPLY" in
      q|Q) return ;;
    esac
    case "$c" in
      "Annuler")   return ;;
      "")          echo "Choix invalide." ;;
      *)
        if [ -f "$TD_HOME/$c/A_FAIRE.md" ]; then
          cat "$TD_HOME/$c/A_FAIRE.md"
        else
          echo "Pas de liste de tâches pour $c."
        fi
        return
        ;;
    esac
  done
}

# Va dans un exercice (le crée si besoin). Le cd fonctionne car td est une fonction.
td_go() {
  local ex="${1:-}"
  if [ -z "$ex" ]; then
    echo "usage : td go td01ex01"
    return 1
  fi
  local d="$TD_HOME/$ex"
  if [ ! -d "$d" ]; then
    mkdir -p "$d" && echo "Exercice créé : $d"
    # On y dépose la liste de tâches si on la connaît
    if [ -f "$TD_SHARE/taches/$ex.md" ]; then
      cp -f "$TD_SHARE/taches/$ex.md" "$d/A_FAIRE.md"
      echo "Liste de tâches déposée : A_FAIRE.md (td todo pour la revoir)"
    fi
  fi
  cd "$d" || return 1
  td_check
  [ -f "A_FAIRE.md" ] && { echo; echo "— Que dois-je faire ? —"; cat "A_FAIRE.md"; }
}

# Menu interactif
td_menu() {
  echo "=== TD Git 201 — workspace : $TD_HOME ==="
  local dirs=()
  while IFS= read -r d; do dirs+=("$d"); done < <(_td_list)
  if [ ${#dirs[@]} -eq 0 ]; then
    echo "Aucun exercice pour l'instant."
    echo "Créez le premier avec : td go td01ex01"
    return
  fi
  PS3="Votre choix (q = quitter) : "
  select c in "${dirs[@]}" "Que dois-je faire ?" "Où suis-je ?"; do
    case "$REPLY" in
      q|Q) echo "Au revoir !"; break ;;
    esac
    case "$c" in
      "Où suis-je ?")        td_check ;;
      "Que dois-je faire ?") td_todo ;;
      "")                    [ "$REPLY" = q ] || [ "$REPLY" = Q ] || echo "Choix invalide." ;;
      *)                     cd "$TD_HOME/$c" && td_check; break ;;
    esac
  done
}

td() {
  case "${1:-}" in
    "")             td_menu ;;
    go)             shift; td_go "$@" ;;
    todo)           td_todo ;;
    check|status)   td_check ;;
    help|-h|--help) _td_usage ;;
    *)
      echo "Commande inconnue : $1"
      _td_usage
      return 1
      ;;
  esac
}
