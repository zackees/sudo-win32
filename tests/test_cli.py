"""
Unit test file.
"""

import os
import unittest

from sudo_win32.elevated_exec import elevated_exec
from sudo_win32.install import install_once

COMMAND_LIST = ["sudo_win32", "echo", "HI"]

if os.environ.get("GITHUB_ACTIONS", "0") == "1":
    os.environ["TESTING_MODE"] = "1"


class MainTester(unittest.TestCase):
    """Main tester class."""

    def test_gsudo_exe(self) -> None:
        """Test gsudo.exe."""
        gsudo_exe = install_once()
        self.assertTrue(os.path.exists(gsudo_exe))

    def test_cli(self) -> None:
        """Test command line interface (CLI)."""
        rtn = elevated_exec(COMMAND_LIST)
        self.assertEqual(0, rtn)

    def test_bad(self) -> None:
        """Tests that the rtn value is propagated up."""
        # rtn = os.system("sudo_win32 badcmd")
        rtn = elevated_exec(["badcmd"])
        self.assertNotEqual(0, rtn)


if __name__ == "__main__":
    unittest.main()
