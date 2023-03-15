"""
Unit test file.
"""
import os
import unittest

COMMAND = "sudo_win32 echo HI"

HERE = os.path.abspath(os.path.dirname(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(HERE, ".."))
PAEXEC_EXE = os.path.join(PROJECT_ROOT, "src", "sudo_win32", "paexec.exe")


class MainTester(unittest.TestCase):
    """Main tester class."""

    def test_cli(self) -> None:
        """Test command line interface (CLI)."""
        rtn = os.system(COMMAND)
        self.assertEqual(0, rtn)

    def test_paexec_exe_exists(self) -> None:
        """Test that paexec.exe exists."""
        self.assertTrue(os.path.exists(PAEXEC_EXE))


if __name__ == "__main__":
    unittest.main()
