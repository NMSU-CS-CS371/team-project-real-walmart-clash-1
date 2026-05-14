# Real Walmart Clash

Real Walmart Clash is a 2D tower defense-style game made in Godot. The player moves around the map, opens a builder menu, buys and places turrets or troops, and defends their base from waves of enemies. The goal is to survive as many rounds as possible while stronger enemy types and boss enemies are introduced over time.

## Controls

| Key | Action |
|---|---|
| WASD | Move the player |
| E | Interact / open the builder |
| Y | Start the round |
| Esc | Open or close the menu |

## Gameplay Overview

The player can move around the battleground and use the builder to buy defensive units. Turrets and troops can be placed on the map to stop enemies from reaching the base. Once the round starts, enemies spawn in waves and move toward the base. If enemies reach the base, the base loses health.

As the rounds increase, new enemy types are introduced. Some enemies are stronger, some have special effects, and horde rounds add extra difficulty. The player’s goal is to defend the base and make it to the highest round possible.

The game also includes a leaderboard that displays previous runs, allowing players to compare how far they made it.

## Features

- Player movement using WASD
- Builder system for buying and placing defenses
- Multiple turrets and troops
- Multiple enemy types
- Boss or special enemies
- Horde rounds
- Base health system
- Round-based survival gameplay
- Leaderboard for previous runs
- Saving and restoring placed towers

## Project Structure

The main project files are located inside the `godot_files` folder.

```text
team-project-real-walmart-clash-1/
│
├── godot_files/
│   ├── game.tscn
│   ├── Battleground.tscn
│   ├── enemy_backup.tscn
│   ├── enemy_2.tscn
│   ├── enemy_3.tscn
│   ├── enemy_4.tscn
│   ├── enemy_5.tscn
│   ├── enemy_6.tscn
│   ├── enemy_7.tscn
│   ├── enemy_8.tscn
│   ├── Turrets/
│   ├── Towers/
│   ├── GDScript/
│   └── New_Assets/
│
└── README.md
