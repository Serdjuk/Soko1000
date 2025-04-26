# Sokoban for ZX Spectrum 48K

## Project Overview

This project is a Sokoban game for the retro ZX Spectrum 48K computer. It includes **1000 levels** grabbed randomly from the following sources:

- [Sokoban Levels by Sneezing Tiger](http://sneezingtiger.com/sokoban/levels.html)
- [SourceCode.se Sokoban Levels](https://sourcecode.se/sokoban/levels.php)


## Level Specifications

- **Maximum Level Size**: 16x16 cells.
- **Cell Representation**: Each cell is a 12x12 pixel sprite on the screen.

## Level Compression

To fit 1000 levels into the ZX Spectrum 48K’s limited memory, a **very basic compression scheme** was used. It’s nothing fancy, just enough to get the job done. Each level is encoded like this:

- **First 4 bits**: Number of crates (same as the number of target containers).
- **Next 4 bits**: Width of the level.
- **Next 4 bits**: Height of the level.
- **Level Data**: A sequence of bits for the level layout, where a `1` bit means a wall.
- **Container Coordinates**: For each container (same number as crates), 4 bits for X-coordinate and 4 bits for Y-coordinate.
- **Crate Coordinates**: For each crate (same number as containers), 4 bits for X-coordinate and 4 bits for Y-coordinate.
- **Player Coordinates**: 4 bits for the player’s X-coordinate and 4 bits for the Y-coordinate.

This simple setup keeps memory usage low enough to store 1000 levels in the ZX Spectrum’s constraints.

## Acknowledgments

Thanks to all the level authors whose work is used in this game. Their names are listed in the game itself.

## License

This project is free and open-source, distributed for non-commercial use. Feel free to explore, modify, and share!