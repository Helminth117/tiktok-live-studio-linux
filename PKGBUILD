# Maintainer: Joseph <joseph62937@gmail.com>
pkgname=tiktok-live-studio-wine
pkgver=1.1.0
pkgrel=3
pkgdesc="TikTok LIVE Studio (Windows) en Linux mediante umu-launcher/Proton"
arch=('x86_64')
url="https://github.com/Helminth117/tiktok-live-studio-linux"
# El lanzador es 0BSD; mmdevapi.dll es Wine (GE-Proton11-11) con
# mmdevapi-device-topology.patch, LGPL-2.1-or-later.
license=('0BSD' 'LGPL-2.1-or-later')
depends=('bash' 'curl' 'jq' 'umu-launcher' 'xdg-user-dirs' 'xdg-utils')
optdepends=('zenity: diálogos al iniciar desde el menú de aplicaciones')
options=('!strip' '!debug')
source=('tiktok-live-studio'
        'tiktok-live-studio.desktop'
        'tiktok-live-studio.svg'
        'mmdevapi.dll'
        'mmdevapi-device-topology.patch')
sha256sums=('25ae4358161403c7790b0521c9382be9bad313d12b2fc27ea0a01a9c925d5357'
            '456ef04418a8ce085bfbeb5f0ac3ba06e71382e6bdebccb8653f01a43f3fbf48'
            'a8ec3a4b88bf16dd1af1c8b97c51ec9143d1005269276935adee67ec79626417'
            '668fb71bc5bc7599301f6bde780188aa0c4b6f2e1f74ce15fc183d1650fb2e15'
            '5c17760dfa02a772b1c4963cbe412345e1ff726390f63012d161eb3f3be09144')

package() {
  install -Dm755 tiktok-live-studio "$pkgdir/usr/bin/tiktok-live-studio"
  install -Dm644 tiktok-live-studio.desktop "$pkgdir/usr/share/applications/tiktok-live-studio.desktop"
  install -Dm644 tiktok-live-studio.svg "$pkgdir/usr/share/icons/hicolor/scalable/apps/tiktok-live-studio.svg"
  install -Dm644 mmdevapi.dll "$pkgdir/usr/share/tiktok-live-studio/mmdevapi.dll"
  install -Dm644 mmdevapi-device-topology.patch "$pkgdir/usr/share/tiktok-live-studio/mmdevapi-device-topology.patch"
}
