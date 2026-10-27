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
