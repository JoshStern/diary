# Diary
A very simple CLI diary using [`git`](https://git-scm.com) for history tracking.

## Setup
### Env Variables
Diary uses a few environment variables:
* `EDITOR` - Your choice of editor (default editor is `vim`). For vscode please be sure your variable includes the wait command (`code --wait`).
* `DIARY_REPO` - Path to the repo used for the diary.
* `DIARY_DEBUG` - When set to any non-zero length value this enables all command output to stdout/stderr.

## Usage
### Initializing a local diary
To create a new diary local diary run `diary init [diary_repo]`. This will initialize a `git` repo at that location. If no arguments are provided then diary will attempt to initialize at `DIARY_REPO`.

Diary currently supports a single-branch workflow using the `main` branch.

**Example:**
```sh
# Initialize diary using DIARY_REPO
export DIARY_REPO=$HOME/my_diary
diary init

# Initialize a second diary by providing a path
diary init ~/my_second_diary
```

### Initializing a remote diary
To create a new diary that's tracked remotely you can run `diary init <diary_repo> <diary_remote>`. Both arguments are required for the remote to be set up. Be sure that the remote repository is empty when the initialization script is run.

**Example:**
```sh
# An empty remote exists at git@github.com:YourUsername/my_diary.git
diary init ~/my_diary git@github.com:YourUsername/my_diary.git
```

## Opening a diary
To open today's entry run `diary [diary_repo]`. This will either initialize a new entry or open an existing one based on the date. Once editing is done all changes are immediately committed (and pushed if a remote is set). The repo argument is optional if `DIARY_REPO` is defined.

## Using a remote diary
If a remote diary already exists then you can download it using `git clone` and begin using it immediately. The local repo will attempt to sync changes with the cloned diary.

**Example:**
```sh
# A remote diary with entries exists at git@github.com:YourUsername/my_diary.git
cd $HOME
git clone git@github.com:YourUsername/my_diary.git

# Open today's entry for that diary
diary my_diary
```

## Autocomplete
The source is shipped with `zsh/_diary` which can be used to setup autocomplete for `zsh`. If you're using `oh-my-zsh` it's as simple copying the `_diary` script to: `.oh-my-zsh/custom/plugins/diary/_diary` and adding it to the `plugins=(...)` list in your `.zshrc`.
