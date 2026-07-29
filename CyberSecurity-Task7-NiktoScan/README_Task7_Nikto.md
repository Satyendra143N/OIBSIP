# OIBSIP Cyber Security — Task 7: Vulnerability Scanning with Nikto

## What is Nikto?

Nikto is an open-source web server scanner that checks for thousands of
known issues, including outdated server software, dangerous files/scripts,
missing security headers, default configuration files, and other common
web server misconfigurations. It works by sending a large number of HTTP
requests to a target and comparing the responses against its database of
known vulnerability signatures.

**Nikto is intentionally noisy** — this means it does not attempt to hide
its scanning activity and generates a large volume of requests very
quickly, which would trip most intrusion detection systems (IDS). This is
by design: Nikto is meant for authorized security assessments where
stealth isn't required, not for covert reconnaissance.

## Nikto vs. Nmap

These tools operate at different layers and serve different purposes:

- **Nmap** operates at the network/transport layer — it discovers hosts,
  open ports, and running services across an entire network.
- **Nikto** operates at the application layer — once you already know a
  web server is running (e.g., from an Nmap scan showing port 80/443
  open), Nikto digs into *that specific web server* to find
  misconfigurations, outdated software, and known vulnerabilities within
  the web application itself.

In a real assessment, Nmap is typically used first (broad discovery),
followed by Nikto against any web servers found (deep dive).

## Setup

- **Target:** A local Apache 2.4.68 (Debian) install running on my Kali
  VM, accessed via `http://localhost`
- **Why a local Apache install instead of DVWA:** DVWA requires a full
  LAMP/XAMPP stack and database setup. A default Apache install still
  produces genuine, meaningful Nikto findings (missing headers, exposed
  status pages, information disclosure) which is sufficient to
  demonstrate the scanning and analysis skills this task is testing.

## Scans Performed

```bash
nikto -h http://localhost -o nikto_scan_results.txt
```

Full raw output is saved in `nikto_scan_results.txt`.

**SSL scan:** The task also calls for an SSL-flagged scan (`-ssl`) if the
target supports HTTPS. My local Apache install was not configured with an
SSL/TLS certificate, so there was no HTTPS listener to scan. I'm noting
this explicitly rather than skipping it silently — running `-ssl` against
a non-HTTPS target would not produce meaningful results.

## Findings — Categorized by Severity

| Finding | Severity | Explanation | Recommended Fix |
|---|---|---|---|
| **`/server-status` exposes Apache internals** | **High** | The `mod_status` module reveals real-time server information — active requests, connected client IPs, requested URLs — to anyone who visits this path. This is genuine information disclosure that could aid an attacker in reconnaissance or reveal sensitive request data. | Disable `mod_status`, or restrict access to it via `Require ip <trusted-ip>` in the Apache config, or remove the `/server-status` location block entirely if unused. |
| **Missing `Content-Security-Policy` header** | Medium | CSP is one of the strongest available defenses against Cross-Site Scripting (XSS) — it restricts which sources of scripts/styles/etc. a browser will execute. Its absence means the browser has no extra layer of defense if an XSS flaw exists elsewhere in the application. | Add a `Content-Security-Policy` header with an appropriately restrictive policy for the site's actual needs. |
| **Missing `Strict-Transport-Security` (HSTS)** | Medium | Without HSTS, browsers won't automatically force HTTPS on future visits, leaving a window open for SSL-stripping / downgrade attacks. (Less critical here since this server isn't running HTTPS at all yet, but this would matter immediately if HTTPS were added.) | Configure HTTPS, then add HSTS headers once TLS is in place. |
| **Missing `X-Content-Type-Options`** | Medium | Without this header (set to `nosniff`), some browsers may try to "sniff" and reinterpret a file's content type, which can be abused in certain XSS/content-injection scenarios. | Add `X-Content-Type-Options: nosniff` to server responses. |
| **`X-Frame-Options` deprecated notice** | Low | Nikto notes this older header has been superseded by CSP's `frame-ancestors` directive. Not a vulnerability by itself, but a sign the security header strategy needs modernizing. | Migrate clickjacking protection to CSP's `frame-ancestors` directive. |
| **Missing `Referrer-Policy` / `Permissions-Policy`** | Low | These are privacy/hardening headers — their absence isn't directly exploitable but represents missed best-practice hardening. | Add both headers with policies appropriate to the site (e.g., `no-referrer-when-downgrade`, restrict unneeded browser features). |
| **ETag inode leak** | Low / Informational | Apache's default ETag header can expose internal filesystem details (inode number) in response headers, which can aid server fingerprinting. | Configure `FileETag` to exclude `INode`, or disable ETags and rely on `Last-Modified`/content hashing instead. |
| **Allowed HTTP methods: HEAD, GET, POST, OPTIONS** | Informational | No dangerous methods (like PUT, DELETE, or TRACE) are enabled, which is good. Listed for completeness, not a finding requiring action. | No action needed — this is the expected, safe default. |

## Key Takeaway

The single most important finding here is the exposed `/server-status`
page — everything else is a "best practice" hardening gap (missing
headers), but `/server-status` is an active information disclosure
vulnerability that a real attacker could use directly. This distinction —
between "should be improved" and "is actively leaking information right
now" — is exactly the kind of prioritization a security analyst needs to
make when triaging a long list of scanner output, rather than treating
every line item as equally urgent.

## Files in This Repo

- `README.md` — this file
- `nikto_scan_results.txt` — raw scan output
- Screenshots of the scan running and its output
