# Polybar Configuration Directory

## Directory Overview
This directory (`~/.config/polybar`) contains configuration files for **Polybar**, a fast and easy-to-use tool for creating status bars on Linux. It defines the visual appearance, modules, and behavior of the status bar used in the user's desktop environment (likely with `bspwm` or `i3` as referenced in the configs).

## Key Files

*   **`config`**: The active/primary configuration file.
    *   **Bar Name**: `bar1`
    *   **Modules**: `bspwm`, `i3`, `xwindow` (center), `xbacklight`, `alsa`, `network`, `cpu`, `temperature`, `battery`, `date`.
    *   **Fonts**: configured to use `fixed`, `unifont`, and `siji` (for icons).
    *   **Tray**: Positioned on the right.
*   **`config1`**: An alternative or backup configuration file (resembling the Polybar example config).
    *   **Bar Name**: `example`
    *   **Modules**: Includes a wider range like `mpd`, `filesystem`, `memory`, `wlan`, `eth`, `pulseaudio`, and `powermenu`.

## Usage

To launch the bar defined in `config`, use the following command in your terminal or startup script:

```bash
polybar -c ~/.config/polybar/config bar1
```

To launch the example bar from `config1`:

```bash
polybar -c ~/.config/polybar/config1 example
```

## Configuration details

### Modules
The configuration makes use of several internal modules:
*   **Workspaces**: Supports both `bspwm` and `i3`.
*   **System Monitoring**: CPU, Memory, Temperature, Battery.
*   **Networking**: WiFi (`wlan`) and Ethernet (`eth`) status.
*   **Media**: Volume control via `alsa` or `pulseaudio`, and MPD support (in `config1`).
*   **Utils**: Date/Time, Backlight control.

### Visual Style
*   **Colors**: Defines a dark theme with high contrast foregrounds and specific color alerts for urgent states.
*   **Icons**: Relies on `siji` font for glyphs (e.g., battery, wifi icons).

## Resources
*   [Polybar Github Repository](https://github.com/polybar/polybar)
*   [Polybar Wiki](https://github.com/polybar/polybar/wiki)
