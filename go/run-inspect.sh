#!/usr/bin/env bash
# Run on the INSPECTOR vm. Spoofs+captures one target (or all) and serves the
# live dashboard. Keep both VMs on the same Parallels virtual network you own
# (Shared Network is fine); never do this over Bridged onto a real LAN.
#
#   ./run-inspect.sh                 # inspect every discovered device
#   ./run-inspect.sh aa:bb:cc:dd:ee:ff   # inspect just the target VM's MAC
set -euo pipefail

target="${1:-all}"
port="${2:-8080}"

if [ ! -x ./inspector ]; then
  echo "build first:  ./build.sh" >&2
  exit 1
fi

ip="$(hostname -I | awk '{print $1}')"
echo "inspecting: $target"
echo "dashboard:  http://localhost:${port}   (from your Mac: http://${ip}:${port})"
echo "tip: on the TARGET vm, run 'ip link' to get its MAC, then browse the web."
echo
exec sudo ./inspector -inspect "$target" -serve ":${port}" -record capture.pcap
