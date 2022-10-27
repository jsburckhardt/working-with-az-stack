curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.13.0/kind-linux-amd64" || e "Unable to download kind"
chmod +x kind || e "kind is not executableable"
mv kind "/bin" || e "kind is not mvable"

# install non interacting node js
apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get install -y nodejs npm
