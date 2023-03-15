"""
Main entry point.
"""

import argparse
import subprocess
import sys

from .elevated_exec import elevated_exec


def main() -> int:
    """Main entry point for the template_python_cmd package."""
    parser = argparse.ArgumentParser()
    parser.add_argument("cmd_parts", help="Command to execute as admin.", nargs="+")
    args = parser.parse_args()
    cmd = subprocess.list2cmdline(args.cmd_parts)
    rtn = elevated_exec(cmd)
    sys.exit(rtn)
