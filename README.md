# M3 Quickshell Android widget
## To bring your empty desktop a life.
---

> [!NOTE]
> This is my first time coding Quickshell dotfiles, so any bugs and issues, you can just directly open up one [here](https://github.com/pdotrun/m3-quickshell-android-widget/issues).

### Quick Start
---
#### Required Dependencies
1. Quickshell (> v0.3)
2. Matugen (> v4.x)
3. libnotify (> v0.8)

#### Optional (to create the Android immersion)
1. [Google Sans](https://fonts.google.com/specimen/Google+Sans)

---
### Setting the dependencies
##### [Arch based Linux]
1. All of them should be in their repo respectively (extra / core)
- libnotify: `sudo pacman -S libnotify --needed --noconfirm`
- quickshell: `sudo pacman -S quickshell --needed --noconfirm` (or if you have beefy ahh computer: ```yay -S quickshell```)
- matugen: `sudo pacman -S matugen` (or if you have a version installed from rust/rustup, that'll work)

##### [Debian based Linux]
- libnotify & (optional) notify-send: ```sudo apt install libnotify-dev``` & ```sudo apt install libnotify-bin```
- (Trixie) Quickshell:
1. Make sure to add `trixie-backports` inside `/etc/apt/sources.list.d/backports.list` so it look like this:
```bash
deb http://deb.debian.org/debian trixie-backports main contrib non-free
```
2. Update and install:
```bash
sudo apt update
sudo apt install -t trixie-backports quickshell
```
- (Testing/Unstable/Forky/Sid) Quickshell:
```bash
sudo apt update
sudo apt install quickshell
```
- Matugen:
- (Precompiled/Bin):
```bash
MATUGEN_VERSION=$(curl -s "https://api.github.com/repos/InioX/matugen/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -sSL https://github.com/InioX/matugen/releases/latest/download/matugen-4.2.0-x86_64.tar.gz | sudo tar xz -C /usr/local/bin matugen
```
- (Cargo/Rust):
```bash
curl --proto '=https' --tlsv1.2 -sSf https://rustup.rs | sh
source "$HOME/.cargo/env"
cargo install matugen
```

### Setting the widgets up
1. Create matugen config folder (`mkdir -p ~/.config/matugen`) as well as its template folder (`mkdir -p ~/.config/matugen/templates`)
2. The snippet for the matugen as follow (located at `~/.config/matugen/config.toml`):

```toml
[templates.m3widgets]
input_path  = '~/.config/matugen/templates/m3widgets.json'
output_path = '~/.cache/m3widgets/colors.json'
```
- As for the json file (located at `~/.config/matugen/templates/m3widgets.json`):
```json
{
  "primary": "{{colors.primary.default.hex}}",
  "on_primary": "{{colors.on_primary.default.hex}}",
  "primary_container": "{{colors.primary_container.default.hex}}",
  "on_primary_container": "{{colors.on_primary_container.default.hex}}",
  "secondary": "{{colors.secondary.default.hex}}",
  "on_secondary": "{{colors.on_secondary.default.hex}}",
  "secondary_container": "{{colors.secondary_container.default.hex}}",
  "on_secondary_container": "{{colors.on_secondary_container.default.hex}}",
  "tertiary": "{{colors.tertiary.default.hex}}",
  "on_tertiary": "{{colors.on_tertiary.default.hex}}",
  "tertiary_container": "{{colors.tertiary_container.default.hex}}",
  "on_tertiary_container": "{{colors.on_tertiary_container.default.hex}}",
  "error": "{{colors.error.default.hex}}",
  "on_error": "{{colors.on_error.default.hex}}",
  "error_container": "{{colors.error_container.default.hex}}",
  "on_error_container": "{{colors.on_error_container.default.hex}}",
  "surface": "{{colors.surface.default.hex}}",
  "on_surface": "{{colors.on_surface.default.hex}}",
  "surface_variant": "{{colors.surface_variant.default.hex}}",
  "on_surface_variant": "{{colors.on_surface_variant.default.hex}}",
  "outline": "{{colors.outline.default.hex}}",
  "outline_variant": "{{colors.outline_variant.default.hex}}",
  "surface_container_lowest": "{{colors.surface_container_lowest.default.hex}}",
  "surface_container_low": "{{colors.surface_container_low.default.hex}}",
  "surface_container": "{{colors.surface_container.default.hex}}",
  "surface_container_high": "{{colors.surface_container_high.default.hex}}",
  "surface_container_highest": "{{colors.surface_container_highest.default.hex}}",
  "inverse_surface": "{{colors.inverse_surface.default.hex}}",
  "inverse_on_surface": "{{colors.inverse_on_surface.default.hex}}",
  "inverse_primary": "{{colors.inverse_primary.default.hex}}",
  "shadow": "{{colors.shadow.default.hex}}",
  "scrim": "{{colors.scrim.default.hex}}"
}
```

#### And you're done! if you have any features to request, you can submit them [here](https://github.com/pdotrun/m3-quickshell-android-widget/issues)

## Previews:
---
<img width="1231" height="658" alt="image" src="https://github.com/user-attachments/assets/2283257b-0aca-425c-ae5e-94e9dc8d950d" />
<img width="1366" height="717" alt="image" src="https://github.com/user-attachments/assets/fb6721a5-7af8-49db-9aa4-9b70185ddbff" />
<img width="849" height="660" alt="image" src="https://github.com/user-attachments/assets/3905d8b2-c626-4ebb-99c8-f0f45f40461d" />
<img width="1314" height="768" alt="image" src="https://github.com/user-attachments/assets/aceb90ff-2b8d-4e8d-87d8-1fde325cdfb3" />
