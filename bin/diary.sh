#!/usr/bin/env bash

set -e;set -u;

RED='\e[31m'
NC='\e[0m'

# Open diary command.
# ```sh
# open_diary <path-to-diary>
# ```
open_diary () {
  local repo=$1

  # Validate the repo exists
  if [ ! -d "$repo/.git" ]; then
    error "No diary at '$repo'. Please initialize."
  fi

  local editor=${EDITOR:-vim}
  local date_str=$(date +'%m-%d-%Y')
  local entry_name="entry_$date_str"
  local entry_path="$repo/$entry_name.md"

  # Open file with configured editor
  $editor $entry_path

  # Commit changes
  git -C $repo add -A
  git -C $repo commit -m "edit $entry_name"
}

# Initialize diary fn
# Called with the fully-qualified repo to be initialized:
# ```sh
# init_diary <path-to-diary-dir>
# ```
init_diary () {
  local repo=$1
  echo "$repo"
  # Validate the repo doesn't exist
  if [ -d "$repo/.git" ]; then
    error "Diary at '$repo' already exists."
  fi
  mkdir -p $repo
  git -C $repo init
}

# Help message
print_help () {
  printf "Diary Options:\n"
  printf "\tdiary [diary_repo]: Open today's entry. Uses DIARY_REPO if no repo is provided and EDITOR (defaults to vim) for text editor.\n"
  printf "\tdiary init [diary_repo]: Initialize diary repo. Uses DIARY_REPO if no repo is provided.\n"
  printf "\n"
}

error () {
  if [ ! -z "${1-}" ]; then
    printf "${RED}ERROR: %s${NC}\n" "$1"
  fi
  print_help
  exit 1
}

# Parse arguments
positional_args=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    init)
      if [ ! -z ${2-} ]; then
        init_diary_repo=$2
        shift
      elif [ ! -z ${DIARY_REPO:-} ]; then
        init_diary_repo=$DIARY_REPO
      else
        error "No init repo found."
      fi
      shift
    ;;
    help)
      print_help
      exit
    ;;
    *)    # unknown option
    positional_args+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done


# Process arguments and call corresponding functions
if [ ! -z ${init_diary_repo:-} ]; then
  init_diary $init_diary_repo
else
  if [ ! -z ${positional_args[0]:-} ]; then
    diary_repo=${positional_args[0]}
  elif [ ! -z ${DIARY_REPO:-} ]; then
    diary_repo=$DIARY_REPO
  else
    error "No diary repo found."
  fi
  open_diary $diary_repo
fi
