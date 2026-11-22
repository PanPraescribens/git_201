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

# Échap ANSI, pour les prompts bien visibles
TD_E=$'\033'

_td_usage() {
  cat << 'USAGE'
td                 — menu interactif (liste vos exercices)
td go <numéro>     — va dans l'exercice n°X de la whitelist (td go = liste)
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
    echo "Pour commencer un exercice : td go 1"
  fi
}

# Affiche un .md minimaliste dans le terminal :
# `code` en jaune gras (pour que personne ne tape les backticks !), titres en cyan.
# Les couleurs seulement si sortie = terminal (sinon on affiche brut).
_md_ansi() {
  if [ -t 1 ]; then
    local E=$'\033'
    sed -e "s/^#\(.*\)/${E}[1;36m#\1${E}[0m/" \
        -e "s/\`\([^\`]*\)\`/${E}[1;33m\1${E}[0m/g" "$1"
  else
    cat "$1"
  fi
}

# La liste de tâches de l'exercice courant (A_FAIRE.md, posé par td go)
td_todo() {
  if [ -f "A_FAIRE.md" ]; then
    _md_ansi "A_FAIRE.md"
    return
  fi
  local dirs=()
  while IFS= read -r d; do dirs+=("$d"); done < <(_td_known)
  if [ ${#dirs[@]} -eq 0 ]; then
    echo "Aucun exercice. Créez-en un avec : td go 1"
    return
  fi
  echo "De quel exercice voulez-vous les tâches ?"
  PS3="${TD_E}[1;33m👉 Tapez un numéro (q = annuler) : ${TD_E}[0m"
  select c in "${dirs[@]}" "Annuler"; do
    case "$REPLY" in
      q|Q) return ;;
    esac
    case "$c" in
      "Annuler")   return ;;
      "")          echo "Choix invalide." ;;
      *)
        if [ -f "$TD_HOME/$c/A_FAIRE.md" ]; then
          _md_ansi "$TD_HOME/$c/A_FAIRE.md"
        else
          echo "Pas de liste de tâches pour $c."
        fi
        return
        ;;
    esac
  done
}

# Liste des exercices connus : ceux qui ont une liste de tâches installée,
# plus ceux déjà créés dans le workspace. C'est LA whitelist de `td go`.
_td_known() {
  {
    local f b d
    for f in "$TD_SHARE"/taches/*.md; do
      [ -f "$f" ] && b=$(basename "$f" .md) && echo "$b"
    done
    for d in "$TD_HOME"/*/; do
      [ -d "$d" ] || continue
      b=$(basename "$d")
      case "$b" in td[0-9]*ex[0-9]*) echo "$b" ;; esac
    done
  } | sort -u
}

# Ouvre un exercice par son nom : le crée si besoin, y entre, fait le point.
_td_open() {
  local ex="$1" d="$TD_HOME/$ex"
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
  [ -f "A_FAIRE.md" ] && { echo; echo "— Que dois-je faire ? —"; _md_ansi "A_FAIRE.md"; }
}

# Va dans un exercice — par NUMÉRO dans la whitelist uniquement.
td_go() {
  local n="${1:-}" known=() k i=1 ex
  while IFS= read -r k; do known+=("$k"); done < <(_td_known)
  if [ ${#known[@]} -eq 0 ]; then
    echo "Aucun exercice connu. Installez l'environnement (divers/td-env.sh)."
    return 1
  fi
  if [ -z "$n" ]; then
    echo "Exercices disponibles :"
    for k in "${known[@]}"; do echo "  $i. $k"; i=$((i+1)); done
    echo "Usage : td go <numéro>"
    return 1
  fi
  case "$n" in
    ''|*[!0-9]*)
      echo "Refusé : « $n » n'est pas un numéro."
      echo "td go seul affiche la liste des exercices."
      return 1
      ;;
  esac
  ex="${known[$((n-1))]:-}"
  if [ -z "$ex" ]; then
    echo "Pas d'exercice n°$n. td go seul affiche la liste."
    return 1
  fi
  _td_open "$ex"
}

# Menu interactif
td_menu() {
  echo "=== TD Git 201 — workspace : $TD_HOME ==="
  local dirs=()
  while IFS= read -r d; do dirs+=("$d"); done < <(_td_list)
  if [ ${#dirs[@]} -eq 0 ]; then
    echo "Aucun exercice pour l'instant."
    echo "Créez le premier avec : td go 1"
    return
  fi
  PS3="${TD_E}[1;33m👉 Tapez un numéro (q = quitter) : ${TD_E}[0m"
  select c in "${dirs[@]}" "Que dois-je faire ?" "Où suis-je ?"; do
    case "$REPLY" in
      q|Q) echo "Au revoir !"; break ;;
    esac
    case "$c" in
      "Où suis-je ?")        td_check ;;
      "Que dois-je faire ?") td_todo ;;
      "")                    [ "$REPLY" = q ] || [ "$REPLY" = Q ] || echo "Choix invalide." ;;
      *)                     _td_open "$c"; break ;;
    esac
  done
}

td() {
  case "${1:-}" in
    "") clear; td_menu ;;
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
