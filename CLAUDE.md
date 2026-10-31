# TikTok LIVE Studio en Linux: notas para Claude

Port de TikTok LIVE Studio a Arch con GE-Proton11-11 y umu-launcher. El usuario rechazó
OBS: el objetivo es que funcione la app de TikTok. El README explica instalación y uso;
aquí está lo que no se ve en el código y lo que falta. Estado: 1.6.6. Probado en laptop (Ryzen 5 PRO 5650U, Radeon Vega, Hyprland).

Responde siempre en español.

## Reglas

- **Go LIVE:** nunca pulses "Go LIVE" en el estudio sin confirmación explícita: es una
  transmisión pública real. El "Go LIVE →" de la pantalla de inicio solo abre el estudio.
- **sudo:** no pidas ni guardes contraseñas. El usuario instala paquetes en su terminal.
- **`activar-deteccion`:** registra un script como picker del portal. La corre el usuario.
- **Commits y push:** solo si los pide. Si `gh` tiene activa otra cuenta, no la cambies:
  `git -c credential.helper= -c credential.helper='!f() { echo username=Helminth117; echo "password=$(gh auth token --user Helminth117)"; }; f' push`
- **Empaquetado:** al cambiar un archivo fuente, sube `pkgver` y recalcula los `sha256sums`.
- **Mundos de Minecraft:** no toques los del usuario.

## Pendiente, en orden

### 1. Probar en la PC de la casa (hoy)

1. `git clone https://github.com/Helminth117/tiktok-live-studio-linux && cd tiktok-live-studio-linux && makepkg -si`
2. Si `~/.config/hypr/xdph.conf` no apunta al picker, el usuario corre
   `tiktok-live-studio activar-deteccion`. Sin eso, los Link no encuentran solas las apps.
3. Abre la app desde el menú e inicia sesión. Revisa micrófono, altavoces y cámara.
4. Prueba Display capture y mide FPS. Comprueba si parpadea o sale negro.
5. Prueba un juego con Display capture y uno con Link (`nueva-captura`). Con Link, pega la
   dirección en la fuente Link de TikTok.
6. Cierra y reabre una app capturada: no debe salir ningún diálogo.
7. **Toma la línea base de consumo** (abajo) antes de optimizar.
8. **LIVE real**, solo cuando el usuario lo confirme. Si funciona, cambia "Going LIVE" en
   el README a verificado.

Si la PC tiene GPU NVIDIA o un monitor rotado, son casos sin probar. Lo mismo con otra
versión de xdph: el crash descrito abajo puede ser distinto.

### 2. Bajar el consumo (lo último que pidió el usuario)

Medición en la laptop con 3 Link activas y ventanas casi quietas (100 = un núcleo):

| Proceso | CPU |
|---|---:|
| MediaSDK_Server (compone la escena) | 165 |
| Helper de Python (tres hilos de pipewiresrc de 34 a 39) | 118 |
| CrGpuMain | 99 |
| 4 CrRendererMain (de 27 a 37 cada uno) | ~125 |
| Hyprland | 32 |
| wineserver | 30 |
| CrBrowserMain | 27 |

Una ventana quieta igual entrega unos 33 FPS, y cada cuadro se comprime y descomprime.

`jpegenc` en un patrón sintético, un núcleo, por cuadro:

| Tamaño | Tiempo |
|---|---:|
| 1920x1080, calidad 85 | 12 ms |
| 1920x1080, calidad 60 | 13 ms |
| 1280x720 | 5 ms |
| 960x540 | 2 ms |

Sin medir el costo de escalar. Bajar la calidad no ayuda. GStreamer no ofrece aquí un
codificador JPEG por VA. Revisa si la PC de la casa sí lo tiene (`gst-inspect-1.0 | grep -i jpeg`).

Cambios, de más a menos ahorro esperado:

1. **Saltar cuadros repetidos** en `LinkCapture` (por ejemplo, comparar una muestra del
   cuadro). Cuidado: MJPEG sin cuadros nuevos no debe parecerle caído a la página.
2. **Comprimir a menos de 1080p:** `videoscale` antes de `jpegenc` en `LinkCapture.TAIL`,
   idealmente según el tamaño de la caja. Mide si escalar se come la ganancia.
3. **Pausar fuentes ocultas (idea del usuario).** Sin probar. Primero averigua si ocultar
   una Link con el ojo corta la conexión: mira `ss -tn` en los puertos 870x mientras el
   usuario la oculta 20 s, con "Always keep active" encendido y luego apagado. Si la corta,
   ya funciona: `LinkFrames.last_read` detiene la captura a los 15 s sin clientes. Si no,
   prueba `document.hidden`/`visibilitychange` en la página de la Link.
4. **Limitar FPS:** `videorate` solo descarta después de copiar. Para ahorrar antes, habría
   que pedir menos cuadros a PipeWire o usar `screencopy:max_fps` de xdph. Debería ser
   opcional: no conviene en juegos.
5. Revisar si hacen falta `always-copy=true` y `videoconvert`.

Mide cada cambio de punta a punta contra la línea base, con las mismas fuentes. Se vieron
errores de los filtros de belleza en los registros; no se sabe si están activos ni cuánto
pesan en MediaSDK.

### 3. Menores

- Elegir Minecraft y Warp una vez con "Cambiar captura", para que recuerden la app.
- Sin probar: Text, Image y Video; escribir con teclado físico en campos de TikTok.
- Una Display capture salió negra una vez, sin causa conocida.
- Reportar a xdph el crash de abajo.

## Cómo funciona

- **Audio:** `mmdevapi.dll` parcheado implementa IDeviceTopology. Sin él, MediaSDK descarta
  todos los dispositivos.
- **Display capture:** TikTok hace BitBlt del root. `winex11.so` parcheado (`X11DRV_GetImage`)
  lee `/dev/shm/tiktok-live-studio-capture-<uid>.1`, que llena el helper (portal ScreenCast
  y GStreamer `pipewiresrc`). Todas las Display leen igual, así que no se pueden distinguir.
- **Capturas extra:** `LinkCapture`, ranuras N>=2, MJPEG en `127.0.0.1:8700+N/<secreto>/`.
- **Elección recordada:** `tiktok-live-studio-picker` elige la clase en
  `~/.cache/tiktok-live-studio/capture.N.class` para la ranura de `<shm>.picking`, y sale
  con 1 sin diálogo si la app está cerrada.
- **Reconstruir Wine:** `tools/prepare-wine.sh`, luego `tools/build-wine-modules.sh`, luego
  `git checkout -- mmdevapi.dll` si solo cambió `winex11.so`.

## Cosas que costó descubrir

- **Tirones de la vista previa:** con 30 cuadros parejos de entrada y GPU al 55 %, la vista
  previa cambia unas 20 veces por segundo. Una grabación local sale a 30 FPS sin repetidos,
  así que no son de la captura, de Link, de la GPU ni del juego. Falta medirlo en un LIVE.
- **NVIDIA:** TikTok con Minecraft con mods llenó la memoria de video (`NV_ERR_NO_MEMORY`,
  menús de Omarchy sin dibujarse). Se recupera al cerrar TikTok. TikTok solo no lo provocó.
- **Ventana fuera de pantalla:** con monitores que no empiezan en x=0, Wine la pone donde no
  hay pantalla y la devuelve si se mueve flotando. `keep_window_visible` la acopla.
- **`struct.pack_into`** pone en cero la zona antes de escribir: por eso `Shm` usa `words`.
- **Sin xdotool:** `hl.dsp.cursor.move` mueve el cursor (TikTok reacciona) y un clic por
  `XTestFakeButtonEvent` de `libXtst` llega a la app; la coordenada X es la de `xrandr`.
- **El campo Link** rechaza IP, `localhost` y `.localhost`: por eso se usa `lvh.me`.
- **La página Link** debe terminar de cargar antes de iniciar el video, o TikTok queda gris.
  Un MJPEG caído no da error en `<img>`: el canal `EventSource` `events` reinicia el video.
- **xdph 1.4.1** hace SIGSEGV en `pw_core_disconnect` al cerrar una ventana capturada, y
  caen todas las capturas. No se arregla desde aquí. El helper vigila `NameOwnerChanged` del
  portal y reinicia las capturas de una en una: reiniciarlas juntas coincidió con un SIGABRT.
- **Un token de ventana** de una app cerrada dice "restore data valid" y da un stream vacío.
- **libgstpipewire** puede tumbar el helper cuando muere el portal: por eso `supervise()`.
- **Rotación:** el portal puede mandar rotate-270 en un monitor sin rotar. Solo se gira si
  la forma del cuadro difiere del tamaño del portal.
- **Window y Game capture de TikTok** solo ven apps de Windows. Un proxy Wine + Window
  capture se descartó: la imagen queda chica en una esquina.
- **Actualizaciones:** el servidor de TikTok puede ofrecer una versión más vieja, y el
  launcher la sigue para que no salga el actualizador de la app.

## Probar y controlar la app

- **Probar el helper del repo sin instalar:**
  `TTLS_CAPTURE_HELPER=$PWD/tiktok-live-studio-capture setsid -f tiktok-live-studio`.
  El helper en marcha no cambia al actualizar el paquete: reinicia TikTok.
- **Medir la vista previa** con `grim`, no el shm: el shm no muestra el respaldo negro de
  Wine. Al leer el shm usa `buffering=0`.
- **Clics:** el primero en TikTok a menudo no entra. Mueve, haz clic, verifica y repite.
- **Texto:** el teclado de hypruse lo deforma. Usa `xdotool type` (solo letras y dígitos) o
  `wl-copy` más `xdotool key ctrl+v`. Las listas se manejan con `xdotool key Down` y `Return`.
- **Procesos:** `pkill -f` y `pgrep -f 'TikTok LIVE Studio.exe'` coinciden con tu propio
  shell (salida 144). Busca líneas de comando que empiecen con `C:\`.
- **Segunda app Wine junto a TikTok:** usa `PROTON_VERB=run`.
