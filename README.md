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
| Install / updates | Works: the launcher installs TikTok's offered version silently before opening the app (the installer's GUI renders black under Proton) |
| Login, studio UI | Works |
| Microphone / speakers | Works with the patched `mmdevapi.dll` from this repo |
| Camera (webcam) | Works |
| Display capture (screen or a window) | Works with the patched `winex11.so` and the capture helper |
| Games (tested: Minecraft Java) | *Display capture* → pick the game's **window** or **screen** (game fullscreen): 25–59 fps, as fast as the game draws. A **region** works too, with black bars if it does not fill the frame |
| TikTok's own *Window capture* / *Game capture* | Do not work: they inject into Windows processes and only see Windows apps |
| Sharing a single **window** in the portal | Works with Minecraft Java (XWayland): about 37 fps, freezing up to 3 s when it changes size. Native Wayland windows: not tested |
| Several different captures at once | Not possible yet: every *Display capture* shows the same thing |
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
4. starts the app with GE-Proton11-11 (the launcher downloads it the first time and
   checks its SHA-512).

On every later launch it compares the installed version with the one TikTok's
server offers. If they differ, it downloads and installs that one silently before
opening the app, which avoids the app's own updater: a download window that cannot
be closed, followed by an installer that renders black. It follows the server even
to an older version, because the app would ask for that one anyway. Without network
it opens what is installed. Your session is kept. If the server changes while the
app is open, the app's own updater can still appear; close it and launch again.

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
downloads that exact release and points `PROTONPATH` at its folder.

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

In TikTok: *Add source → Display capture*. Only this source opens the share dialog,
and only when no choice is saved. TikTok has no button to change it: open
**Cambiar captura de TikTok** from your application menu, or run
`tiktok-live-studio cambiar-captura` (it switches right away, even while TikTok is
open).

There is **one capture at a time**: every *Display capture*, on any Display, shows the
same thing, because TikTok reads them all the same way. A capture that does not fill
the frame gets black bars instead of being stretched. If a shared window stops sending
frames, which happens when it changes size, the helper reconnects after 3 seconds.

For games, put the game in fullscreen and pick its **window** or its **screen**.
Minecraft Java (XWayland) worked at about 37 fps as a window. Resizing it, for example
with F11, freezes the image for up to 3 seconds. Minecraft also lowers its own frame rate
when it thinks you are AFK (*Video Settings → Inactivity FPS Limit*).

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
- **Display capture in red, "No video signal"**: the source remembers the monitor it
  was added on. After connecting or removing a monitor, add a new *Display capture*.
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

En cada arranque compara la versión instalada con la que ofrece el servidor de
TikTok. Si son distintas, la descarga y la instala en silencio antes de abrir la
app; así se evita el actualizador de la app, con su ventana de descarga que no se
puede cerrar y su instalador en negro. Sigue al servidor aunque ofrezca una versión
anterior, porque la app la pediría de todos modos. Sin red abre lo que ya está
instalado. La sesión se conserva. Si el servidor cambia con la app abierta, aún
puede salir el actualizador de la app: ciérrala y vuelve a abrirla.

### El arreglo de audio

Sin `mmdevapi.dll` parcheada, el mezclador muestra «Default device (No audio
found)». El motor de medios de TikTok recorre la topología de cada dispositivo
(`IDeviceTopology` → `IConnector` → `IPart`) y Wine no la implementaba, así que
descartaba todos los dispositivos. El parche la implementa; el lanzador copia la
DLL al prefijo y la carga solo para esta app, sin modificar GE-Proton.

### Captura de pantalla y ventanas

En TikTok usa *Add source → Display capture*. Solo esta fuente abre el diálogo de tu
escritorio para compartir pantalla, y solo si no hay una elección guardada: elige
**una pantalla, una ventana o una región**. TikTok no tiene un botón para cambiarla:
abre **Cambiar captura de TikTok** desde el menú de aplicaciones o ejecuta
`tiktok-live-studio cambiar-captura`, aunque TikTok esté abierto.

Solo hay **una captura a la vez**: todas las *Display capture*, en cualquier Display,
muestran lo mismo, porque TikTok las lee igual. Si la captura no llena el cuadro, lleva
barras negras en vez de estirarse.

Para juegos (probado con Minecraft Java) elige su **ventana** o, a pantalla completa,
su **pantalla**: llega a 25–59 fps. Si la ventana cambia de tamaño (por ejemplo con
F11), la imagen se congela hasta 3 segundos y se recupera sola. Las fuentes
*Window capture* y *Game capture* propias de TikTok no funcionan con juegos de Linux
(solo ven apps de Windows).

Funciona así: Wine no tiene las APIs de captura de Windows y TikTok termina
leyendo el escritorio con GDI, que en Wayland sale negro. El `winex11.so`
parcheado toma esa imagen de memoria compartida, donde
`tiktok-live-studio-capture` deja lo que recibe del portal de captura por
PipeWire.

### Problemas comunes

- **Micrófono demasiado sensible**: si en `pactl list sources` el *Base Volume*
  es bajo (por ejemplo 10 %) y el volumen alto, ese extra es ganancia de
  hardware. Bájalo: `pactl set-source-volume @DEFAULT_SOURCE@ 30%`.
- **Display capture en rojo, «No video signal»**: la fuente recuerda el monitor donde
  se añadió. Si conectas o quitas un monitor, añade una *Display capture* nueva.
- **Icono genérico en el menú (Omarchy)**: la shell indexa los iconos al
  arrancar; ejecuta `omarchy-restart-shell` después de instalar.
- **No aparece el diálogo para compartir pantalla**: revisa que tengas un portal
  (`xdg-desktop-portal-hyprland`, `-gnome`, `-kde` o `-wlr`) y, en Hyprland, que
  `~/.config/hypr/xdph.conf` no apunte a un `custom_picker_binary` que ya no
  existe.
