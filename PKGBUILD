# Maintainer: Joseph <joseph62937@gmail.com>
pkgname=tiktok-live-studio-wine
pkgver=1.1.0
pkgrel=1
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
        'mmdevapi.dll'
        'mmdevapi-device-topology.patch')
sha256sums=('07907bb95b0a403b99d0409320d884723db019f734731f765dcc0fd07d5c3da2'
            '0607092e532e1e68f0117231eaa3b788748b48a1a34dbdcbc54a8a7d2859432c'
            '668fb71bc5bc7599301f6bde780188aa0c4b6f2e1f74ce15fc183d1650fb2e15'
            '5c17760dfa02a772b1c4963cbe412345e1ff726390f63012d161eb3f3be09144')

package() {
  install -Dm755 tiktok-live-studio "$pkgdir/usr/bin/tiktok-live-studio"
  install -Dm644 tiktok-live-studio.desktop "$pkgdir/usr/share/applications/tiktok-live-studio.desktop"
  install -Dm644 mmdevapi.dll "$pkgdir/usr/share/tiktok-live-studio/mmdevapi.dll"
  install -Dm644 mmdevapi-device-topology.patch "$pkgdir/usr/share/tiktok-live-studio/mmdevapi-device-topology.patch"
}
