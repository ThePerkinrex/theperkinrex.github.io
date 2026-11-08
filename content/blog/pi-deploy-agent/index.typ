#import "@tola/source:0.0.0": tola-meta
#import "/site/components.typ": *

#tola-meta((
  title: "My Raspberry Pi doesn't compile anything: a small deploy agent in Rust",
  description: "GitHub Actions builds and signs a release bundle, sends it over Tailscale, and an agent on the Pi verifies it, swaps a symlink and restarts the systemd units over D-Bus, including its own.",
  date: "2026-11-07",
  tags: ("rust", "deployment", "raspberry-pi", "systemd", "ci"),
  hero: "/assets/images/pi-deploy-agent.svg",
  draft: true,
))
