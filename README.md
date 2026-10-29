<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/helminth117-logo-dark.svg">
    <img src="assets/helminth117-logo-light.svg" alt="helminth117" width="420">
  </picture>
</p>

# TikTok LIVE Studio on Linux

Unofficial launcher and Arch Linux package that runs the Windows version of
**TikTok LIVE Studio** on Linux through [umu-launcher](https://github.com/Open-Wine-Components/umu-launcher)
and [GE-Proton](https://github.com/GloriousEggroll/proton-ge-custom), including a
Wine fix that makes **microphones and speakers work** inside the app.

> Not affiliated with TikTok or ByteDance. TikTok LIVE Studio is not
> redistributed here: the launcher downloads the official installer from
> TikTok's own servers.

[Español abajo](#español)

## Status

| Feature | State |
|---|---|
| Install / auto-update | Works (installer runs silently; its GUI renders black under Proton) |
| Login, studio UI | Works |
| Microphone / speakers | Works with the patched `mmdevapi.dll` from this repo |
| Camera (webcam) | Works |
| Display capture (screen or a window) | Works with the patched `winex11.so` and the capture helper |
| TikTok's own *Window capture* / *Game capture* | Do not work (they only see Windows apps); use *Display capture* and pick the window |
| Going LIVE | Not verified yet |

Tested on Arch Linux (Omarchy, Hyprland/Wayland, PipeWire, AMD Radeon Vega),
TikTok LIVE Studio 1.39.0, GE-Proton11-11.

## Install (Arch Linux)

```sh
git clone https://github.com/Helminth117/tiktok-live-studio-linux
cd tiktok-live-studio-linux
makepkg -si
```

`umu-launcher` is in the `multilib` repository. Then launch **TikTok LIVE Studio**
from your application menu, or run `tiktok-live-studio`.

On first launch the launcher:

1. asks TikTok's update service for the latest installer and its MD5,
2. downloads it to `~/.cache/tiktok-live-studio/` (resuming if TikTok's CDN
   drops the connection, which it does on long downloads),
3. installs it silently into its own prefix,
   `~/.local/share/tiktok-live-studio/prefix`,
4. starts the app with GE-Proton11-11 (umu downloads it the first time).

Other commands: `tiktok-live-studio install [EXE]`, `winecfg`, `winetricks ...`,
`reset` (deletes the prefix and your session). See `tiktok-live-studio --help`.

## Why the patched mmdevapi.dll

Without it, the audio mixer only shows *"Default device (No audio found)"* even
though Wine sees every PulseAudio/PipeWire device.

TikTok's media engine (`MediaSDK_Server.exe`) builds its device list by walking
each endpoint's device topology: `IMMDevice::Activate(IDeviceTopology)` →
`GetConnector(0)` → `IConnector::GetConnectedTo` → `IPart` → `GetTopologyObject`.
Wine only had stubs there (`E_NOTIMPL`), so every device was discarded.

[`mmdevapi-device-topology.patch`](mmdevapi-device-topology.patch) implements
`IDeviceTopology`, `IConnector` and `IPart` the way Windows presents a software
audio device: each endpoint's connector is connected to a connector on a
virtual adapter (`{2}.\\?\root#media#0000#{6994ad04-…}\wave`).

The launcher copies `mmdevapi.dll` into the prefix's `system32` and loads it
with `WINEDLLOVERRIDES=mmdevapi=n,b`, so GE-Proton itself is not modified.
Because the DLL is built against GE-Proton11-11's exact Wine tree, the launcher
pins `PROTONPATH=GE-Proton11-11`.

Also needed: Wine ≥ 10.15. TikTok's network library imports
`IPHLPAPI.SetPerTcp6ConnectionEStats`, so UMU-Proton 10.0 aborts at start.

## Screen and window capture

Wine has neither Windows Graphics Capture nor DXGI Desktop Duplication, so
TikTok falls back to GDI: it reads the desktop with `BitBlt`. Under Wayland the
X root window contains none of your native windows, so that read is black.

[`winex11-screen-capture.patch`](winex11-screen-capture.patch) makes
`X11DRV_GetImage` read the desktop from shared memory instead, when
`WINE_SCREEN_CAPTURE_SHM` is set. [`tiktok-live-studio-capture`](tiktok-live-studio-capture)
fills it: the first time TikTok reads the desktop it asks the
`org.freedesktop.portal.ScreenCast` portal, so your desktop shows its usual
**share dialog where you pick a screen or a window**, and it receives the frames
over PipeWire (rotated monitors are straightened). It stops when nothing reads
for 15 s.

In TikTok: *Add source → Display capture*. The choice is remembered; run
`tiktok-live-studio cambiar-captura` to be asked again.

The launcher runs the app with a copy of GE-Proton11-11 made of hard links
(`~/.local/share/tiktok-live-studio/proton`, almost no extra disk) where only
`winex11.so` differs; GE-Proton itself is not modified.

### Rebuilding the Wine modules

```sh
tools/prepare-wine.sh        # GE-Proton11-11 Wine tree in ~/Projects/wine-ge (~300 MB)
tools/build-wine-modules.sh  # applies both patches, builds mmdevapi.dll and winex11.so here
```

Needs `clang`, `lld`, `bison`, `flex`, `autoconf` and the X11 headers.

## Troubleshooting

- **Microphone far too sensitive**: check `pactl list sources`. If *Base Volume*
  is low (e.g. 10%) and the volume is high, the extra percentage is hardware
  boost. Lower it: `pactl set-source-volume @DEFAULT_SOURCE@ 30%`.
- **Generic icon in the menu (Omarchy)**: the shell indexes icons when it
  starts; run `omarchy-restart-shell` after installing.
- **Logs**: `~/.local/share/tiktok-live-studio/prefix/drive_c/users/steamuser/AppData/Roaming/TikTok LIVE Studio/logs/`.
- **Wine traces**: `WINEDEBUG=+mmdevapi tiktok-live-studio`.

## License

Launcher, PKGBUILD and scripts: 0BSD. `mmdevapi.dll` and the patch are derived
from Wine: LGPL-2.1-or-later (see [LICENSE](LICENSE) and [COPYING.LIB](COPYING.LIB)).

---

## Español

Lanzador no oficial y paquete de Arch Linux para usar la versión de Windows de
**TikTok LIVE Studio** en Linux con umu-launcher y GE-Proton. Incluye un arreglo
de Wine para que **el micrófono y los altavoces funcionen** dentro de la app.

No está afiliado a TikTok ni a ByteDance. El instalador se descarga de los
servidores oficiales de TikTok; aquí no se redistribuye.

### Instalación

```sh
git clone https://github.com/Helminth117/tiktok-live-studio-linux
cd tiktok-live-studio-linux
makepkg -si
```

Después abre **TikTok LIVE Studio** desde el menú o ejecuta `tiktok-live-studio`.
La primera vez descarga el instalador oficial (verificando su MD5), lo instala
en `~/.local/share/tiktok-live-studio/prefix` y arranca la app con GE-Proton11-11.

### El arreglo de audio

Sin `mmdevapi.dll` parcheada, el mezclador muestra «Default device (No audio
found)». El motor de medios de TikTok recorre la topología de cada dispositivo
(`IDeviceTopology` → `IConnector` → `IPart`) y Wine no la implementaba, así que
descartaba todos los dispositivos. El parche la implementa; el lanzador copia la
DLL al prefijo y la carga solo para esta app, sin modificar GE-Proton.

### Captura de pantalla y ventanas

En TikTok usa *Add source → Display capture*. La primera vez aparece el diálogo
de tu escritorio para compartir pantalla: elige **una pantalla o una ventana**.
La elección se recuerda; `tiktok-live-studio cambiar-captura` hace que vuelva a
preguntar. Las fuentes *Window capture* y *Game capture* propias de TikTok no
funcionan (solo ven apps de Windows).

Funciona así: Wine no tiene las APIs de captura de Windows y TikTok termina
leyendo el escritorio con GDI, que en Wayland sale negro. El `winex11.so`
parcheado toma esa imagen de memoria compartida, donde
`tiktok-live-studio-capture` deja lo que recibe del portal de captura por
PipeWire.

### Problemas comunes

- **Micrófono demasiado sensible**: si en `pactl list sources` el *Base Volume*
  es bajo (por ejemplo 10 %) y el volumen alto, ese extra es ganancia de
  hardware. Bájalo: `pactl set-source-volume @DEFAULT_SOURCE@ 30%`.
- **Icono genérico en el menú (Omarchy)**: la shell indexa los iconos al
  arrancar; ejecuta `omarchy-restart-shell` después de instalar.
- **No aparece el diálogo para compartir pantalla**: revisa que tengas un portal
  (`xdg-desktop-portal-hyprland`, `-gnome`, `-kde` o `-wlr`) y, en Hyprland, que
  `~/.config/hypr/xdph.conf` no apunte a un `custom_picker_binary` que ya no
  existe.
