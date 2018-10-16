#!/bin/bash
usage() {
  echo "USAGE: ${0} <nmap supported ip range e.g. 192.168.1.1-20, 192.168.1.0/24, etc> <use specified interface>"
  exit 1
}

if [[ $# < 2 ]]; then
  usage
fi

ip_range=$1
interface=$2

echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Leveraging a Discovery Scan to Find IPs Prior to More Exhaustive Port Analysis..."
if [[ -e targets.txt ]]; then
  > targets.txt
fi

nmap --excludefile exclude_targets.txt \
  -e $interface \
  -sn \
  -PR \
  -PS \
  -PA \
  -PU \
  -PY \
  -PE \
  -PP \
  -PM \
  -oG host_discovery_results.txt
  $ip_range
cat host_discovery_results.txt | awk '{print $2}' | grep -v Nmap | while read ip; do
  echo $ip >> targets.txt.UNSORTED
done
sort -V targets.txt.UNSORTED > targets.txt
rm targets.txt.UNSORTED
echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n"

echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Initiating TCP Scans..."
nmap -iL targets.txt \
  --excludefile exclude_targets.txt \
  -e $interface \
  --min-hostgroup 3 \
  --host-timeout 999m \
  -T4 \
  -Pn \
  -sS \
  -sC \
  -p 0-65535 \
  -A \
  -oA "latest_tcp_results"
cat "latest_tcp_results.nmap" > latest_tcp_results.txt
echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n"

echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Initiating UDP Scans..."
nmap -iL targets.txt \
  --excludefile exclude_targets.txt \
  -e $interface \
  --min-hostgroup 3 \
  --host-timeout 999m \
  -T4 \
  -Pn \
  -sU \
  -sC \
  -A \
  -oA "latest_udp_results"
cat "latest_udp_results.nmap" > latest_udp_results.txt
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
