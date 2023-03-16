"""
Main entry point.
"""

import sys

from .elevated_exec import elevated_exec


def main() -> int:
    """Main entry point for the template_python_cmd package."""
    rtn = elevated_exec(sys.argv[1:])
    sys.exit(rtn)
