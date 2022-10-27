### Downloading RKE2 binaries for air gapped installation

# Installation instructions taken from 'https://docs.rke2.io/install/airgap/#rke2-installsh-script-install'

mkdir /root/rke2-artifacts && cd /root/rke2-artifacts/
curl -OLs https://github.com/rancher/rke2/releases/download/v1.23.6%2Brke2r2/rke2-images.linux-amd64.tar.zst
curl -OLs https://github.com/rancher/rke2/releases/download/v1.23.6%2Brke2r2/rke2.linux-amd64.tar.gz
curl -OLs https://github.com/rancher/rke2/releases/download/v1.23.6%2Brke2r2/sha256sum-amd64.txt
curl -sfL https://get.rke2.io --output install.sh
