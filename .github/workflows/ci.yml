"""Smoke tests for check_host.sh."""
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / "check_host.sh"


def run_script(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["bash", str(SCRIPT), *args],
        capture_output=True,
        text=True,
        timeout=30,
    )


def test_script_exists():
    assert SCRIPT.exists(), "check_host.sh not found in repo root"


def test_no_args_shows_usage():
    result = run_script()
    assert result.returncode == 1
    assert "Usage" in result.stdout


def test_bad_port_rejected():
    result = run_script("localhost", "not-a-port")
    assert result.returncode == 1
    assert "is not a number" in result.stdout


def test_localhost_is_available():
    result = run_script("localhost")
    assert result.returncode == 0
