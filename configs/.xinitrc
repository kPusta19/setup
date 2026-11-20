# Cursor
export XCURSOR_THEME="Bibata-Modern-Classic"
export XCURSOR_SIZE=20
export XCURSOR_PATH="$HOME/.local/share/icons:$HOME/.icons:/usr/share/icons"

# Xresources
xrdb -merge ~/.Xresources

# BSPWM
exec bspwm
