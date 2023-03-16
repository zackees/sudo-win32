"""
Unit test file.
"""

import os
import unittest

from sudo_win32.elevated_exec import elevated_exec
from sudo_win32.install import install_once

COMMAND_LIST = ["sudo_win32", "echo", "HI"]

IS_TESTING = os.environ.get("GITHUB_ACTIONS", "0") == "1"
if IS_TESTING:
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
        env_copy = os.environ.copy()
        # delete paths
        env_copy.pop("PATH", None)
        for key, value in env_copy.items():
            print(f"{key}={value}")
        cmd_list = ["badcmd"]
        if IS_TESTING:
            cmd_list = ["cmd.exe", "/C", "badcmd"]
        rtn = elevated_exec(cmd_list)
        self.assertNotEqual(0, rtn)


if __name__ == "__main__":
    unittest.main()
