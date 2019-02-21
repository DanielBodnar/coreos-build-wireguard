set -v -x

#pkg=WireGuard-0.0.20171211
#pkg=WireGuard-0.0.20180420
pkg=WireGuard-0.0.20180420.nop0

# Clone a specific tag.
# git clone --branch="${pkg##*-}" --depth=1 https://git.zx2c4.com/WireGuard "/tmp/$pkg"
git clone --branch="${pkg##*-}" --depth=1 https://github.com/nopdotcom/WireGuard "/tmp/$pkg"

# Verify the tag's signature.
# gpg2 --keyserver pool.sks-keyservers.net --recv-keys AB9942E6D4A4CFC3412620A749FC7012A5DE03AE
# git -C "/tmp/$pkg" tag -v "${pkg##*-}"

# Build the tools and module.
make -C "/tmp/$pkg/src" -j$(nproc) all V=1

# Install everything in a staging root directory.
make -C "/tmp/$pkg/src" install module-install DESTDIR=/tmp/root V=1
cp --parents "/lib/modules/$(uname -r)/extra/wireguard.ko" /tmp/root

# Edit the service to be torcx-aware.
sed -i \
    -e '/^\[Unit]/aRequires=torcx.target\nAfter=torcx.target' \
    -e "/^\\[Service]/aEnvironmentFile=/run/metadata/torcx\\nExecStartPre=-/sbin/modprobe ip6_udp_tunnel\\nExecStartPre=-/sbin/modprobe udp_tunnel\\nExecStartPre=-/sbin/insmod \${TORCX_UNPACKDIR}/${pkg%-*}/lib/modules/%v/extra/wireguard.ko" \
    -e 's,/usr/s\?bin/,${TORCX_BINDIR}/,g' \
    -e 's,^\([^ ]*=\)\(.{TORCX_BINDIR}\)/,\1/usr/bin/env PATH=\2:${PATH} \2/,' \
    /tmp/root/usr/lib/systemd/system/wg-quick@.service

# Write a torcx image manifest.
mkdir -p /tmp/root/.torcx
cat << 'EOF' > /tmp/root/.torcx/manifest.json
{
    "kind": "image-manifest-v0",
    "value": {
        "bin": [
            "/usr/bin/wg",
            "/usr/bin/wg-quick"
        ],
        "units": [
            "/usr/lib/systemd/system/wg-quick@.service"
        ]
    }
}
EOF

# Write the torcx image.
tar --force-local -C /tmp/root -czf "/host/${pkg/-/:}.torcx.tgz" .
