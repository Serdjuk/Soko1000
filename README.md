# Sokoban for ZX Spectrum 48K

## Project Overview

This project is a Sokoban game developed for the retro ZX Spectrum 48K computer. It includes **1000 carefully curated levels** sourced from the following resources:

- [Sokoban Levels by Sneezing Tiger](http://sneezingtiger.com/sokoban/levels.html)
- [SourceCode.se Sokoban Levels](https://sourcecode.se/sokoban/levels.php)

The game is free, open-source, and distributed under a permissive license.

## Level Compression

To fit 1000 levels into the limited memory of the ZX Spectrum 48K, an efficient compression scheme was implemented. Each level is encoded using the following structure:

- **First 4 bits**: Number of crates (equal to the number of target containers).
- **Next 4 bits**: Width of the level.
- **Next 4 bits**: Height of the level.
- **Level data**: A linear sequence of bits representing the level layout, where a `1` bit indicates a wall.
- **Container coordinates**: For each container (equal to the number of crates), 4 bits for X-coordinate and 4 bits for Y-coordinate.
- **Crate coordinates**: For each crate (same count as containers), 4 bits for X-coordinate and 4 bits for Y-coordinate.
- **Player coordinates**: 4 bits for the player's X-coordinate and 4 bits for the player's Y-coordinate.

This compact representation minimizes memory usage while preserving all necessary level information, allowing the inclusion of 1000 levels within the ZX Spectrum's constraints.

## Acknowledgments

Special thanks to all the level authors whose work is featured in this game. Their names are credited within the game itself.

## License

This project is free and open-source, distributed for non-commercial use. Feel free to explore, modify, and share!