#!/usr/bin/env bash
# Build the inspector on a fresh Ubuntu/Debian VM (arm64 or amd64).
# The capture path is CGO + libpcap, so this must run natively on the target
# machine -- you cannot cross-compile a working binary from an M1 to Intel.
set -euo pipefail

echo "[1/4] apt deps (libpcap-dev, build tools, git, go)"
sudo apt-get update -qq
sudo apt-get install -y libpcap-dev build-essential git golang-go

# go.mod needs Go 1.22+. Ubuntu 24.04 ships that; older releases don't.
need="1.22"
have="$(go version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1 || echo 0)"
if [ "$(printf '%s\n%s\n' "$need" "$have" | sort -V | head -1)" != "$need" ]; then
  echo "[2/4] apt Go is $have (< $need); installing 1.22.5 from go.dev"
  arch="$(dpkg --print-architecture)"   # arm64 on M1 Parallels, amd64 on Intel
  tarball="go1.22.5.linux-${arch}.tar.gz"
  wget -q "https://go.dev/dl/${tarball}"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$tarball"
  rm -f "$tarball"
  export PATH="/usr/local/go/bin:$PATH"
  echo "  add this to ~/.bashrc:  export PATH=/usr/local/go/bin:\$PATH"
else
  echo "[2/4] Go $have is new enough"
fi

echo "[3/4] resolving modules"
go mod tidy

echo "[4/4] building ./inspector"
go build -o inspector ./cmd/inspector
echo
echo "done. binary: $(pwd)/inspector"
./inspector -h 2>&1 | head -3 || true
