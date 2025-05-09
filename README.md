# TexModAutomator

[![Build](https://github.com/ddav2/TexModAutomator/actions/workflows/main.yml/badge.svg)](https://github.com/ddav2/TexModAutomator/actions/workflows/main.yml)

This project is an automation tool for [TexMod](https://www.fileplanet.com/archive/p-16225/Texmod-v0-9b).
It is written in the [AutoIt](https://www.autoitscript.com/site/autoit/) scripting language.

## What is TexMod?

> TexMod is an utility to find, save and modify textures in Direct3D 9 applications.
> The tool is very important, if you want to install graphic patches, like skin patches to your games.
> (Source: [ModDB.com](https://www.moddb.com))

The TexMod beta version v0.9b was released by RS &lt;[rstoff@gmail.com](mailto:rstoff@gmail.com)&gt; back in 2006 and was not further maintained
(source: [FilePlanet.com](https://www.fileplanet.com/archive/p-16225/Texmod-v0-9b)).
Unfortunately, since TexMod is closed source, there is no easy way for anyone else to improve it.

**The main problem with TexMod is that it lacks automation.**
If you want to launch a game with certain texture mods (*.tpf files),
you have to select the game EXE and the mod files in the TexMod GUI manually every time.
This can become annoying if you play the game often.
TexMod does not have a command line interface nor does it use any configuration files.

## What does TexModAutomator do?

TexModAutomator is an [AutoIt](https://www.autoitscript.com/site/autoit/) script that automatically
interacts with the TexMod GUI to start a game with certain texture mods (*.tpf files).
TexModAutomator reads its configuration from an [INI](https://en.wikipedia.org/wiki/INI_file) file (`TexModAutomator.ini`)
that specifies where the game EXE and the mods are located.
This file can be easily edited by a user.

## TexModAutomator.ini
Here is an example of the `TexModAutomator.ini` configuration file with an explanation of each option:
```ini
[Settings]
; "Alters how long a script should briefly pause after a successful window-related operation.
; Time in milliseconds to pause (default=250)."
; Source: https://www.autoitscript.com/autoit3/docs/functions/AutoItSetOption.htm
WinWaitDelay=250

; Texmod.exe path
TexModExe=Texmod.exe

; Game executable path
GameExe=game.exe

; Timeout in seconds for certain blocking operations,
; for example, waiting until a TexMod window becomes active.
; 0 means no timeout.
Timeout=2

; Timeout in seconds when waiting for the game to close.
; 0 means no timeout.
; You can usually ignore this setting and keep it at 0.
TimeoutGameClose=0

; Automatically start the game after setting everything up in TexMod (boolean)
AutoRunGame=1

; Automatically close TexMod when the game closes (boolean)
AutoCloseTexMod=1

; The directory with the *.tpf mod files
; If empty, the paths of the individual mod files should be fully qualified.
ModDir=Mods

[Mods]
; List the desired *.tpf mods down below.
; The mod files are specified relative to the ModDir directory.
; The order of the mods might be important,
; because later mods can overwrite textures from the previous mods.
=mod1.tpf
=mod2.tpf
=mod3.tpf
```

## Recommended Setup
The following procedure is recommended to enable TexMod for a game.
The goal is to replace the original game EXE with our automation binary.
Examples will be given for Tomb Raider Legend but the steps can be adjusted for different games:

1. Download `TexMod.exe` and `TexModAutomator.exe` into the game folder
2. Create a backup of the original game EXE, e.g., create a copy of `trl.exe` named `trl.exe.bak`
3. Rename the original game EXE to `game.exe`
4. Create a copy of `TexModAutomator.exe` and name it like the original game EXE,
   e.g., create a copy of `TexModAutomator.exe` named `trl.exe`
5. Create and adjust the `TexModAutomator.ini` file
6. Enjoy the modded game :)

If you now try to run the game normally (e.g. from Steam), it will start our automation tool
which will launch the game with the mods in TexMod.

# Background
## Existing TexMod Automation Tools
There have already been attempts to automate TexMod.
Here are some notable TexMod automation projects I have found:
- [texmodAutoload](https://github.com/LucasArmanelli/texmodAutoload) by Lucas Armanelli
  - An AutoIt TexMod automation script
  - The source code is available on GitHub
- [EasyTexMod](https://www.nexusmods.com/xcom/mods/525/) by eclipse666 aka SpazmoJones
  - A binary `AutoTexMod.exe` for the TexMod automation
  - A GUI installer `EasyTexMod.exe` for the `AutoTexMod.exe` binary
  - Closed source

Feel free to check out these projects yourself :)

## Goal of This Project
Although the existing tools have interesting approaches, in my experience, they were too unreliable or lacked certain features.
I created this project because I was not satisfied with the existing tools.
This project was mainly inspired by [texmodAutoload](https://github.com/LucasArmanelli/texmodAutoload).

The goal of this project is to create a TexMod automation tool that is
- Efficient
- Easy to use
- Open source
- Well-documented

It should be noted that this tool is still rather a workaround than a real solution to the issues in TexMod.
A long-term solution would be to enhance or to rewrite TexMod so that it gets automation built in.

# License
TexModAutomator is developed by Daniel Davidovich and available under the [MIT License](https://opensource.org/license/MIT).
See [LICENSE](LICENSE) for the full license text.
