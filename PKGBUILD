# Maintainer: Joseph <joseph62937@gmail.com>
pkgname=tiktok-live-studio-wine
pkgver=1.2.0
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
            'xdg-desktop-portal-hyprland: captura de pantalla en Hyprland'
            'xdg-desktop-portal-wlr: captura de pantalla en Sway y otros wlroots'
            'xdg-desktop-portal-gnome: captura de pantalla en GNOME'
            'xdg-desktop-portal-kde: captura de pantalla en KDE Plasma')
options=('!strip' '!debug')
source=('tiktok-live-studio'
        'tiktok-live-studio-capture'
        'tiktok-live-studio.desktop'
        'tiktok-live-studio.svg'
        'mmdevapi.dll'
        'mmdevapi-device-topology.patch'
        'winex11.so'
        'winex11-screen-capture.patch')
sha256sums=('a29d7aa7723e2e852e53c8d4fcef4fd544603f364670b362b6bff61f0512939e'
            '41e5b4ba9ec83af1ce3f0d0feec2dfa2f9391a2b7baa7ed38547ae948b5830d0'
            '456ef04418a8ce085bfbeb5f0ac3ba06e71382e6bdebccb8653f01a43f3fbf48'
            'a8ec3a4b88bf16dd1af1c8b97c51ec9143d1005269276935adee67ec79626417'
            '668fb71bc5bc7599301f6bde780188aa0c4b6f2e1f74ce15fc183d1650fb2e15'
            '5c17760dfa02a772b1c4963cbe412345e1ff726390f63012d161eb3f3be09144'
            'b6e5dbf3cddfbecf8a6cdad96e485940cdb77a8c58b8313c1d6a079403147988'
            'e9256146b89365ba142d63b3b8e70a7001287625c18e16c94fd03c26bda371ee')

package() {
  install -Dm755 tiktok-live-studio "$pkgdir/usr/bin/tiktok-live-studio"
  install -Dm755 tiktok-live-studio-capture "$pkgdir/usr/lib/tiktok-live-studio/tiktok-live-studio-capture"
  install -Dm644 tiktok-live-studio.desktop "$pkgdir/usr/share/applications/tiktok-live-studio.desktop"
  install -Dm644 tiktok-live-studio.svg "$pkgdir/usr/share/icons/hicolor/scalable/apps/tiktok-live-studio.svg"
  install -Dm644 mmdevapi.dll "$pkgdir/usr/share/tiktok-live-studio/mmdevapi.dll"
  install -Dm644 mmdevapi-device-topology.patch "$pkgdir/usr/share/tiktok-live-studio/mmdevapi-device-topology.patch"
  install -Dm644 winex11.so "$pkgdir/usr/share/tiktok-live-studio/winex11.so"
  install -Dm644 winex11-screen-capture.patch "$pkgdir/usr/share/tiktok-live-studio/winex11-screen-capture.patch"
}
