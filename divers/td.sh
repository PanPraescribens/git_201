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
td todo [numéro]   — « que dois-je faire ? » (numéro = un autre exercice)
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

# Nom lisible pour le menu : 01_01 → « Cours 1 - Exercice 1 »
# (les anciens noms td01ex01 s'affichent tels quels)
_td_pretty() {
  local b="$1" c e
  case "$b" in
    [0-9][0-9]_[0-9][0-9])
      c="${b%%_*}"; e="${b#*_}"
      echo "Cours $((10#$c)) - Exercice $((10#$e))"
      ;;
    *) echo "$b" ;;
  esac
}

# Où suis-je ? Dépôt, branche, modifs en attente, et garde-fous :
# - anti repo-dans-repo (clone du cours)
# - anti exercice-imbriqué (piège du mkdir en double)
td_check() {
  local top branch n rel depth
  # Étes-vous au bon endroit ? Racine d'un exercice connu = confirmation positive
  case "$PWD" in
    "$TD_HOME"/*)
      rel="${PWD#"$TD_HOME"/}"
      depth=$(printf '%s' "$rel" | awk -F/ '{print NF}')
      if [ "$depth" -eq 1 ] && _td_is_exercise "$rel"; then
        echo "✓ Vous êtes dans le dossier de l'exercice : $(_td_pretty "$rel")"
        echo "  td todo       — la liste de tâches de cet exercice"
        echo "  (git init si ce n'est pas déjà fait, puis suivez le todo !)"
      elif [ "$depth" -ge 2 ] && _td_is_exercise "${rel##*/}"; then
        echo "⚠️  Exercice imbriqué détecté : $PWD"
        echo "   (piège classique : mkdir dans le dossier de l'exercice)."
        echo "   Remontez d'un niveau : cd .."
      fi
      ;;
  esac
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
# La ligne de métadonnées « <!-- source: ... » (exercise à copier) est masquée.
_md_ansi() {
  if [ -t 1 ]; then
    local E=$'\033'
    sed -e '/^<!-- source:/d' \
        -e "s/^#\(.*\)/${E}[1;36m#\1${E}[0m/" \
        -e "s#\(https://[^ ]*\)#${E}[36m\1${E}[0m#g" \
        -e "s/\`\([^\`]*\)\`/${E}[1;33m\1${E}[0m/g" "$1"
  else
    grep -v '^<!-- source:' "$1"
  fi
}

# Test : ce nom est-il un dossier d'exercice ?
_td_is_exercise() {
  case "$1" in
    td[0-9]*ex[0-9]*|[0-9][0-9]_[0-9][0-9]) return 0 ;;
    *) return 1 ;;
  esac
}

# La liste de tâches FAITE AUTORITÉ pour un exercice : d'abord la version
# installée (TD_SHARE, mise à jour par td-env.sh), sinon l'A_FAIRE local —
# car une copie d'exercice traîne l'A_FAIRE de l'exercice PRÉCÉDENT.
_td_taskfile() {
  local ex="$1"
  if [ -f "$TD_SHARE/taches/$ex.md" ]; then
    echo "$TD_SHARE/taches/$ex.md"
  elif [ -f "$TD_HOME/$ex/A_FAIRE.md" ]; then
    echo "$TD_HOME/$ex/A_FAIRE.md"
  fi
}

# La liste de tâches de l'exercice courant (ou d'un autre : td todo <numéro>)
td_todo() {
  if [ -n "${1:-}" ]; then
    local n="$1" known=() k i=1 ex f
    while IFS= read -r k; do known+=("$k"); done < <(_td_known)
    case "$n" in
      ''|*[!0-9]*) echo "Refusé : « $n » n'est pas un numéro." ; return 1 ;;
    esac
    ex="${known[$((n-1))]:-}"
    if [ -z "$ex" ]; then
      echo "Pas d'exercice n°$n. td todo seul = exercice courant."
      return 1
    fi
    f=$(_td_taskfile "$ex")
    if [ -n "$f" ]; then
      _md_ansi "$f"
    else
      echo "Pas de liste de tâches pour $ex."
    fi
    return
  fi
  # Exercice courant = racine d'un exercice dans le workspace ?
  local rel cur=""
  case "$PWD" in
    "$TD_HOME"/*)
      rel="${PWD#"$TD_HOME"/}"
      case "$rel" in */*) ;; *) _td_is_exercise "$rel" && cur="$rel" ;; esac
      ;;
  esac
  if [ -n "$cur" ]; then
    local f
    f=$(_td_taskfile "$cur")
    if [ -n "$f" ]; then
      _md_ansi "$f"
      return
    fi
  fi
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
    if [ -f "$TD_SHARE/taches/$c.md" ]; then
      _md_ansi "$TD_SHARE/taches/$c.md"
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
      case "$b" in td[0-9]*ex[0-9]*|[0-9][0-9]_[0-9][0-9]) echo "$b" ;; esac
    done
  } | sort -u
}

# Exercice à copier comme point de départ ? Déclaré dans la liste de tâches :
# une ligne « <!-- source: 01_01 --> » = td go copie le repo 01_01 dans le nouvel exercice.
# (Conservé pour compat, mais la méthode préférée est un script de mise en place.)
_td_seed() {
  local ex="$1" f="$TD_SHARE/taches/$ex.md"
  [ -f "$f" ] || return 0
  sed -n 's/^<!-- source: *\([^ >]*\).*$/\1/p' "$f" | head -1
}

# Ouvre un exercice par son nom : le crée si besoin, y entre, fait le point.
_td_open() {
  local ex="$1" d="$TD_HOME/$ex" setup
  if [ ! -d "$d" ]; then
    mkdir -p "$d" && echo "Exercice créé : $d"
    # Liste de tâches d'abord : le script de mise en place peut s'en servir (git add A_FAIRE.md)
    if [ -f "$TD_SHARE/taches/$ex.md" ]; then
      grep -v '^<!-- source:' "$TD_SHARE/taches/$ex.md" > "$d/A_FAIRE.md"
      echo "Liste de tâches déposée : A_FAIRE.md (td todo pour la revoir)"
    fi
    # État de départ de l'exercice, préparé par son script dédié (s'il existe)
    setup="$TD_SHARE/taches/$ex.sh"
    if [ -f "$setup" ]; then
      if (cd "$d" && bash "$setup"); then
        echo "✓ Repo préparé dans l'état attendu par l'exercice"
      else
        echo "⚠️  Le script de préparation de $ex a échoué — repartez d'un dossier vide :"
        echo "   rm -rf \"$d\" puis relancez td go."
      fi
    fi
  fi
  cd "$d" || return 1
  td_check
  local tf
  tf=$(_td_taskfile "$ex")
  [ -n "$tf" ] && { echo; echo "— Que dois-je faire ? —"; _md_ansi "$tf"; }
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
    for k in "${known[@]}"; do echo "  $i. $(_td_pretty "$k")"; i=$((i+1)); done
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
  local dirs=() labels=() d
  while IFS= read -r d; do dirs+=("$d"); labels+=("$(_td_pretty "$d")"); done < <(_td_list)
  if [ ${#dirs[@]} -eq 0 ]; then
    echo "Aucun exercice pour l'instant."
    echo "Créez le premier avec : td go 1"
    return
  fi
  PS3="${TD_E}[1;33m👉 Tapez un numéro (q = quitter) : ${TD_E}[0m"
  select c in "${labels[@]}" "Que dois-je faire ?" "Où suis-je ?"; do
    case "$REPLY" in
      q|Q) echo "Au revoir !"; break ;;
    esac
    case "$c" in
      "Où suis-je ?")        td_check ;;
      "Que dois-je faire ?") td_todo ;;
      "")                    [ "$REPLY" = q ] || [ "$REPLY" = Q ] || echo "Choix invalide." ;;
      *)                     _td_open "${dirs[$((REPLY-1))]}"; break ;;
    esac
  done
}

td() {
  case "${1:-}" in
    "") clear; td_menu ;;
    go)             shift; td_go "$@" ;;
    todo)           shift; td_todo "$@" ;;
    check|status)   td_check ;;
    help|-h|--help) _td_usage ;;
    *)
      echo "Commande inconnue : $1"
      _td_usage
      return 1
      ;;
  esac
}
