### Downloading zarf binaries for amd64 for air gapped installation

mkdir /root/opentdfbinaries && cd /root/opentdfbinaries
git clone https://github.com/opentdf/opentdf.git
cd opentdf
# now run pre-reqs script
chmod a+x scripts/pre-reqs
./scripts/pre-reqs

# generate offline open-tdf bundle
echo "Generating offline open-tdf bundle"
chmod a+x examples/offline/build-offline-bundle
./examples/offline/build-offline-bundle
echo "bundle generated"
