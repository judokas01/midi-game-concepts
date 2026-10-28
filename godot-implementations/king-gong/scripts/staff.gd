extends RefCounted
## Where things sit, in pixels. The spike scaled one staff step to the window height; here it
## is fixed and the window stretches instead (project setting: stretch mode canvas_items).
## Across, the level is laid out in time: every beat, of a note or a rest, takes BEAT_W.

const STEP := 36.0                     # half a staff line spacing
const BEAT_W := 3.0 * STEP             # horizontal pixels per beat
const BRANCH_PER_BEAT := 2.2 * STEP    # a branch is this long per beat of its note; the rest is gap
const SKY_TOP := 44.0
const LEDGER_Y := SKY_TOP + 11.6 * STEP   # the ledger line below the staff: C4 in the treble clef, E2 in the bass
const LIANA_Y := LEDGER_Y + 4.1 * STEP
const FLOOR_Y := LEDGER_Y + 5.7 * STEP


static func x_of(beat: float) -> float:
	return beat * BEAT_W


static func y_of(step: float) -> float:
	return LEDGER_Y - step * STEP


## The middle of a note's branch, where the gorilla grips it.
static func note_pos(n: RefCounted) -> Vector2:
	return Vector2(x_of(n.beat + n.beats / 2.0), y_of(n.step))


static func branch_length(n: RefCounted) -> float:
	return n.beats * BRANCH_PER_BEAT


## The stump the gorilla starts on, left of the first branch.
static func stump_spot(first: RefCounted) -> Vector2:
	return note_pos(first) + Vector2(-branch_length(first) / 2.0 - 1.5 * STEP, 1.4 * STEP)


## The nest it ends in, right of the last branch.
static func home_spot(last: RefCounted) -> Vector2:
	return note_pos(last) + Vector2(branch_length(last) / 2.0 + 1.8 * STEP, 1.9 * STEP)
