"""
Executes an elevated command in windows. Very tricky. Many articles have been written
about this topic. This is the best solution I could find is to use a mix of batch programs
and powershell:
1. Powershell is used to execute a batch file and raises the privledges to admin level.
2. The batch file
  a. executes the command as admin.
  b. echoes "done" to a file as a normal user
3. The calling python waits until the "done" file appears then exits.
"""

import ctypes
import os
import shutil
import subprocess
import time
from tempfile import TemporaryDirectory


def is_admin() -> bool:
    """Returns true if admin"""
    try:
        return bool(ctypes.windll.shell32.IsUserAnAdmin())  # flake8: noqa
    except Exception:  # pylint: disable=broad-except
        return False


def write_utf8(path: str, content: str) -> None:
    """Write a file with utf-8 encoding."""
    with open(path, encoding="utf-8", mode="w") as f:
        f.write(content)


def read_ascii(path: str) -> str:
    """Read a file with utf-8 encoding."""
    with open(path, encoding="ascii", mode="r") as f:
        return f.read()


def elevated_exec(cmd: str) -> int:
    """Execute a command as admin."""

    if is_admin():
        # Already admin, just execute the command.
        return os.system(cmd)

    with TemporaryDirectory(ignore_cleanup_errors=True) as tmpdir:

        def get_path(file: str) -> str:
            path = os.path.join(tmpdir, file)
            out = os.path.abspath(path)
            return out

        src_run_ps1 = os.path.join(os.path.dirname(__file__), "run.ps1")
        run_bat = get_path("run.bat")
        run_ps1 = get_path("run.ps1")
        rtn_txt = get_path("rtn.txt")
        # Copy the powershell script to the temp directory.
        shutil.copyfile(src_run_ps1, run_ps1)
        # First execute the service as admin.
        # Then execute write.bat as a normal user, "rtn.txt" will appear.
        run_cmd = f"""
@echo off
cd {os.getcwd()}
{cmd}
"""
        # Normalize for windows.
        run_cmd = run_cmd.replace("\r\n", "\n")
        write_utf8(run_bat, run_cmd)
        subprocess.call(r"powershell -c .\run.ps1", shell=True, cwd=tmpdir)
        while not os.path.exists(rtn_txt):
            time.sleep(0.1)
        rtn_str = read_ascii(rtn_txt).strip()
        rtn = int(rtn_str)
        return rtn


def unit_test() -> None:
    """Unit test."""
    rtn = elevated_exec("echo hi")
    assert rtn == 0


if __name__ == "__main__":
    unit_test()
