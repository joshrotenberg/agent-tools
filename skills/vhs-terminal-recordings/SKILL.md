---
name: vhs-terminal-recordings
description: >-
  When a CLI or TUI project needs screenshots or a demo GIF for its README,
  record them with vhs from committed .tape scripts instead of staging them
  by hand. Covers the repo layout, determinism, the parser and Output
  gotchas that silently produce wrong output, and verifying the result by
  extracting frames rather than trusting it.
---

# Terminal recordings with vhs

[vhs](https://github.com/charmbracelet/vhs) turns a `.tape` script into a GIF
or PNG by driving a real terminal. Commit the tapes: an image regenerates when
the output changes, a hand-staged screenshot rots.

Install: `brew install vhs` (needs `ffmpeg`, which it pulls in).

## Layout

```
docs/
  tapes/          committed .tape scripts, plus a README on regenerating
    hero.tape
    describe.tape
  media/          the generated assets the docs point at
    hero.gif
    describe.png
```

For a Rust crate, exclude `docs/` from the package (`exclude = ["/docs"]` in
`Cargo.toml`) — a few hundred KB of GIF has no business in a `.crate`. Then
the README's images must use **absolute** URLs
(`https://raw.githubusercontent.com/<owner>/<repo>/main/docs/media/hero.gif`)
or they render broken on crates.io and docs.rs. Prose links can stay relative;
they resolve on the forge, which is where people click them.

## Record against a built binary

```bash
cargo build --release && vhs docs/tapes/hero.tape
```

Drive `./target/release/<bin>`, not `cargo run` — the tape would record
Cargo's build output. If the tape shells out to the binary by name, put it on
`PATH` for the run:

```bash
PATH="$PWD/target/release:$PATH" vhs docs/tapes/scripting.tape
```

That may not be enough. vhs starts a *login* shell, which re-reads the
profile and can put `~/.cargo/bin` (or any other install location) back in
front of your build. An older installed copy then gets recorded, and the
only symptom is a recording showing a version of the tool you did not build.
Confirm with `bash -lc 'command -v <bin>'` before trusting a still.

## A tape that works

```tape
# Regenerate with: cargo build --release && vhs docs/tapes/hero.tape
Output docs/media/hero.gif

Set Shell bash
Set FontSize 16
Set Width 1180
Set Height 660
Set Padding 14
Set Theme "Catppuccin Mocha"
Set TypingSpeed 55ms

Hide
Type "clear && ./target/release/mytool --demo --no-history"
Enter
Sleep 2.5s
Show

Type "ec"
Sleep 700ms
Tab                 # opens the completion menu
Sleep 2s
Enter               # accepts the highlighted entry
Sleep 500ms
Type ' message="hello"'
Enter
Sleep 1.4s

Type "quit"
Enter
Sleep 900ms
```

`Hide`/`Show` keeps the launch command out of the frame. Sleep generously
after `Enter`: a recording that cuts off mid-render looks broken.

## The six things that will bite you

### 1. `Output` ending in `.png` writes a *directory* of frames

For a still, send `Output` to a throwaway GIF and keep only the `Screenshot`:

```tape
Output "target/vhs-scratch-describe.gif"   # quoted; gitignore it
...
Screenshot docs/media/describe.png
```

Point both at the same `.png` and vhs turns your screenshot path into a folder
of several hundred `frame-cursor-00001.png` files.

Also quote any path with slashes in `Output` — an unquoted `/tmp/x.gif` fails
to parse.

### 2. `Screenshot` on the last line writes nothing

vhs needs a frame after the one it captures. As the final command it is a
no-op, and the run still exits 0:

```tape
Sleep 2s
Screenshot docs/media/thing.png
Sleep 500ms                        # required, or nothing is written
```

The old image stays on disk, so the regeneration looks like it worked. Check
the file's mtime, not the exit code.

### 3. `Type` cannot parse escaped quotes

```tape
Type "say \"hi\""     # parser error: Invalid command: \
Type 'say "hi"'       # correct: swap the outer quotes
```

Same for `$?` and friends inside a double-quoted `Type` — wrap the whole thing
in single quotes instead of escaping.

### 4. Shell history makes the recording depend on your machine

A REPL with a history hinter will pre-fill lines from whatever *you* last
typed, so the recording shows ghost text and the keystrokes in the tape land
somewhere unexpected. Pass whatever disables it (`--no-history`), or point
`$HOME`/state at a temp dir for the run. This one produces a recording that
looks subtly wrong and is not reproducible on any other machine.

### 5. Menus may not respond to arrow keys

If the app binds Tab to "open menu, then cycle" (a common reedline
configuration), advancing past the first candidate is another `Tab`, not
`Down`. Check the app's keybindings before assuming; `Down` silently does
nothing and you record the wrong selection.

### 6. Size the terminal to the longest line

Wrapped output looks broken in a README. Measure first:

```bash
./target/release/mytool --demo -e tools | awk '{print length}' | sort -rn | head -1
```

At `FontSize 16`, `Width 1180` gives roughly 118 columns. If the output does
not fit at ~100, that is a signal it is too wide for ordinary terminals too —
fix the program, not the recording.

## Verify by looking, not by assuming

vhs exits 0 on a recording that shows the wrong thing. Extract frames and
actually read them:

```bash
# how many frames
ffprobe -v error -count_frames -select_streams v:0 \
  -show_entries stream=nb_read_frames -of csv=p=0 docs/media/hero.gif

# pull a few out (n is the frame index)
ffmpeg -v error -i docs/media/hero.gif \
  -vf "select='eq(n\,90)+eq(n\,200)'" -vsync 0 /tmp/frame%d.png
```

Then open them. Things caught this way that a green exit did not: a completion
menu that never opened, a tool listing wrapping mid-tag, an enum demo that
selected the first option and converted a value to itself, and a result line
still showing `String("ada")` because the recording predated a fix.

## What makes a good hero recording

- **One story, ~20-30 seconds.** Show the thing the project is *for*, not a
  tour of every flag.
- **Lead with the differentiator.** If completion is the pitch, the first
  thing on screen should be a completion menu.
- **Let asynchronous output arrive.** If a background job prints when it
  finishes, sleep long enough to catch it; that line is often the best
  evidence the tool does what it claims.
- **End clean.** `quit`, brief pause, stop. A trailing shell prompt is fine;
  a half-typed line is not.
- **Keep it under ~2 MB** so it loads on a README.

## Regeneration notes belong in the repo

Put a short `docs/tapes/README.md` next to the tapes: the command, any `PATH`
requirement, which tape produces which asset, and the gotchas above that are
specific to your app. Whoever regenerates them next will not have this
context, and the failure mode is a silently wrong image rather than an error.
