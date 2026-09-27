# Alfred's new Mac setup

## Run the setup

Save `mac-setup.sh` and `Brewfile` together in one folder. Open Terminal, change to that folder, and run:

```bash
bash mac-setup.sh
```

Run this from a normal Terminal or iTerm window so macOS can ask for your password. Homebrew's installer installs Apple's Command Line Tools if needed. Allow that installation to finish.

The script installs the apps below, configures your shell, fills in missing Git identity settings, and adds your `mini` SSH alias. Existing configurations are preserved; files it changes are backed up when present. It can be rerun after a partial installation. It may upgrade existing Homebrew packages to satisfy the Brewfile. Package availability and macOS requirements can change over time.

## Complete software list

| Software | Homebrew package | Purpose |
| --- | --- | --- |
| Homebrew | Installed by the script if missing | Package manager |
| Git | `git` | Version control |
| GitHub CLI | `gh` | GitHub from the terminal |
| Herdr | `herdr` | Coding-agent terminal runtime |
| Starship | `starship` | Prompt showing folder, Git branch, and changes |
| Oh My Zsh | Official GitHub repository | Zsh configuration and Git plugin |
| iTerm2 | `iterm2` | Terminal |
| Visual Studio Code | `visual-studio-code` | Editor and `code` command |
| Claude desktop | `claude` | Claude app |
| Claude Code | `claude-code` | `claude` terminal command |
| Codex CLI | `codex` | `codex` terminal command |
| Grok Bot | `grok-bot` | Grok Bot app |
| ChatGPT | `chatgpt` | Desktop app |
| Docker Desktop | `docker-desktop` | Containers |
| Tailscale | `tailscale-app` | Network connection to your mini |
| Google Chrome | `google-chrome` | Browser |
| CleanShot X | `cleanshot` | Screenshots and recording |
| Raycast | `raycast` | Launcher |
| Spotify | `spotify` | Music |
| Slack | `slack` | Team messaging |
| 1Password | `1password` | Password manager |

ChatGPT and 1Password were already present on this Mac, so they are included for the next one. Herdr is the tool from https://herdr.dev/. Laravel Herd is excluded. Screen Sharing is built into macOS and needs no separate app installation.

## Manual Homebrew commands

If you prefer to install the packages manually after Homebrew is ready:

```bash
brew install git gh herdr starship

brew install --cask \
  iterm2 \
  visual-studio-code \
  claude \
  claude-code \
  codex \
  grok-bot \
  chatgpt \
  docker-desktop \
  tailscale-app \
  google-chrome \
  cleanshot \
  raycast \
  spotify \
  slack \
  1password
```

These commands install software only. The setup script also configures Oh My Zsh, Starship, Git identity, and your SSH alias.

## Git and GitHub

The script fills in these global defaults only if missing:

```bash
git config --global user.name alnutile
git config --global user.email alfrednutile@gmail.com
```

Sign in on the new Mac, choose GitHub.com and HTTPS, then connect Git authentication to GitHub CLI:

```bash
gh auth login
gh auth setup-git --hostname github.com
gh auth status
```

## SSH access to the mini

The script adds this alias if there is no existing `mini` alias:

```sshconfig
Host mini
    HostName alfreds-mac-mini.tail110302.ts.net
    User alfrednutile
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    AddKeysToAgent yes
```

First sign in to Tailscale on the new Mac and ensure the mini is reachable.

Generate a separate key for the new computer. This checks for both files so an existing key is not overwritten:

```bash
if [ -e ~/.ssh/id_ed25519 ] || [ -e ~/.ssh/id_ed25519.pub ]; then
  echo 'Existing key found; keeping it.'
else
  ssh-keygen -t ed25519 -C 'alfrednutile' -f ~/.ssh/id_ed25519
fi
```

Choose a passphrase when prompted, or press Return twice for no passphrase, matching the choice made for this Mac. For a passphrase-protected key:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

For a key without a passphrase:

```bash
ssh-add ~/.ssh/id_ed25519
```

Copy only the public key to the mini:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub mini
ssh mini
```

Verify the mini's host-key fingerprint on the first connection. The copy step asks for the mini's login password. Keep the private key on its originating Mac; do not place it in this setup folder or a Git repository. This setup does not enable inbound SSH or Screen Sharing on the new Mac.

## First-run checklist

- Open a new iTerm window to load Oh My Zsh and Starship.
- Sign in to 1Password and Chrome.
- Sign in to GitHub CLI using the commands above.
- Open Claude, ChatGPT, Grok Bot, Slack, and Spotify and sign in.
- Run `claude` and `codex` and complete their sign-in flows.
- Open Tailscale, sign in, and approve its required macOS network prompts.
- Open Docker Desktop and complete its initial setup; wait for the engine to start.
- Open CleanShot X, activate your license, and grant the capture permissions you want.
- Open Raycast and choose your shortcut and permissions.
- Open Visual Studio Code. Sign in to Settings Sync if you want to restore extensions and preferences. No extra VS Code extensions were installed by this setup.
- Run `herdr` from iTerm when you want to use it. The script does not start it at login.

## Verify

```bash
brew --version
git --version
gh --version
herdr --version
starship --version
claude --version
codex --version
code --version
docker --version
gh auth status
ssh -G mini
```

After Docker Desktop has started:

```bash
docker info
```

Check package installation from the setup folder:

```bash
brew bundle check --file=Brewfile
```

SSH keys, passwords, tokens, sign-ins, licenses, and app data are not bundled in these files.
