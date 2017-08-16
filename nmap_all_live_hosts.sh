#!/bin/bash
usage() {
  echo "USAGE: ${0} <nmap supported ip range e.g. 192.168.1.1-20, 192.168.1.0/24, etc>"
  exit 1
}

if [[ $# < 1 ]]; then
  usage
fi

ip_range=$1

echo "Leveraging a Discovery Scan to Find IPs Prior to More Exhaustive Port Analysis..."
if [[ -e targets.txt ]]; then
  > targets.txt
fi

nmap -sn $ip_range -oG host_discovery_results.txt
cat host_discovery_results.txt | awk '{print $2}' | grep -v Nmap | while read ip; do
  echo $ip >> targets.txt
done
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n"

echo "Initiating TCP Scans..."
nmap -iL targets.txt \
  --min-hostgroup 3 \
  --max-hostgroup 9 \
  --host-timeout 36m \
  --min-parallelism 3 \
  --min-rtt-timeout 36ms \
  --initial-rtt-timeout 99ms \
  --max-rtt-timeout 300ms \
  --max-retries 3 \
  --max-scan-delay 9ms \
  -n \
  -Pn \
  -sS \
  -p 0-65535 \
  -A \
  -oA "latest_tcp_results"
cat "latest_tcp_results.nmap" > latest_tcp_results.txt
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n"

echo "Initiating UDP Scans..."
nmap -iL targets.txt \
  --min-hostgroup 3 \
  --max-hostgroup 9 \
  --host-timeout 36m \
  --min-parallelism 3 \
  --min-rtt-timeout 36ms \
  --initial-rtt-timeout 99ms \
  --max-rtt-timeout 300ms \
  --max-retries 3 \
  --max-scan-delay 9ms \
  -n \
  -Pn \
  -sU \
  -A \
  -oA "latest_udp_results"
cat "latest_udp_results.nmap" > latest_udp_results.txt
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
