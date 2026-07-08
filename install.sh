#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${HOOKS_BASE_URL:-https://raw.githubusercontent.com/0xankit/safegit/refs/heads/main}"
MANIFEST_URL="$BASE_URL/manifest.json"

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
hooks_dir="$repo_root/.git/hooks"

if [ ! -d "$repo_root/.git" ]; then
  echo "Error: must be run inside a Git repository."
  exit 1
fi

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: missing required command: $1"
    exit 1
  }
}

need_cmd curl
need_cmd jq

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

manifest="$tmp_dir/manifest.json"
curl -fsSL "$MANIFEST_URL" -o "$manifest"

echo "Available hooks:"
jq -r '.hooks[] | "\(.id): \(.name)\n  \(.description)\n"' "$manifest"

echo
echo "Enter hook ids to enable, separated by spaces."
echo "Example: whitespace-newline protected-branches"
read -r -p "> " selected

[ -n "$selected" ] || {
  echo "No hooks selected."
  exit 0
}

mkdir -p "$hooks_dir"

for hook_id in $selected; do
  item="$(jq -c --arg id "$hook_id" '.hooks[] | select(.id == $id)' "$manifest")"

  if [ -z "$item" ]; then
    echo "Unknown hook id: $hook_id"
    exit 1
  fi

  git_hook="$(echo "$item" | jq -r '.git_hook')"
  remote_path="$(echo "$item" | jq -r '.path')"

  target="$hooks_dir/$git_hook"
  local_script="$hooks_dir/${git_hook}.${hook_id}.sh"

  echo "Installing $hook_id into $git_hook..."

  curl -fsSL "$BASE_URL/$remote_path" -o "$local_script"
  chmod +x "$local_script"

  if [ ! -f "$target" ]; then
    cat > "$target" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

hook_name="$(basename "$0")"
hook_dir="$(cd "$(dirname "$0")" && pwd)"

for script in "$hook_dir/$hook_name".*.sh; do
  [ -e "$script" ] || continue
  "$script" "$@"
done
EOF
    chmod +x "$target"
  fi
done

echo "Hooks installed successfully."