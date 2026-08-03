# editor_app

A text editor built from scratch using Flutter.

## Features available
1. Basic keyboard interactions
2. Virtualization (with cross axis scroll calculation)
3. Keyboard shortcuts (top level shortcuts registered with support for more)
4. Cursor placement and animations
5. Zooming.
6. Line numbers

## Next set of features being built

Please look at the TODOs folder in the repo for the next set of action items.

## Running the project

Run using

```
flutter run -d mac
```

Ripgrep is now part of the macOS build (not part of the linux or windows builds!!!).
Steps to build a binary (from the base folder path):
```
rm -rf external
bash create_release_build.sh
```

## Demo

https://github.com/user-attachments/assets/e2eebdda-9ba7-4f17-bba2-26c3286d5340


