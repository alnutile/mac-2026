#!/bin/bash
# Run in Terminal or iTerm: bash mac-setup.sh
set -euo pipefail
setup_dir="$(cd "$(dirname "$0")" && pwd)"
if [[ "$(uname -s)" != Darwin ]]; then
  echo 'This script is for macOS.' >&2
  exit 1
fi
if [[ ! -f "$setup_dir/Brewfile" ]]; then
  echo 'Keep Brewfile in the same folder as mac-setup.sh.' >&2
  exit 1
fi
if [[ -x /opt/homebrew/bin/brew ]]; then
  brew_bin=/opt/homebrew/bin/brew
elif [[ -x /usr/local/bin/brew ]]; then
  brew_bin=/usr/local/bin/brew
elif command -v brew >/dev/null 2>&1; then
  brew_bin="$(command -v brew)"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    brew_bin=/opt/homebrew/bin/brew
  else
    brew_bin=/usr/local/bin/brew
  fi
fi
eval "$("$brew_bin" shellenv)"
setup_stamp="$(date +%Y%m%d-%H%M%S)"
backup_file() {
  if [[ -f "$1" ]]; then cp -p "$1" "$1.before-mac-setup.$setup_stamp"; fi
}
# Preserve existing settings; append Homebrew only if not already configured.
if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  backup_file "$HOME/.zprofile"
  printf '\n# Homebrew\neval "$(%s shellenv)"\n' "$brew_bin" >> "$HOME/.zprofile"
fi
bundle_failed=0
brew bundle --file="$setup_dir/Brewfile" || bundle_failed=1

# Oh My Zsh without running an installer that replaces your shell configuration.
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi
mkdir -p "$HOME/.cache/zsh" "$HOME/.config"
if ! grep -q 'oh-my-zsh.sh' "$HOME/.zshrc" 2>/dev/null; then
  backup_file "$HOME/.zshrc"
  cat >> "$HOME/.zshrc" <<'ZSH'

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP="$HOME/.cache/zsh/.zcompdump"
ZSH_THEME=""
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
ZSH
fi
if command -v starship >/dev/null 2>&1; then
  if ! grep -q 'starship init zsh' "$HOME/.zshrc" 2>/dev/null; then
    backup_file "$HOME/.zshrc"
    printf '\n# Starship prompt\neval "$(starship init zsh)"\n' >> "$HOME/.zshrc"
  fi
  if [[ ! -f "$HOME/.config/starship.toml" ]]; then
    cat > "$HOME/.config/starship.toml" <<'TOML'
add_newline = true
format = "$directory$git_branch$git_status$cmd_duration$line_break$character"
[directory]
style = "bold cyan"
truncation_length = 3
[git_branch]
symbol = "git:"
style = "bold purple"
[git_status]
style = "bold yellow"
[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
TOML
  fi
fi

# Fill missing Git identity settings; preserve any existing identity.
git config --global user.name >/dev/null 2>&1 || git config --global user.name alnutile
git config --global user.email >/dev/null 2>&1 || git config --global user.email alfrednutile@gmail.com

# Add the mini alias before wildcard rules, without replacing an existing alias.
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if ! awk 'tolower($1)=="host" {for(i=2;i<=NF;i++) if(tolower($i)=="mini") found=1} END {exit !found}' "$HOME/.ssh/config" 2>/dev/null; then
  backup_file "$HOME/.ssh/config"
  ssh_config_tmp="$(mktemp "$HOME/.ssh/config.setup.XXXXXX")"
  cat > "$ssh_config_tmp" <<'SSH'
Host mini
    HostName alfreds-mac-mini.tail110302.ts.net
    User alfrednutile
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    AddKeysToAgent yes

SSH
  if [[ -f "$HOME/.ssh/config" ]]; then cat "$HOME/.ssh/config" >> "$ssh_config_tmp"; fi
  mv "$ssh_config_tmp" "$HOME/.ssh/config"
fi
chmod 600 "$HOME/.ssh/config"
echo 'Shell, Git defaults, and mini alias configured. Open a new terminal window.'
echo 'See MAC-SETUP.md for GitHub login, SSH key creation, and app first-run setup.'
if [[ "$bundle_failed" == 1 ]]; then
  echo 'Some Homebrew installs failed. Review the errors and rerun this script.' >&2
  exit 1
fi
brew bundle check --file="$setup_dir/Brewfile"
