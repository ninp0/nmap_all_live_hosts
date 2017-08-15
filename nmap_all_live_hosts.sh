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
if [[ -e latest_tcp_results.txt ]]; then
  > latest_tcp_results.txt
fi

if [[ -e latest_udp_results.txt ]]; then
  > latest_udp_results.txt
fi

nmap -sn $ip_range -oG host_discovery_results.txt
cat host_discovery_results.txt | awk '{print $2}' | grep -v Nmap | while read ip; do
  echo "Full TCP Scan: ${ip}"
  echo "Full TCP Scan: ${ip}" >> latest_tcp_results.txt
  # More aggressive than T5
  nmap --defeat-rst-ratelimit --min-rtt-timeout 36ms --initial-rtt-timeout 63ms --max-rtt-timeout 99ms --max-retries 3 --host-timeout 3m --max-scan-delay 6ms -n -Pn -sS -p 0-65535 -A -oA "${ip}_tcp_report" $ip
  cat "${ip}_tcp_report.nmap" >> latest_tcp_results.txt
  echo -e "--------------------------------------------------------------------------------\n\n\n" >> latest_tcp_results.txt
  echo -e "--------------------------------------------------------------------------------\n\n\n"

  echo -e "Default UDP Scan: ${ip}"
  echo -e "Default UDP Scan: ${ip}" >> latest_udp_results.txt
  # More aggressive than T5
  nmap --defeat-rst-ratelimit --min-rtt-timeout 36ms --initial-rtt-timeout 63ms --max-rtt-timeout 99ms --max-retries 3 --host-timeout 3m --max-scan-delay 6ms -n -sU -A -oA "${ip}_udp_report" $ip
  cat "${ip}_udp_report.nmap" >> latest_udp_results.txt
  echo -e "--------------------------------------------------------------------------------\n\n\n" >> latest_udp_results.txt
  echo -e "--------------------------------------------------------------------------------\n\n\n"
done
