"""
Unit test file.
"""
import os
import unittest

from sudo_win32.elevated_exec import elevated_exec

COMMAND = "sudo_win32 echo HI"


class MainTester(unittest.TestCase):
    """Main tester class."""

    def test_cli(self) -> None:
        """Test command line interface (CLI)."""
        rtn = os.system(COMMAND)
        self.assertEqual(0, rtn)

    def test_bad(self) -> None:
        """Tests that the rtn value is propagated up."""
        # rtn = os.system("sudo_win32 badcmd")
        rtn = elevated_exec("badcmd")
        self.assertEqual(1, rtn)


if __name__ == "__main__":
    unittest.main()
