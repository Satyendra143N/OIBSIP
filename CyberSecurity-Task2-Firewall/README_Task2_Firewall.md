# OIBSIP Cyber Security — Task 2: Basic Firewall Configuration with UFW

## What Does a Firewall Do?

A firewall is a network security system that monitors and controls incoming
and outgoing traffic based on a defined set of rules. It acts as a barrier
between a trusted internal system and untrusted external networks (like the
internet), deciding which connections are allowed through and which are
blocked. Without a firewall, every open service on a machine would be
directly reachable by anyone who can route traffic to it.

**UFW (Uncomplicated Firewall)** is a user-friendly front-end for Linux's
underlying `iptables` firewall system. It simplifies rule management into
straightforward commands like `allow` and `deny`, instead of requiring raw
iptables syntax.

## Setup

- **System:** Kali Linux (VirtualBox VM)
- **Tool:** UFW

Installed and enabled with:
```bash
sudo apt install ufw -y
sudo ufw enable
```

## Rules Configured

| # | Rule | Command | Purpose |
|---|------|---------|---------|
| 1 | Allow SSH (port 22) | `sudo ufw allow ssh` | Required rule — permits remote administration access |
| 2 | Deny HTTP (port 80) | `sudo ufw deny http` | Required rule — blocks unencrypted web traffic |
| 3 | Allow HTTPS (port 443) | `sudo ufw allow https` | Custom rule — permits encrypted web traffic while blocking its unencrypted counterpart |
| 4 | Deny from 192.168.50.0/24 | `sudo ufw deny from 192.168.50.0/24` | Custom rule — blocks an entire subnet, demonstrating source-based (not just port-based) filtering |

**Why these specific rules:** SSH allow + HTTP deny were required by the
task. For the custom rules, I chose to pair an **allow** for HTTPS with the
HTTP deny to show a realistic real-world pattern (force encrypted traffic
only), and added a **subnet-level deny** to demonstrate that UFW can filter
by source address/range, not just by port — a different rule *type* than
the other three.

## Verifying Active Rules

```bash
sudo ufw status verbose
```
Screenshot of this output is included in this folder (`ufw_status.png`).

## Testing That Rules Actually Work

Verifying a firewall configuration means confirming the *behavior*, not
just that a rule exists in the list.

**Test 1 — HTTP deny (port 80):**
Started a temporary test server on the Kali VM:
```bash
sudo python3 -m http.server 80
```
Then attempted to connect from my Windows host browser to
`http://<kali-vm-ip>`. The connection failed to load / timed out,
confirming the deny rule is actively blocking inbound port 80 traffic
rather than the rule simply existing but not being enforced.

**Test 2 — SSH allow (port 22):**
Installed and started the SSH server on Kali:
```bash
sudo apt install openssh-server -y
sudo systemctl start ssh
```
Connected successfully from my Windows host via
`ssh kali@<kali-vm-ip>`, confirming the allow rule permits the intended
traffic through.

**Test 3 — Subnet deny rule:**
Testing this rule practically would require traffic actually originating
from an address within `192.168.50.0/24`, which wasn't available in my
single-VM test environment. I verified the rule is correctly registered
and active via `sudo ufw status verbose` instead, which is a reasonable
and honest limitation of a single-machine test setup.

## Screenshots Included

- `ufw_status.png` — output of `ufw status verbose`
- `http_test_blocked.png` — failed HTTP connection attempt
- `ssh_test_success.png` — successful SSH connection

## Files in This Repo

- `README.md` — this file
- `ufw_configuration.sh` — runnable script that applies all rules in sequence
- Screenshots as listed above
