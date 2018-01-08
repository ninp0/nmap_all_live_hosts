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

nmap -e $interface -sn -PR -PS -PA -PU -PY -PE -PP -PM $ip_range -oG host_discovery_results.txt
cat host_discovery_results.txt | awk '{print $2}' | grep -v Nmap | while read ip; do
  echo $ip >> targets.txt.UNSORTED
done
sort -V targets.txt.UNSORTED > targets.txt
rm targets.txt.UNSORTED
echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n"

echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Initiating TCP Scans..."
#nmap -iL targets.txt \
#  --min-hostgroup 3 \
#  --max-hostgroup 9 \
#  --host-timeout 999m \
#  --min-parallelism 3 \
#  --min-rtt-timeout 36ms \
#  --initial-rtt-timeout 99ms \
#  --max-rtt-timeout 300ms \
#  --max-retries 9 \
#  --max-scan-delay 9ms \
#  -Pn \
#  -sS \
#  -p 0-65535 \
#  -A \
#  -oA "latest_tcp_results"
nmap -iL targets.txt \
  -e $interface \
  --min-hostgroup 3 \
  --host-timeout 999m \
  -T4 \
  -Pn \
  -sS \
  -p 0-65535 \
  -A \
  -oA "latest_tcp_results"
cat "latest_tcp_results.nmap" > latest_tcp_results.txt
echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n"

echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Initiating UDP Scans..."
#nmap -iL targets.txt \
#  --min-hostgroup 3 \
#  --max-hostgroup 9 \
#  --host-timeout 999m \
#  --min-parallelism 3 \
#  --min-rtt-timeout 36ms \
#  --initial-rtt-timeout 99ms \
#  --max-rtt-timeout 300ms \
#  --max-retries 9 \
#  --max-scan-delay 9ms \
#  -Pn \
#  -sU \
#  -A \
#  -oA "latest_udp_results"
nmap -iL targets.txt \
  -e $interface \
  --min-hostgroup 3 \
  --host-timeout 999m \
  -T4 \
  -Pn \
  -sU \
  -A \
  -oA "latest_udp_results"
cat "latest_udp_results.nmap" > latest_udp_results.txt
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
