# OIBSIP Cyber Security — Task 1: Basic Network Scanning with Nmap

## What is Nmap?

Nmap (Network Mapper) is a free, open-source tool used to discover hosts and
services on a network. It works by sending specially crafted packets to a
target and analyzing the responses (or lack of responses) to determine which
ports are open, what services/software are running on them, and sometimes
even what operating system the target is running.

## Why Network Scanning Matters

Network scanning is one of the first steps in both offensive security
(penetration testing, red teaming) and defensive security (asset discovery,
attack surface assessment). If you don't know what services are exposed on
your network, you can't secure them. Attackers use the exact same
technique — scanning — as their first reconnaissance step before attempting
any exploitation, which is why understanding it from a defender's
perspective is essential.

## Setup

- **Attacker machine:** Kali Linux running as a VirtualBox VM
- **Target:** My Windows host machine (the physical PC running VirtualBox),
  reached from inside the VM over the virtual network adapter
- **Nmap version:** 7.99 (pre-installed on Kali Linux, verified with
  `nmap --version`)

## Scans Performed

Three separate scans were run against the target IP `172.21.222.75`. Full
raw output for each is saved in `nmap_scan_results.txt`.

| # | Command | Purpose |
|---|---------|---------|
| 1 | `nmap 172.21.222.75` | Basic scan — check the top 1000 common ports for open/closed/filtered state |
| 2 | `nmap -sV 172.21.222.75` | Service version scan — identify software/version running on any open ports |
| 3 | `sudo nmap -O 172.21.222.75` | OS detection scan — attempt to fingerprint the target's operating system |

## Findings

**Open ports found: 0.** All 1000 scanned ports across all three scans came
back as **filtered**, meaning Nmap received no response at all to its
probes — not even a rejection.

**Why this happened:** The target is a Windows machine, and Windows Defender
Firewall blocks unsolicited inbound connections by default. Instead of
actively rejecting a probe (which would mark a port "closed" and give Nmap a
clean signal), the firewall silently drops the packet. From the scanning
machine's point of view, this looks identical to "nobody is listening and
nothing is responding" — which is exactly the intended behavior of a
properly configured host firewall.

**OS Detection Scan result:** Nmap explicitly warned that *"OSScan results
may be unreliable because we could not find at least 1 open and 1 closed
port."* This is an important limitation to understand: OS fingerprinting
relies on subtle differences in how a target's TCP/IP stack responds on
open vs. closed ports. With zero open ports and zero clearly closed
(rejected) ports to compare, Nmap had nothing solid to fingerprint against.
The resulting guesses (a network camera, a printer, an old Linux kernel, a
Cisco router — none of which is the actual target, a Windows PC) should be
treated as noise, not a finding. This is a good example of why raw tool
output should never be trusted blindly — the analyst has to understand the
tool's confidence level and limitations.

## Security Risk Analysis

| Port | Service | Risk Assessment |
|------|---------|------------------|
| None open | — | No open ports were discovered, so there is no direct port-based attack surface visible from this scan position. |

Since no ports were open, the actual security takeaway of this exercise is
about the **filtering behavior itself**, not any specific service:

- **Positive finding:** The target's firewall is doing its job. An external
  attacker performing basic reconnaissance from this network position would
  learn essentially nothing about what's running on the machine — a good
  defensive posture.
- **Caveat:** "Filtered" is not the same as "secure." It only tells us the
  firewall blocks *unsolicited* connections; it says nothing about
  vulnerabilities in software the user actively runs (browsers, email
  clients, installed applications) which make outbound connections and are
  a far more common real-world attack vector than open inbound ports.
- **Recommendation:** Keep the host firewall enabled (as it clearly is
  here), only open/forward ports that are explicitly needed, and treat OS
  fingerprinting output with skepticism when Nmap flags it as unreliable —
  cross-reference with other tools or known information about the target
  before drawing conclusions.

## Ethical Use Guidelines

⚠️ **This scan was performed only against a machine I own and control**
(my own Windows host, scanned from a VM I set up on the same physical
computer). Nmap and other scanning tools should never be used against
systems you do not own or do not have explicit written permission to test.
Unauthorized scanning can be illegal under computer misuse laws in many
jurisdictions, even if no exploitation is attempted — the scan itself can
be considered unauthorized access preparation.

## Files in this repo

- `README.md` — this file
- `nmap_scan_results.txt` — raw output from all three scans
- Screenshots of each scan (terminal output)
