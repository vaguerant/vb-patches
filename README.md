Here's a few assembly patches for Virtual Boy games.

# Patches
* `golf-save.asm`
  * compatible with `Golf (USA).vb`
  * restores full save support from the Japanese game, replacing password system
  * erase saves with the normal in-game menu under Individual Records
* `marioclash-save.asm`
  * compatible with `Mario Clash (Japan, USA).vb`
  * adds support for saving your level progress, high scores and brightness
  * replaces the original capped 1 to 40 level select with the option to select any level that you've previously reached, all the way up to 99
  * erase save by pressing **L** + **R** + **Left D-Pad Down** + **Right D-Pad Down** on the title screen
* `redalarm-save.asm`
  * compatible with either `Red Alarm (USA).vb` or `Red Alarm (Japan).vb`
  * adds support for saving your high score and all options screen settings: brightness, depth, button control scheme and difficulty
  * erase save by pressing **L** + **R** + **Left D-Pad Down** + **Right D-Pad Down** on the title screen

# How to build
These patches are written for [Matej's V810 assembler](http://matejhorvat.si/en/software/mv810asm/), an excellent assembler with ROM patching capabilities available for DOS, Windows (x86) and Mac OS (Intel, PowerPC and 68k).

You can build your patched ROMs like so:
```
MV810Asm golf-save.asm golf-save.vb /V /H "Golf (USA).vb"
```
```
MV810Asm marioclash-save.asm marioclash-save.vb /V /H "Mario Clash (Japan, USA).vb"
```
```
MV810Asm redalarm-save.asm redalarm-save.vb /V /H "Red Alarm (USA).vb"
```
You will need to supply clean original ROMs. Filenames are examples only.

If you don't need to modify these hacks, you can also just download pre-built IPS patches from the [Releases tab](/releases).