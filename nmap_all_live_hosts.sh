#!/bin/bash
usage() {
  echo "USAGE: ${0} <nmap supported ip range e.g. 192.168.1.1-20, 192.168.1.0/24, etc>"
  exit 1
}

if [[ $# < 1 ]]; then
  usage
fi

ip_range=$1

echo -e "Leveraging a Discovery Scan to Find IPs Prior to More Exhaustive Port Analysis...\n\n\n"
if [[ -e targets.txt ]]; then
  > targets.txt
fi

nmap -sn -PR -PS -PA -PU -PY -PE -PP -PM $ip_range -oG host_discovery_results.txt
cat host_discovery_results.txt | awk '{print $2}' | grep -v Nmap | while read ip; do
  echo $ip >> targets.txt
done
echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n"

echo "Initiating TCP Scans...\n\n\n"
nmap -iL targets.txt \
  --min-hostgroup 3 \
  --max-hostgroup 9 \
  --host-timeout 36m \
  --min-parallelism 3 \
  --min-rtt-timeout 36ms \
  --initial-rtt-timeout 99ms \
  --max-rtt-timeout 300ms \
  --max-retries 9 \
  --max-scan-delay 9ms \
  -n \
  -Pn \
  -sS \
  -p 0-65535 \
  -A \
  -oA "latest_tcp_results"
cat "latest_tcp_results.nmap" > latest_tcp_results.txt
echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n"

echo -e "Initiating UDP Scans...\n\n\n"
nmap -iL targets.txt \
  --min-hostgroup 3 \
  --max-hostgroup 9 \
  --host-timeout 36m \
  --min-parallelism 3 \
  --min-rtt-timeout 36ms \
  --initial-rtt-timeout 99ms \
  --max-rtt-timeout 300ms \
  --max-retries 9 \
  --max-scan-delay 9ms \
  -n \
  -Pn \
  -sU \
  -A \
  -oA "latest_udp_results"
cat "latest_udp_results.nmap" > latest_udp_results.txt
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
