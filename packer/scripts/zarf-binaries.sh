### Downloading zarf binaries for amd64 for air gapped installation

mkdir /root/zarf-artifacts && cd /root/zarf-artifacts/
curl -OLs https://github.com/defenseunicorns/zarf/releases/download/v0.19.0/zarf-init-amd64.tar.zst
curl -OLs https://github.com/defenseunicorns/zarf/releases/download/v0.19.0/zarf-init-arm64.tar.zst
curl -OLs https://github.com/defenseunicorns/zarf/releases/download/v0.19.0/zarf
curl -OLs https://github.com/defenseunicorns/zarf/releases/download/v0.19.0/zarf.sha256
