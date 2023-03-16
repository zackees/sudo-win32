"""
Wraps gsudo to do the elevation
"""

import ctypes
import os
import shutil
import subprocess

from sudo_win32.install import install_once


def is_admin() -> bool:
    """Returns true if admin"""
    try:
        return bool(ctypes.windll.shell32.IsUserAnAdmin())  # flake8: noqa
    except Exception:  # pylint: disable=broad-except
        return False


def elevated_exec(cmd_list: list[str]) -> int:
    """Execute a command as admin."""
    if is_admin():
        # Already admin, just execute the command.
        return subprocess.call(cmd_list)
    gsudo_exe = install_once()
    # add gsudo_exe to path
    os.environ["PATH"] = os.path.dirname(gsudo_exe) + os.pathsep + os.environ["PATH"]
    assert shutil.which("gsudo.exe") is not None
    cmd = subprocess.list2cmdline(["gsudo.exe"] + cmd_list)
    return os.system(cmd)


def unit_test() -> None:
    """Unit test."""
    rtn = elevated_exec(["echo hi"])
    assert rtn == 0


if __name__ == "__main__":
    unit_test()
