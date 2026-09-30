#!/usr/bin/env bash
# Install the four Catppuccin themes for bat, then rebuild the cache.
set -euo pipefail

command -v bat >/dev/null 2>&1 || { echo "bat is not installed"; exit 1; }

themes_dir="$(bat --config-dir)/themes"
mkdir -p "$themes_dir"

base_url="https://github.com/catppuccin/bat/raw/main/themes"

for flavor in Latte Frappe Macchiato Mocha; do
  echo "Downloading Catppuccin $flavor theme..."
  curl -fSL -o "$themes_dir/Catppuccin $flavor.tmTheme" \
    "$base_url/Catppuccin%20$flavor.tmTheme"
done

bat cache --build
echo "bat themes installed: $(bat --list-themes | grep -ci catppuccin) Catppuccin themes available"
