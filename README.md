# sudo-win32

This missing sudo command for win32. This is a thin wrapper over `gsudo`. Check out the excellent repo [here](https://github.com/gerardog/gsudo).

The only benefit for this repo is that you don't need administrator privledges in order to use this tool, while using
something like choco install `gsudo` requires admin privledges. stderr/stdout and process return values are all supported.
If you want to use `gsudo` directly, you can install it with `choco install gsudo`.

The most recent `gsudo` version used is `2.0.4`


[![Linting](../../actions/workflows/lint.yml/badge.svg)](../../actions/workflows/lint.yml)
[![Tests](../../actions/workflows/push_win.yml/badge.svg)](../../actions/workflows/push_win.yml)

# Usage

```bash
> pip install sudo_win32[sudo]
> sudo taskkill /F /im wslservice.exe
```

If you omit [sudo] then the command will just be `sudo_win32`.

# Documentation

This is shamelessly ripped from the `gsudo` repo and is kept as-is. Simply replace `gsudo` with
`sudo_win32` or `sudo` if you installed with the [sudo] extra. Otherwise it's the same.

## Usage

``` powershell
gsudo [options]                  # Elevates your current shell
gsudo [options] {command} [args] # Runs {command} with elevated permissions
gsudo cache [on | off | help]    # Starts/Stops a credentials cache session. (less UAC popups)
gsudo status                     # Shows current user, cache and console status.
gsudo !!                         # Re-run last command as admin. (YMMV)
```

``` powershell
New Window options:
 -n | --new            # Starts the command in a new console/window (and returns immediately).
 -w | --wait           # When in new console, wait for the command to end.
 --keepShell           # After running a command, keep the elevated shell open.
 --keepWindow          # After running a command in a new console, ask for keypress before closing the console/window.

Security options:
 -u | --user {usr}     # Run as the specified user. Asks for password. For local admins shows UAC unless '-i Medium'
 -i | --integrity {v}  # Specify integrity level: Untrusted, Low, Medium, MediumPlus, High (default), System
 -s | --system         # Run as Local System account (NT AUTHORITY\SYSTEM).
 --ti                  # Run as member of NT SERVICE\TrustedInstaller
 -k                    # Kills all cached credentials. The next time gsudo is run a UAC popup will be appear.

Shell related options:
 -d | --direct         # Skips Shell detection. Asume CMD shell or CMD {command}.
 --loadProfile         # When elevating PowerShell commands, load user profile.

Other options:
 --loglevel {val}      # Set minimum log level to display: All, Debug, Info, Warning, Error, None
 --debug               # Enable debug mode.
 --copyns              # Connect network drives to the elevated user. Warning: Verbose, interactive asks for credentials
 --copyev              # (deprecated) Copy environment variables to the elevated process. (not needed on default console mode)
```

**Note:** You can use anywhere **the `sudo` alias** created by the installers.

**Examples:**

``` powershell
gsudo   # elevates the current shell in the current console window (Supports Cmd/PowerShell/Pwsh Core/Yori/Take Command/git-bash/cygwin)
gsudo -n # launch the current shell elevated in a new console window
gsudo -n -w powershell ./Do-Something.ps1 # launch in new window and wait for exit
gsudo notepad %windir%\system32\drivers\etc\hosts # launch windows app

sudo notepad # sudo alias built-in

# redirect/pipe input/output/error example
gsudo dir | findstr /c:"bytes free" > FreeSpace.txt

gsudo config LogLevel "Error"          # Configure Reduced logging
gsudo config Prompt "$P [elevated]$G " # Configure a custom Elevated Prompt
gsudo config Prompt --reset            # Reset to default value

# Enable credentials cache (less UAC popups):
gsudo config CacheMode Auto
```


# Development

To develop software, run `. ./activate.sh`

# Windows

This environment requires you to use `git-bash`.

# Linting

Run `./lint.sh` to find linting errors using `pylint`, `flake8` and `mypy`.

# Release Notes
  * 1.0.8 - Fixes some commands in admin mode.
  * 1.0.7 - Use shell mode for gsudo, since it's a better experience. Commands are merged via subprocess.list2cmdline
  * 1.0.6 - Switch the implementation to `gsudo`, which is excellent and does everything this lib needs.
  * 1.0.5 - sudo-win32[sudo] now works correctly, before it was unconditionally installing.
  * 1.0.3 - The stdout/stderr are now correct re-routed back.
  * 1.0.2 - The return value of the command is now returned when elevating privledges.
  * 1.0.1 - Fixing the readme
  * 1.0.0 - Initial release
