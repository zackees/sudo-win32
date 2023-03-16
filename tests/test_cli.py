"""
Unit test file.
"""

import os
import unittest

from sudo_win32.elevated_exec import elevated_exec
from sudo_win32.install import install_once


class MainTester(unittest.TestCase):
    """Main tester class."""

    def test_gsudo_exe(self) -> None:
        """Test gsudo.exe."""
        gsudo_exe = install_once()
        self.assertTrue(os.path.exists(gsudo_exe))

    def test_cli(self) -> None:
        """Test command line interface (CLI)."""
        rtn = elevated_exec(["echo", "HI"])
        self.assertEqual(0, rtn)

    def test_bad(self) -> None:
        """Tests that the rtn value is propagated up."""
        cmd_list = ["cmd.exe", "/c", "badcmd"]  # fix for when in admin mode.
        rtn = elevated_exec(cmd_list)
        self.assertNotEqual(0, rtn)


if __name__ == "__main__":
    unittest.main()
