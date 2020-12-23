#!/usr/bin/env bash

set -u

RED='\e[31m'
GREEN='\e[32m'
NC='\e[0m'

# Print standard error message and exit.
error () {
  if [ ! -z "${1-}" ]; then
    printf "${RED}[ERROR]${NC} %s\n" "$1"
  fi
  print_help
  exit 1
}

# Print standard info message.
log_info () {
  printf "${GREEN}[DIARY]${NC} %s\n" "$1"
}

# Run command silently unless debug flag is set.
quiet () {
  if [ ! -z ${DIARY_DEBUG:-} ]; then
    "$@"
  else
    "$@" > /dev/null 2>&1
  fi
}

# Print help message
print_help () {
  printf "Diary Options:\n"
  printf "\tdiary [diary_repo]: Open today's entry. Uses DIARY_REPO if no repo is provided and EDITOR (defaults to vim) for text editor.\n"
  printf "\tdiary init [diary_repo] [diary_remote]: Initialize diary repo. Uses DIARY_REPO if no repo is provided.\n"
  printf "\t\tIf both repo and remote are provided then a new diary is set up and tracked using the remote.\n"
  printf "\n"
}

# Open diary command.
# ```sh
# open_diary [diary_repo]
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
  if has_origin $repo; then
    log_info "Syncing with remote"
    quiet git -C $repo pull
  fi

  $editor $entry_path

  quiet git -C $repo add -A
  quiet git -C $repo commit -m "edit $entry_name"
  if has_origin $repo; then
    log_info "Pushing to remote"
    quiet git -C $repo push origin main
  fi
}

# Check if repo has origin for tracking
# ```sh
# if has_origin $repo_path; then
#    # Do someting
# fi
# ```
has_origin() {
  local repo=$1
  local repo_remotes=$(git -C $repo remote)
  for rem in $repo_remotes; do
    if [ $rem == "origin" ]; then
      true
      return
    fi
  done
  false
}

# Initialize diary fn
# Called with the fully-qualified repo to be initialized:
# ```sh
# init_diary [local-repo] [remote-repo]
# ```
init_diary () {
  local repo=$1
  local remote_repo=${2:-}
  # Validate the repo doesn't exist
  if [ -d "$repo/.git" ]; then
    error "Diary at '$repo' already exists."
  fi
  log_info "Initializing repo '$repo'"
  mkdir -p $repo
  quiet git -C $repo init
  echo "# Personal Diary" >> $repo/README.md
  quiet git -C $repo add -A
  quiet git -C $repo commit -m "Diary init commit"
  quiet git -C $repo branch -M main
  quiet git -C $repo config pull.rebase true

  # Setup remote
  if [ ! -z ${remote_repo:-} ]; then
    log_info "Setting up remote '$remote_repo'"
    quiet git -C $repo remote add origin $remote_repo
    quiet git -C $repo push -u origin main
  fi
}

# Parse arguments
positional_args=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    init)
      if [ ! -z ${2:-} ]; then
        init_diary_repo=$2
        init_diary_remote=${3:-}
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
  init_diary $init_diary_repo ${init_diary_remote:-}
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
