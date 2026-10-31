# Maintainer: Joseph <joseph62937@gmail.com>
pkgname=tiktok-live-studio-wine
pkgver=1.6.5
pkgrel=1
pkgdesc="TikTok LIVE Studio (Windows) en Linux mediante umu-launcher/Proton"
arch=('x86_64')
url="https://github.com/Helminth117/tiktok-live-studio-linux"
# El lanzador y el ayudante de captura son 0BSD; mmdevapi.dll y winex11.so son
# Wine (GE-Proton11-11) con los parches incluidos, LGPL-2.1-or-later.
license=('0BSD' 'LGPL-2.1-or-later')
depends=('bash' 'curl' 'jq' 'umu-launcher' 'xdg-user-dirs' 'xdg-utils'
         'python' 'python-gobject' 'gstreamer' 'gst-plugins-base' 'gst-plugins-good'
         'gst-plugin-pipewire' 'xdg-desktop-portal')
optdepends=('zenity: diálogos al iniciar desde el menú de aplicaciones'
            'wl-clipboard: copiar la dirección de cada captura nueva'
            'xdg-desktop-portal-hyprland: captura de pantalla en Hyprland'
            'xdg-desktop-portal-wlr: captura de pantalla en Sway y otros wlroots'
            'xdg-desktop-portal-gnome: captura de pantalla en GNOME'
            'xdg-desktop-portal-kde: captura de pantalla en KDE Plasma')
options=('!strip' '!debug')
source=('tiktok-live-studio'
        'tiktok-live-studio-capture'
        'tiktok-live-studio-picker'
        'tiktok-live-studio.desktop'
        'tiktok-live-studio-cambiar-captura.desktop'
        'tiktok-live-studio-nueva-captura.desktop'
        'tiktok-live-studio.svg'
        'mmdevapi.dll'
        'mmdevapi-device-topology.patch'
        'winex11.so'
        'winex11-screen-capture.patch'
        'LICENSE'
        'COPYING.LIB')
sha256sums=('832121fcad7eeb5636871d46dd443960427ed6f9fb57393ba17ce10f064b7f52'
            'c34eb100d2529ecb962bb77dd3416ead1f6f6c0b6de3a6221f784edc695c810b'
            '885883c779d6d90d279bf35054169950a70a3fcd76da7f8d2e4c12947fd6e05d'
            '456ef04418a8ce085bfbeb5f0ac3ba06e71382e6bdebccb8653f01a43f3fbf48'
            '8695816749bb38a351b6bd7c44d5fd1d2f6c4c6e80038c9c8e1360ef9c92ac5f'
            'a8e3c4f3c3e33f99d68244a43a5fc8ff6fb59d1a3da4505465da4b47bb68f768'
            'a8ec3a4b88bf16dd1af1c8b97c51ec9143d1005269276935adee67ec79626417'
            '668fb71bc5bc7599301f6bde780188aa0c4b6f2e1f74ce15fc183d1650fb2e15'
            '5c17760dfa02a772b1c4963cbe412345e1ff726390f63012d161eb3f3be09144'
            'c66977cdd1b39ff64a90d9771409726c94573732894ddd6cb4763faf165424e2'
            '55f83f9ba2bb1fb5728418cb09dcf33ef9787c413ee2704e452e041cf6f32351'
            'd96b03bc7c276da218bd31dea3aa445b10afaf184396ef824bf6739fd018f29b'
            'e237fa56668030e928551ddd60f05df5fe957f75eab874bbd017e085ed722e7c')

package() {
  install -Dm755 tiktok-live-studio "$pkgdir/usr/bin/tiktok-live-studio"
  install -Dm755 tiktok-live-studio-capture "$pkgdir/usr/lib/tiktok-live-studio/tiktok-live-studio-capture"
  install -Dm755 tiktok-live-studio-picker "$pkgdir/usr/lib/tiktok-live-studio/tiktok-live-studio-picker"
  install -Dm644 tiktok-live-studio.desktop "$pkgdir/usr/share/applications/tiktok-live-studio.desktop"
  install -Dm644 tiktok-live-studio-cambiar-captura.desktop "$pkgdir/usr/share/applications/tiktok-live-studio-cambiar-captura.desktop"
  install -Dm644 tiktok-live-studio-nueva-captura.desktop "$pkgdir/usr/share/applications/tiktok-live-studio-nueva-captura.desktop"
  install -Dm644 tiktok-live-studio.svg "$pkgdir/usr/share/icons/hicolor/scalable/apps/tiktok-live-studio.svg"
  install -Dm644 mmdevapi.dll "$pkgdir/usr/share/tiktok-live-studio/mmdevapi.dll"
  install -Dm644 mmdevapi-device-topology.patch "$pkgdir/usr/share/tiktok-live-studio/mmdevapi-device-topology.patch"
  install -Dm644 winex11.so "$pkgdir/usr/share/tiktok-live-studio/winex11.so"
  install -Dm644 winex11-screen-capture.patch "$pkgdir/usr/share/tiktok-live-studio/winex11-screen-capture.patch"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  install -Dm644 COPYING.LIB "$pkgdir/usr/share/licenses/$pkgname/COPYING.LIB"
}
