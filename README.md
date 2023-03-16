# sudo-win32

This missing sudo command for win32.

[![Linting](../../actions/workflows/lint.yml/badge.svg)](../../actions/workflows/lint.yml)
[![Tests](../../actions/workflows/Win_Tests.yml/badge.svg)](../../actions/workflows/push_win.yml)

# Usage

```bash
> pip install sudo_win32[sudo]
> sudo taskkill /F /im wslservice.exe
```

If you omit [sudo] then the command will just be `sudo_win32`.

If this package solves a problem in your life then you are obligated to give this repo
a star. If you don't, then you are a bad person.

In this releae the stdout and stderr are not returned when elevating privledges.

# How this works

I use powershell to raise permissions and then execute the command. The return value and
stdout/stderr are returned.

# Development

To develop software, run `. ./activate.sh`

# Windows

This environment requires you to use `git-bash`.

# Linting

Run `./lint.sh` to find linting errors using `pylint`, `flake8` and `mypy`.

# Release Notes
  * 1.0.5 - sudo-win32[sudo] now works correctly, before it was unconditionally installing.
  * 1.0.3 - The stdout/stderr are now correct re-routed back.
  * 1.0.2 - The return value of the command is now returned when elevating privledges.
  * 1.0.1 - Fixing the readme
  * 1.0.0 - Initial release
