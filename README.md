# sudo-win32

This missing sudo command for win32.

[![Linting](../../actions/workflows/lint.yml/badge.svg)](../../actions/workflows/lint.yml)

[![Win_Tests](../../actions/workflows/push_win.yml/badge.svg)](../../actions/workflows/push_win.yml)

# Usage

```python
pip install sudo_win32
sudo_win32 taskkill /F /im wslservice.exe
```

Note that the command is recommended to be a string. If this isn't done, then the command
will be concatenated using subprocess.list2cmdline.

If this package solves a problem in your life then you are obligated to give this repo
a star. If you don't, then you are a bad person.

# How this works

I discovered this solution while at Google and did a proper implementation of it.

This command executes an elevated command in windows. Very tricky. Many articles have been written
about this topic. This is the best solution I could find is to use a mix of batch programs
and powershell:
1. Powershell is used to execute a batch file and raises the privledges to admin level.
2. The batch file
  a. executes the command as admin.
  b. echoes "done" to a file as a normal user
3. The calling python waits until the "done" file appears then exits.

# Development

To develop software, run `. ./activate.sh`

# Windows

This environment requires you to use `git-bash`.

# Linting

Run `./lint.sh` to find linting errors using `pylint`, `flake8` and `mypy`.

# Release Notes

  * 1.0.1 - Fixing the readme
  * 1.0.0 - Initial release