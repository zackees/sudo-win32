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


def read_utf8(path: str) -> str:
    """Read a file with utf-8 encoding."""
    with open(path, encoding="utf-8", mode="r") as f:
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

        write_py_file = get_path("write.py")
        run_bat_file = get_path("myrun.bat")
        ps1_file = get_path("run.ps1")
        done_txt = get_path("done.txt")

        write_py = """
import os
import sys
with open('rtn.txt', mode='r', encoding='utf-8') as fd:
    rtn_val = fd.read()
with open('tmp.txt', mode='w', encoding='utf-8') as fd:
    fd.write(str(rtn_val))
os.rename('tmp.txt', 'done.txt')
        """

        # First execute the service as admin.
        # Then execute write.bat as a normal user, "done.txt" will appear.
        admin_cmd = f"""
@echo off
{cmd}
set lasterr=%ERRORLEVEL%
cd %~dp0
echo %lasterr% > rtn.txt
runas /trustlevel:0x20000 "python write.py"
        """

        entrypoint_ps1 = f"""
Start-Process -WindowStyle Hidden -Verb runAs "{run_bat_file}"
        """

        write_utf8(write_py_file, write_py)
        write_utf8(run_bat_file, admin_cmd)
        write_utf8(ps1_file, entrypoint_ps1)

        cmd = f'powershell -c "{os.path.abspath(ps1_file)}"'
        # print(cmd)
        os.system(cmd)
        # time.sleep(20)
        while not os.path.exists(done_txt):
            time.sleep(0.1)
        rtn_str = read_utf8(done_txt).strip()
        rtn = int(rtn_str)
        return rtn


def unit_test() -> None:
    """Unit test."""
    rtn = elevated_exec("echo hi")
    assert rtn == 0


if __name__ == "__main__":
    unit_test()
