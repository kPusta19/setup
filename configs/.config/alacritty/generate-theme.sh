
#!/usr/bin/env bash

set -Eeuo pipefail

CONFIG_DIR="$HOME/.config/alacritty"
TEMPLATE="$CONFIG_DIR/templates/theme.toml.tpl"
OUTPUT="$CONFIG_DIR/themes/current.toml"

mkdir -p "$(dirname "$OUTPUT")"

: "${SETUP_BACKGROUND_COLOR:=#282828}"
: "${SETUP_BACKGROUND_ALT_COLOR:=#32302F}"
: "${SETUP_FOREGROUND_COLOR:=#D4BE98}"

: "${SETUP_RED_COLOR:=#EA6962}"
: "${SETUP_GREEN_COLOR:=#A9B665}"
: "${SETUP_YELLOW_COLOR:=#D8A657}"
: "${SETUP_BLUE_COLOR:=#7DAEA3}"
: "${SETUP_PURPLE_COLOR:=#D3869B}"
: "${SETUP_AQUA_COLOR:=#89B482}"

# Validate color values to prevent invalid TOML or shell injection.
validate_color() {
    [[ "$2" =~ ^#[[:xdigit:]]{6}$ ]] || {
        printf 'Invalid color: %s\n' "$1" >&2
        exit 1
    }
}

validate_color BACKGROUND "$SETUP_BACKGROUND_COLOR"
validate_color BACKGROUND_ALT "$SETUP_BACKGROUND_ALT_COLOR"
validate_color FOREGROUND "$SETUP_FOREGROUND_COLOR"
validate_color RED "$SETUP_RED_COLOR"
validate_color GREEN "$SETUP_GREEN_COLOR"
validate_color YELLOW "$SETUP_YELLOW_COLOR"
validate_color BLUE "$SETUP_BLUE_COLOR"
validate_color PURPLE "$SETUP_PURPLE_COLOR"
validate_color AQUA "$SETUP_AQUA_COLOR"

sed \
    -e "s|{{BACKGROUND}}|$SETUP_BACKGROUND_COLOR|g" \
    -e "s|{{BACKGROUND_ALT}}|$SETUP_BACKGROUND_ALT_COLOR|g" \
    -e "s|{{FOREGROUND}}|$SETUP_FOREGROUND_COLOR|g" \
    -e "s|{{RED}}|$SETUP_RED_COLOR|g" \
    -e "s|{{GREEN}}|$SETUP_GREEN_COLOR|g" \
    -e "s|{{YELLOW}}|$SETUP_YELLOW_COLOR|g" \
    -e "s|{{BLUE}}|$SETUP_BLUE_COLOR|g" \
    -e "s|{{PURPLE}}|$SETUP_PURPLE_COLOR|g" \
    -e "s|{{AQUA}}|$SETUP_AQUA_COLOR|g" \
    "$TEMPLATE" > "$OUTPUT"

printf 'Generated Alacritty theme: %s\n' "$OUTPUT"
