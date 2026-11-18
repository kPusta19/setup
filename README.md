# Debian BSPWM Rice

Independent installers for Debian 12/13:

```bash
curl -fsSL https://raw.githubusercontent.com/OWNER/debian-bspwm/main/ui.sh | bash
curl -fsSL https://raw.githubusercontent.com/OWNER/debian-bspwm/main/audio.sh | bash
curl -fsSL https://raw.githubusercontent.com/OWNER/debian-bspwm/main/bluetooth.sh | bash
```

Replace OWNER with your GitHub account. Override defaults with `BSPWM_REPO` and `BSPWM_BRANCH`.

Local test:
```bash
./modules/ui/install.sh --dry-run
./modules/audio/install.sh --dry-run
./modules/bluetooth/install.sh --dry-run
```

Flags: `--dry-run`, `--yes`, `--verbose`, `--help`.

`ui.sh` installs only Xorg/BSPWM/desktop packages, GPU-related packages and touchpad config.
`audio.sh` installs PipeWire, WirePlumber, PulseAudio compatibility, pavucontrol and pamixer.
`bluetooth.sh` installs BlueZ, Blueman and rfkill.
`install.sh` remains an optional interactive selector, not the required entrypoint.
