# Git Hooks Installer

A lightweight installer for reusable Git hooks.

The installer downloads a manifest of available hooks, lets you choose which ones to enable, and installs them into your local repository. Hooks are fetched from a remote source, making it easy to update or add new hooks without changing the installer.

## Features

- Interactive hook selection
- Modular, reusable hook scripts
- Easy to extend by updating `manifest.json`
- Project-local installation (`.git/hooks`)
- Supports multiple scripts per Git hook via wrapper hooks

## Usage

```bash
curl -fsSL https://raw.githubusercontent.com/0xankit/safegit/refs/heads/main/install.sh | bash
```

Follow the prompts to select the hooks you want to install.

## Adding a New Hook

1. Add the hook script under `hooks/<git-hook>/`.
2. Register it in `manifest.json`.
3. No changes to `install.sh` are required.

## Project Structure

```bash
.
├── install.sh
├── manifest.json
└── hooks/
    ├── pre-commit/
    ├── pre-push/
    └── post-commit/
```

## License

This project is licensed under the MIT License. See the LICENSE file for details.
