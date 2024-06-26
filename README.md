Here's a few assembly patches for Virtual Boy games.

# Patches

## Bound High!
These separate debug and save patches have been designed not to clash with each other, so you can apply both if you feel like it. A warning, however: you can pretty easily mess up your save with the debug cheats by e.g. giving yourself unbeatable high scores of 999900. Personally I'd suggest separate debug and save ROMs if you have any concerns about losing your legit scores.
* `bound-debug.asm`
  * compatible with `Bound High (World) (Proto 2).vb`
    * **note:** this ROM is relatively new (2018, vs. `Proto 1` from 2010) and was only added to No-Intro in May 2024
  * restores all known dummied debug features
    * title screen button combos:
      * play Adventure of Chalvo opening cutscene
        * **Left D-Pad: Left**, **Left**, **Select**, **Start**, **B**
      * play Adventure of Chalvo ending cutscene
        * **Right D-Pad: Right**, **Right**, **A**, **B**, **Start**
    * Score Attack!!/Pocket and Cushion stage select button combos:
      * play 16 stages clear cutscene
        * **Right D-Pad: Left**, **Left**, **A**, **B**, **Start**
      * play 20 stages clear cutscene
        * **Right D-Pad: Right**, **Right**, **A**, **B**, **Start**
      * 16 stages clear/unlock 17-20
        * **Left D-Pad: Right**, **Right**, **Select**, **Start**, **B**
      * complete next stage selected with maximum score
        * **Left D-Pad: Up**, **Down**, **Up**, **Down**, **B**
    * pause menu button combos:
      * Round Select
        * Hold **R**, then press **Right D-Pad: Up**, **Down**, **Left**, **Right**
      * Sound Test Mode
        * Hold **R**, then press **B**, **A**, **L**, **L**
      * Automatic Play
        * Hold **R**, then press **L**, **Right D-Pad: Left**, **L**, **Right D-Pad: Right**, **L**, **Right D-Pad: Down**
      * Enable Expert Enemies
        * Hold **R**, then press **Right D-Pad: Down**, **Left**, **Up**, **Right**, **Left D-Pad: Down**, **Right**, **Up**, **Left**
      * Change Difficulty
        * Hold **R**, then press **Left D-Pad: Up** eight (8) times
      * Frame Advance Mode
        * Hold **L** and **R**, then press **B**
* `bound-save.asm`
  * compatible with `Bound High (World) (Proto 2).vb`
  * Adventure of Chalvo mode:
    * saves the most recent received/entered password
    * defaults to Continue if you have a password saved
  * Score Attack!! and Pocket and Cushion modes:
    * saves high scores and stage completion stats
    * password system is removed entirely
  * erase save by pressing **L** + **R** + **Left D-Pad Down** + **Right D-Pad Down** on the title screen

## Golf
* `golf-save.asm`
  * compatible with `Golf (USA).vb`
  * restores full save support from the Japanese game, replacing password system
  * erase saves with the normal in-game menu under Individual Records

## Hyper Fighting
* `highting-fix.asm`
  * compatible with `Hyper Fighting (World) (Aftermarket) (Unl).vb`
  * fixes a minor bug where the Brightness setting fails to save if you set it to maximum

## Jack Bros.
* `jackbros-save.asm`
  * compatible with `Jack Bros. (USA).vb` **only**
  * does not apply to the Japan ROM but you can use the secret language-swap button code built into the original game (!). Hold **L**, **R** and **Left D-Pad Left** then press **Start** on the title screen; this will switch languages and save the new setting to SRAM
  * adds ability to enable/disable the [debug mode](https://www.virtual-boy.com/games/jack-bros/guides/). Hold **Select** while booting the game; this setting is also saved to SRAM. The title screen shows "DEBUG" in the bottom right when enabled
  * enables the [Japan-only sound test](https://www.virtual-boy.com/games/jack-bros/guides/) and fixes the Japanese text to display correctly
  * separately saves progress for all "three" characters from the Select Player screen **and/or** by entering passwords, i.e. passwords *will* replace your save games
  * saves the difficulty setting (normal/"for super players"), with separate save slots for normal and super difficulties
  * adds ~~secret character~~ to the Select Player screen. Hold **L** + **R** while cycling through characters
  * erase individual character saves by pressing **Left D-Pad Down** four times in a row while they are highlighted on the Select Player screen. There are warning sounds

## Mario Clash
* `marioclash-save.asm`
  * compatible with `Mario Clash (Japan, USA).vb`
  * adds support for saving your level progress, high scores and brightness
  * replaces the original capped 1 to 40 level select with the option to select any level that you've previously reached, all the way up to 99
  * optionally remap the controls to be closer to other Mario games (based on [Controller Fix by DogP](https://www.virtual-boy.com/games/mario-clash/downloads/))
  * erase save by pressing **L** + **R** + **Left D-Pad Down** + **Right D-Pad Down** on the title screen

## Nester's Funky Bowling
* `nester-save.asm`
  * compatible with `Nester's Funky Bowling (USA).vb`
  * adds support for saving your name, character, ball weight and the League Leaders (high scores)
  * erase save by pressing **L** + **R** + **Left D-Pad Down** + **Right D-Pad Down** on the title screen

## Red Alarm
* `redalarm-save.asm`
  * compatible with either `Red Alarm (USA).vb` or `Red Alarm (Japan).vb`
  * adds support for saving your high score 
  * prevents high score from being written while running in debug mode
  * saves all options screen settings: brightness, depth, button control scheme and difficulty
  * erase save by pressing **L** + **R** + **Left D-Pad Down** + **Right D-Pad Down** on the title screen

## Space Squash
* `sposh-save.asm`
  * compatible with `Space Squash (Japan).vb` (and the English translation patch if you like)
  * disables the forced delay to read the warning screen
  * title screen: makes **Start** button open the main menu instead of booting directly into game
  * saves game progress and character upgrades at the end of each Area
  * adds a Continue option on the main menu to load saved progress
  * adds support for saving high scores
  * fixes an original game bug when updating high scores (old scores weren't propagated down the list correctly when beaten)
  * saves all Config Mode options: level (difficulty), backdrop, BGM toggle, match points, continues and brightness
  * erase save by pressing **L** + **R** + **Left D-Pad Down** + **Right D-Pad Down** on the title screen

## Vertical Force
* `vert-u-save.asm` and `vert-j-save.asm`
  * compatible with `Vertical Force (USA).vb` and `Vertical Force (Japan).vb`, respectively
  * adds support for saving high scores and completion times in all three difficulties
  * prevents high scores/best times from being written if you came via level select
  * saves the brightness, difficulty and control settings
  * erase save by pressing **L** + **R** + **Left D-Pad Down** + **Right D-Pad Down** on the title screen

## V-Tetris
* `vtetris-save.asm`
  * compatible with `V-Tetris (Japan).vb`
  * adds support for saving high scores
  * erase save by pressing **L** + **R** + **Left D-Pad Down** + **Right D-Pad Down** on the title screen

## Waterworld
* `water-save.asm`
  * compatible with `Waterworld (USA).vb`
  * adds a high score display in the top left of the HUD
  * minor HUD rearrangements to make the high score fit in the limited space, e.g. `PLAYER` (or `LEADER`/`WINNER` in multiplayer) reduced to `P` (`L`/`W`)
  * adds saving for the new high score feature
  * only shows the auto-pause selection on boot, instead of every time you game over
  * disables the annoying reminder noise if you don't press any buttons for a while
  * erase save by pressing **L** + **R** + **Left D-Pad Down** + **Right D-Pad Down** on the title screen

# How to build
These patches are written for [Matej's V810 assembler](http://matejhorvat.si/en/software/mv810asm/), an excellent assembler with ROM patching capabilities available for DOS, Windows (x86) and Mac OS (Intel, PowerPC and 68k).

You can build your patched ROMs like so:
```
MV810Asm bound-debug.asm bound-debug.vb /V /H "Bound High (World) (Proto 2).vb"
MV810Asm bound-save.asm bound-save.vb /V /H "Bound High (World) (Proto 2).vb"
MV810Asm golf-save.asm golf-save.vb /V /H "Golf (USA).vb"
MV810Asm highting-fix.asm highting-fix.vb /V /H "Hyper Fighting (World) (Aftermarket) (Unl).vb"
MV810Asm jackbros-save.asm jackbros-save.vb /V /H "Jack Bros. (USA).vb"
MV810Asm marioclash-save.asm marioclash-save.vb /V /H "Mario Clash (Japan, USA).vb"
MV810Asm marioclash-save.asm marioclash-save-bswap.vb /V /I BUTTON_SWAP 1 /H "Mario Clash (Japan, USA).vb"
MV810Asm nester-save.asm nester-save.vb /V /H "Nester's Funky Bowling (USA).vb"
MV810Asm redalarm-save.asm redalarm-save.vb /V /H "Red Alarm (USA).vb"
MV810Asm sposh-save.asm sposh-save.vb /V /H "Space Squash (Japan).vb"
MV810Asm vert-u-save.asm vert-u-save.vb /V /H "Vertical Force (USA).vb"
MV810Asm vert-j-save.asm vert-j-save.vb /V /H "Vertical Force (Japan).vb"
MV810Asm vtetris-save.asm vtetris-save.vb /V /H "V-Tetris (Japan).vb"
MV810Asm water-save.asm water-save.vb /V /H "Waterworld (USA).vb"
```
You will need to supply clean original ROMs. Filenames are examples only.

If you don't need to modify these hacks, you can also just download pre-built IPS patches from the [Releases tab](https://github.com/vaguerant/vb-patches/releases).