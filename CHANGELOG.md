# Changelog

## 0.2.1

- bin/docker.sh borrows the docker group with sg only where sg exists: Arch has none, so the unit exited 127 on a fresh Souko (whose owner now owns Docker's socket, so plain docker works).

## 0.2.0

- Every field on its setup form says in plain words what it is, and links to where to get it (addon.yaml `help:`, shown by Hisho's dashboard).
- Installs on a Souko: its unit and install use the Docker this machine has (system Docker, or the account's rootless one), with the docker group added since the session began (bin/docker.sh); it had the rootless socket written in and failed on a fresh Souko.
- Runs before Tailscale is connected (on this machine only; Apply after Tailscale publishes it); a start that fails says why.
- Hisho keeps its address in the settings (HISHO_SET site_url): its link and checks need nothing typed.

## 0.1.2

- Installs on a fresh Souko: its address comes from this machine's tailnet name when none is set, and it publishes on the tailnet without sudo when the owner is Tailscale's operator.

## 0.1.1

- README says what you need (addon.yaml you_need) and how to use it; the README check requires both.

## 0.1.0

- Moved out of Hisho into its own repository (hisho-addon-infisical); installed from the add-on store.

