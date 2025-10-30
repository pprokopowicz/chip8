# Chip8

My version of Chip8 interpreter written in Zig.

## Usage

To run use the following command:

```console
foo@bar:~$ zig build run -- --rom <PATH_TO_ROM>
```

Available arguments:
- `--rom` path to rom file, this is the only argument that's mandatory.
- `--scale` sets window display with scale from original resolution of 64x32. Default value is 16.
- `--foreground-color` sets texture foreground color, pass this value in hex. Default is white.
- `--background-color` sets texture background color, pass this value in hex. Default is black.
- `--mute` if added audio will be muted.

Command with every option might look like this:
```console
foo@bar:~$ zig build run -- --rom /file/path/rom.ch8 --scale 32 --foreground-color FFFFFF --background-color 000000 --mute
```

## Notes

Prerequisite to running is having [SDL3](https://github.com/libsdl-org/SDL) installed. As far as I know Linux should have it out of the box, on macOS use homebrew to install.


Currently tested on macOS and Linux.
