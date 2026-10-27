# Infisical secrets (Hisho add-on)

## What it does

Runs Infisical, a self-hosted secrets manager (open source, MIT core), on the Core machine, so
Hisho's secrets can live at home instead of in a cloud service. It runs in rootless Docker, listens
on 127.0.0.1 only and is published on the tailnet with `tailscale serve`. Its card shows whether
the server and its tailnet address answer, with Start / Stop / Restart.

## What it needs

- You need:
  - Docker and Tailscale on the Core machine (Hisho sets both up)
- Runs on: the Core machine
- Commands on that machine: `docker`, `tailscale`
- Settings in `~/Hisho/System/Config/Addons/infisical.yaml`:
  - `image` (str, default `infisical/infisical:v0.166.3`)
  - `port` (port, default `8085`)
  - `https_port` (port, default `8443`)
  - `site_url` (url, required)

## How to install

On the dashboard: **Add-ons > Store > Infisical secrets > Install**. Or from a terminal:

```bash
hisho addon install infisical
```

Hisho takes the newest version from this repository and copies it to the machine it runs on, runs its install and turns it on. Updates show as **Update
available** on its Store card; **Roll back** returns to the version before.

## How to use

After install, open its tailnet address (on its page), make the first admin account, a project and a machine identity for Hisho, then tell Hisho with `hisho secret backend infisical`. Its card shows whether Infisical answers, with **Start**, **Stop** and **Restart**.

## Settings

In `~/Hisho/System/Config/Addons/infisical.yaml`: `site_url` (its tailnet address, e.g.
`https://<core>.<tailnet>.ts.net:8443`), and if you want, the image, port and HTTPS port. After the
first install: open the URL, create the first (admin) account, make a project and a machine
identity for Hisho, then point Hisho at it (Fleet.yaml `secrets: backends: [infisical, ...]`).

## How to remove

**Add-ons > Store > Infisical secrets > Remove**, or `hisho addon remove infisical`. Stops and removes its service and `tailscale serve` entry; its Docker volumes (your secrets) are
kept. Your settings stay in `~/Hisho/System/Config/Addons/infisical.yaml`.

## License

Source-available under the [PolyForm Shield License 1.0.0](LICENSE.md): free to use, change and share,
for any purpose except offering a product that competes with Hisho (reselling it, for example).
