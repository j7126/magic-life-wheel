#!/usr/bin/env bash
set -euo pipefail

# Fetch MTGJSON data assets from the j7126/mtgjson_converter_dart GitHub release
# Saves `set_list.bin` and `all_cards.bin` to the repository `data/` directory.

REPO="j7126/mtgjson_converter_dart"
SUPPORTED_VERSION="1.2.0"

if [ "$#" -gt 0 ]; then
  SUPPORTED_VERSION="$1"
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "This script requires 'jq'. Install it (e.g. 'brew install jq' or apt-get)." >&2
  exit 2
fi

echo "Fetching latest release info for $REPO..."
json=$(curl -sL "https://api.github.com/repos/$REPO/releases/latest")
tag=$(printf '%s' "$json" | jq -r '.tag_name')

if [ "$tag" != "$SUPPORTED_VERSION" ]; then
  echo "Latest release tag ($tag) does not match supported version ($SUPPORTED_VERSION)." >&2
  exit 3
fi

set_list_name=$(printf '%s' "$json" | jq -r '.assets[] | select(.name | test("^set_list_[0-9]+")) | .name' | head -n1)
all_cards_name=$(printf '%s' "$json" | jq -r '.assets[] | select(.name | test("^all_cards_[0-9]+")) | .name' | head -n1)

set_list_url=$(printf '%s' "$json" | jq -r '.assets[] | select(.name=="'"$set_list_name"'") | .browser_download_url')
all_cards_url=$(printf '%s' "$json" | jq -r '.assets[] | select(.name=="'"$all_cards_name"'") | .browser_download_url')

if [ -z "$set_list_url" ] || [ -z "$all_cards_url" ]; then
  echo "Could not find required release assets (set_list / all_cards)." >&2
  exit 4
fi

extract_date() {
  local name="$1"
  printf '%s' "$name" | sed -E 's/^[^0-9]*_([0-9]+).*/\1/'
}

set_list_date=$(extract_date "$set_list_name")
all_cards_date=$(extract_date "$all_cards_name")

if [ "$set_list_date" != "$all_cards_date" ]; then
  echo "Error: asset build dates do not match: $set_list_date vs $all_cards_date" >&2
  exit 5
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="$REPO_ROOT/data"
mkdir -p "$OUT_DIR"

echo "Downloading set_list ($set_list_name) -> $OUT_DIR/set_list.bin"
curl -L --fail -o "$OUT_DIR/set_list.bin" "$set_list_url"

echo "Downloading all_cards ($all_cards_name) -> $OUT_DIR/all_cards.bin"
curl -L --fail -o "$OUT_DIR/all_cards.bin" "$all_cards_url"

echo "Downloaded build date: $set_list_date"
echo "Files saved to: $OUT_DIR"
echo "Done."

exit 0
