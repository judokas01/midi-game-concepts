# King Gong: the message moves off the chord signs — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The why-you-fell / what-was-wrong message moves from across the chord signs to a
dark pill at the top, under the progress line, clear of every sign.

**Architecture:** `Hud/Banner` in `main.tscn` turns from a full-width Label into a
CenterContainer band (y 34–70) holding a PanelContainer pill with the Label inside; `hud.gd`
writes the text into the Label and fades the band as before, and exposes the pill's rect for
the dev bot, which checks it against the signs every frame a message shows.

**Tech Stack:** Godot 4.7.2, typed GDScript, `main.tscn`, `ui/banner.tres`.

**Spec:** [docs/superpowers/specs/2026-11-13-king-gong-banner-design.md](../specs/2026-11-13-king-gong-banner-design.md)

## Global Constraints

- Project root: `godot-implementations/king-gong/`; paths below are relative to it.
- Godot: `C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe`. Never kill Godot processes you
  didn't start.
- Dev check: create `.superpowers/sdd/2026-11-13-king-gong-banner/check.sh` (repo root) with
  this body, and run it as `bash .superpowers/sdd/2026-11-13-king-gong-banner/check.sh "<expected>" [flags]`:

  ```bash
  #!/usr/bin/env bash
  expected=$1; shift
  log=$(mktemp)
  timeout 200 "C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe" --path "C:/game-dev/midi-game-concepts/godot-implementations/king-gong" -- --autoplay "$@" > "$log" 2>&1
  grep -E "^(paused|resumed|autoplay|menu:|pause:|end:|drill:|banner:)" "$log"
  if grep -qE "SCRIPT ERROR|^ERROR|ERROR:" "$log"; then grep -E -A3 "SCRIPT ERROR|ERROR" "$log" | head -30; echo "FAIL: errors"; exit 1; fi
  grep -qF "$expected" "$log" && { echo "PASS: $*"; exit 0; }
  echo "FAIL: expected '$expected'"; tail -5 "$log"; exit 1
  ```

  It opens a game window. Godot sometimes segfaults at quit; judge by the printed lines.
- The message's words, timing (2.8 s, fading over the last 0.56 s) and colour stay as they are.
- No commits. The user commits their own work.
- Code style: typed GDScript, tabs, `##` doc comments in the project's plain-English voice.

## Review Focus

1. **The longest message** ("No Cmaj7 chord, so the log stayed up. Play it together with
   F#4", about 760 px at 22 px) stays on one line and clear of the counter pill. The
   `--chords` run's "No … chord, so the log stayed up. Play it together with …" pins the
   long form; by eye in Step 5.
2. **A shorter message replacing a longer one before it fades** gets a shorter pill,
   re-centred (the CenterContainer does this; a PanelContainer anchored by itself would not
   shrink back). By eye in Step 5.
3. **The pause menu over a message**: the band stays under the pause menu (its place among
   the Hud children doesn't change) and its fade freezes with the game.
4. **A wider window** (stretch aspect `expand`): the band spans the full width, so the pill
   stays centred.
5. **Top-line note labels** (F5 treble, A3 bass) may touch the pill's lower edge: accepted
   in the spec, not a finding.

---

### Task 1: The message in a pill at the top

**Files:**
- Modify: `main.tscn` (the `Banner` node at the `[node name="Banner" …]` line, a new
  `StyleBoxFlat` sub-resource next to `StyleBoxFlat_pill`)
- Modify: `ui/banner.tres` (font size)
- Modify: `scripts/hud.gd` (`_banner`, `show_banner`, new `banner_rect`)
- Modify: `scripts/dev_autoplay.gd` (new `_check_banner`, called from `_play`)
- Modify: `README.md` (the counters paragraph, the learn-mode "banner" line, the Dev check list)

**Interfaces — Produces:** `hud.banner_rect() -> Rect2`: the message's pill on screen, or
`Rect2()` while no message shows. Only the dev bot calls it.

- [ ] **Step 1: Write the failing check**

In `scripts/hud.gd`, add the seam the check reads, returning today's banner as it is:

```gdscript
## Where the message shows on screen; empty while none does. For the dev check.
func banner_rect() -> Rect2:
	return _banner.get_global_rect() if _banner.visible else Rect2()
```

In `scripts/dev_autoplay.gd`, add `var _banner_ok := false` with the other state, call
`_check_banner()` in `_play` right after `_check_progress()`, and add:

```gdscript
## The message (why you fell, what was wrong) covers nothing you need to read: no standing
## chord sign on screen nor the key under it, nor where the tallest sign reaches, nor the
## percentage or the counters, and it stays on screen.
func _check_banner() -> void:
	var at: Rect2 = game.hud.banner_rect()
	if not at.has_area():
		return
	var covered: Array[String] = []
	for i in game.notes.size():
		var standing: ChordLog = game.world.chord_log(i)
		if standing == null or not game.notes[i].log_up:
			continue
		var board: Sprite2D = standing.get_node("Top/Sign/Board")
		var key: Label = standing.get_node("Top/Sign/Key")
		if at.intersects(board.get_global_transform_with_canvas() * board.get_rect()):
			covered.append("the %s sign" % game.notes[i].chord.name)
		if key.text != "" and at.intersects(key.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, key.size)):
			covered.append("the %s key" % game.notes[i].chord.name)
	var tallest := get_viewport().get_canvas_transform() * Vector2(0.0, ChordLog.SIGN_Y - ChordLog.TALL_BOARD.get_height() / 2.0)
	if at.end.y > tallest.y:
		covered.append("where a seventh's tall sign reaches")
	if at.intersects(game.hud.get_node("Progress").label_rect()):
		covered.append("the percentage")
	if at.intersects(_pill().get_global_rect()):
		covered.append("the counters")
	if not get_viewport().get_visible_rect().encloses(at):
		covered.append("the screen's edge")
	if not covered.is_empty():
		push_error("the banner %s covers %s" % [at, ", ".join(covered)])
	elif not _banner_ok:
		_banner_ok = true
		print("banner: clear of the signs")
```

Add one line to the header comment, under `--shots`:
`##   every run checks the message, whenever it shows, clears the chord signs and the counters`.

- [ ] **Step 2: Run it to see it fail**

Run: `bash .superpowers/sdd/2026-11-13-king-gong-banner/check.sh "banner: clear of the signs" --drill --bpm=120`
Expected: FAIL with an `ERROR: the banner [P: (0, 122.6), S: (1280, 30)…] covers the <chord> sign`
line (the drill's wrong chord, with the next sign on screen). A SCRIPT ERROR instead means a
typo in the check: fix it and run again.

- [ ] **Step 3: Put the message in a pill at the top**

- `main.tscn`: a new `[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_banner"]` beside
  `StyleBoxFlat_pill`: the pill's `bg_color` RGB at alpha 0.85, content margins about 18
  left/right and 3 top/bottom, corner radius 18 on all four corners.
- `main.tscn`: `Banner` (keep its `unique_id`) becomes a `CenterContainer`: `visible = false`,
  anchors top-wide as now (`anchors_preset = 10`, `anchor_right = 1.0`, `grow_horizontal = 2`),
  `offset_top = 34.0`, `offset_bottom = 70.0`, `mouse_filter = 2`. Child `Pill`
  (`PanelContainer`, `mouse_filter = 2`, panel `StyleBoxFlat_banner`), its child `Text`
  (`Label`, `label_settings = ExtResource("13_banner")`, centred both ways). Keep `Banner`
  where it is among the Hud children.
- `ui/banner.tres`: `font_size = 22` (from 25). Colour and outline stay.
- `scripts/hud.gd`: `_banner` becomes `Control`; add `_banner_pill: Control = $Banner/Pill`
  and `_banner_text: Label = $Banner/Pill/Text`. `show_banner` writes `_banner_text.text`;
  the fade, `show` and `hide` stay on `_banner`. `banner_rect()` returns
  `_banner_pill.get_global_rect()` while `_banner` is visible. Update the doc comment of
  `show_banner` to say where it shows: "in a pill under the progress line, above the signs".

- [ ] **Step 4: Run the checks to see them pass**

Run each (they open windows; up to three at once is fine):

| Flags | Expected lines (all of them) |
|---|---|
| `--drill --bpm=120` | `drill: 16 chords, 4 beats apart`, `drill: no note names`, `banner: clear of the signs`, `WON falls=0 bananas=4 misses=1`, `end: guard ok` |
| `--chords --bpm=120` | `banner: clear of the signs`, `WON falls=3 bananas=4` |
| `--menu --drill --bpm=120` | `banner: clear of the signs`, `menu: back on DRILL` |
| `--bpm=120` | `banner: clear of the signs`, `WON falls=2 bananas=5` |
| `--learn --bpm=120` | `banner: clear of the signs`, `WON falls=0 bananas=4 misses=1` |
| `--chords-only --bpm=120` | `banner: clear of the signs`, `WON falls=1 bananas=6` |
| `--pause --chords --bpm=120` | `pause: bass clef ok`, `WON falls=3 bananas=4` |

Pass the last expected line of each row to `check.sh` and read the printed lines for the
rest. No `ERROR` anywhere.

- [ ] **Step 5: Look at it**

Run: `& "C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe" --path godot-implementations/king-gong -- --autoplay --chords --bpm=120 --shots=<scratch dir>`
and open the shots where a message shows (the run prints `state=FALL` beside them).
Expected: the pill centred under the progress line, one line of text, clear of the signs
and the counter pill; after a shorter message the pill is shorter and still centred.

- [ ] **Step 6: README**

- The counters paragraph (after "`Esc ‖`, the pause."): add that why you fell, or what was
  wrong, shows for a moment in a dark pill under the progress line, above the chord signs.
- Learn mode: "the banner names the right one" → "the message at the top names the right one".
- Dev check list: one entry, after the `end: guard ok` one: every run also checks that the
  message, whenever it shows, covers no chord sign or key and clears the percentage and the
  counters, and prints `banner: clear of the signs` (in every mode above, as each has a fall
  or a wrong note).

- [ ] **Step 7: Hand over**

No commit. Tell the user what changed and the one command to see it:
`& "C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe" --path godot-implementations/king-gong`.
