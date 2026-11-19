# King Gong (Godot): the message moves off the chord signs

Short design. Project: `godot-implementations/king-gong/`.

## Why

When you fall, or play a wrong note or chord, a line of text says why ("That isn't Gm: play
G Bb D", "No Am chord, so the log stayed up…"). It runs across the whole screen at
y ≈ 123–153 of the 1280 × 720 view. The chord signs hang in that same band: a sign's board
spans y ≈ 101–175, and a seventh's tall bass-clef board starts at y ≈ 88. So the message
covers the next two signs at the moment you need to read them to try again. The user
reported this in the chord drill. Every mode uses the same message line.

## Goals

- The message sits at the top, centred, in a dark rounded pill like the counter pill
  (bananas · wrong · Esc). It goes just under the progress line's percentage and above
  every sign, the tall seventh boards included.
- It never covers a standing chord sign, the key hint under one, the progress percentage
  or the counter pill.
- It stays one line, and the pill is sized to its text.
- The words, the timing (2.8 s, fading over the last fifth) and the warm colour don't change.

## Non-goals

- No change to what the messages say or when they come.
- No speech bubble, and nothing that follows the gorilla.
- A note label on the staff's very top line (F5 in the treble, A3 in the bass) may touch
  the pill's lower edge while a message shows. This is accepted, because no other band
  above the signs is free.

## Approaches

- **Top, in a dark pill.** Picked by the user. The message stays near where you look and
  clears every sign. It shares the top edge with the counters.
- **Bottom, above the little keyboard.** This keeps the staff clear. But the message is far
  from where you look, and it covers the gorilla on low notes and where it lands after a fall.
- **Left of the gorilla, over what is already passed.** This keeps the message level with
  the signs. But that space is narrow, so messages wrap to two or three lines.

## Design

- `Hud/Banner` becomes a band across the top, from y 34 to y 70, that centres a pill. The
  pill holds the text. Showing, hiding and the fade work on the whole band, as they do now.
- The pill is styled like the counter pill: dark green-black, a little more opaque so it
  reads over the canopy, with fully rounded ends.
- The text keeps `ui/banner.tres`, but its font size goes from 25 to 22, so the pill fits
  between the percentage (which ends at y ≈ 30) and the tallest sign (from y ≈ 88).
- **Builder's call:** the pill's exact margins and corner radius, as long as the dev
  check passes.

## Check

Each frame a message shows, the dev bot checks that the pill clears each of these:

- the standing signs on screen, and their key hints;
- the highest point a tall sign can reach;
- the progress percentage;
- the counter pill;
- the screen's edges.

It prints `banner: clear of the signs` the first time the check passes.
