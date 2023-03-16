# sudo-win32

This missing sudo command for win32. Thin wrapper over `gsudo`. Check out the excellent repo [here](https://github.com/gerardog/gsudo).

[![Linting](../../actions/workflows/lint.yml/badge.svg)](../../actions/workflows/lint.yml)
[![Tests](../../actions/workflows/push_win.yml/badge.svg)](../../actions/workflows/push_win.yml)

# Usage

```bash
> pip install sudo_win32[sudo]
> sudo taskkill /F /im wslservice.exe
```

If you omit [sudo] then the command will just be `sudo_win32`.

# Development

To develop software, run `. ./activate.sh`

# Windows

This environment requires you to use `git-bash`.

# Linting

Run `./lint.sh` to find linting errors using `pylint`, `flake8` and `mypy`.

# Release Notes
  * 1.0.6 - Switch the implementation to `gsudo`, which is excellent and does everything this lib needs.
  * 1.0.5 - sudo-win32[sudo] now works correctly, before it was unconditionally installing.
  * 1.0.3 - The stdout/stderr are now correct re-routed back.
  * 1.0.2 - The return value of the command is now returned when elevating privledges.
  * 1.0.1 - Fixing the readme
  * 1.0.0 - Initial release
