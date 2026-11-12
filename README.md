# Lost Soul

A dark-and-light 2D platformer built in a **3-day hackathon at KIT (ClementineJam, 24–26 April 2026)** by a team of four, in **Godot 4.6**.

You run through a pitch-dark pixel-art forest with nothing but a flashlight, while something chases you. The darkness is the main mechanic: your light is limited and checkpoints light the way.

## Mechanics

- **Flashlight** with its own energy bar — the forest is only visible where you point it
- **Darkness blocks and checkpoints**
- **Dash** (with cooldown bar), **double jump** and **wall jump**
- **Chasing monster**, enemies, kill zones and healing pickups
- Three levels, a main menu, a level preview camera and a health bar with delayed damage

## Run it

1. Install [Godot 4.6](https://godotengine.org/download).
2. Open `project.godot` and press **Play** (F5).

Controls: move `A`/`D` or `←`/`→`, jump `Space`, dash `Shift` or `F`, flashlight `Z`.

## Team

Made together in one weekend:

- [Alparslan Semiz](https://github.com/AlparslanSemiz) — gameplay programming: jumps, wall zones, dash cooldowns and animation feedback; the flashlight, darkness, checkpoints, healing zones, pickups, hazards and scene transitions
- [aarmert](https://github.com/aarmert) — level 1, player scripts
- [Maya-Tukel](https://github.com/Maya-Tukel) — art, music and sound effects, finish portal and orbs
- [reignthevth](https://github.com/reignthevth) — project setup and first prototype, scenes, levels, animations

The original jam repository is [reignthevth/GAMEJAM](https://github.com/reignthevth/GAMEJAM); this is a cleaned-up copy for the portfolio.

## Credits

Pixel-art, music and sound assets are from free asset packs (see `blockholders/` and `music_sound_gamejam/`); their licenses belong to their authors.
