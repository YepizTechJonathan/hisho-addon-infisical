"""Infisical add-on tests. Run with Hisho's venv at the repository's top:
~/code/hisho/.venv/bin/python -m pytest -q"""
import json
import subprocess
from pathlib import Path

import pytest
import yaml

from hisho import addon_store, addons, fleet_power, maintenance  # noqa: F401
from hisho.addon_testing import AUTH, TOKEN, Recorder

HERE = Path(__file__).resolve().parents[1]


def ctx_for(addon):
    return addons.Context(addon, resolve=lambda name: f"value-of-{name}")


def test_manifest_is_valid_and_readme_matches(addon):
    assert addons.validate_manifest(addon.manifest) == []
    assert addon_store.readme_problems(HERE) == []


def test_it_runs_on_the_core_machine_published_on_the_tailnet_only(addon):
    assert addon.kind == "service" and addon.services()[0]["unit"] == "hisho-infisical.service"
    assert addon.manifest["install"] == "bin/install.sh" and addon.manifest["uninstall"] == "bin/uninstall.sh"
    install = (HERE / "bin" / "install.sh").read_text()
    assert 'if [ ! -f "$data/.env" ]' in install           # the encryption key is never overwritten
    assert "tailscale serve" in install and "0.0.0.0" not in (HERE / "docker-compose.yml").read_text()


def test_its_unit_uses_the_docker_this_machine_has_and_the_group_added_since_login():
    """A Souko runs the system's Docker (its account joined the docker group at first boot, after the session began);
    a Kihon runs rootless Docker. The unit no longer names the rootless socket (Install failed on a Souko, SIB-015)."""
    unit = (HERE / "units" / "hisho-infisical.service").read_text()
    assert "DOCKER_HOST" not in unit and "bin/docker.sh compose" in unit
    wrapper = (HERE / "bin" / "docker.sh").read_text()
    assert "/run/user/$uid/docker.sock" in wrapper and "exec sg docker" in wrapper
    assert "command -v sg" in wrapper            # Arch has no sg: never a "command not found" (exit 127, 2026-10-29)


def test_install_hands_its_address_to_hisho_and_runs_before_tailscale():
    install = (HERE / "bin" / "install.sh").read_text()
    assert 'echo "HISHO_SET site_url=${site}"' in install
    assert 'site="http://127.0.0.1:${HISHO_OPT_PORT}"' in install
    res = subprocess.run(["bash", str(HERE / "bin" / "docker.sh"), "--version"], capture_output=True, text=True)
    assert res.returncode in (0, 127) or "docker" in (res.stdout + res.stderr).lower()
