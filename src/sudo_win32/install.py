"""
Installs gsudo.
"""

import os
import shutil
import subprocess

import py7zr

HERE = os.path.dirname(os.path.abspath(__file__))
GSUDO_7Z = os.path.join(HERE, "gsudo.7z")
GSUDO_DIR = os.path.join(HERE, "gsudo")


def install_once() -> str:
    """Install."""
    out = os.path.abspath(os.path.join(HERE, "gsudo", "gsudo.exe"))
    if os.path.exists(GSUDO_DIR):
        return out
    prev = os.getcwd()
    try:
        with py7zr.SevenZipFile(GSUDO_7Z, mode="r") as archive:
            os.chdir(HERE)
            archive.extractall()
            # change permissions so that gsudo.exe is executable by non administrators
            paths = os.listdir(GSUDO_DIR)
            paths = [os.path.join(GSUDO_DIR, f) for f in paths]
            paths.append(GSUDO_DIR)
            for f in paths:
                # Modifies the permissions of the file to allow Everyone to have full control.
                subprocess.check_output(f"icacls {f} /grant Everyone:F", shell=True)
    finally:
        os.chdir(prev)
    return out


def unit_test() -> None:
    """Unit test."""
    os.chdir(HERE)
    shutil.rmtree("gsudo", ignore_errors=True)
    install_once()


if __name__ == "__main__":
    unit_test()
