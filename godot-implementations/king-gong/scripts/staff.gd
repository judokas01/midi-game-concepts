extends RefCounted
## Where things sit, in pixels. The spike scaled one staff step to the window height; here it
## is fixed and the window stretches instead (project setting: stretch mode canvas_items).

const STEP := 36.0                     # half a staff line spacing
const BEAT_W := 3.0 * STEP             # horizontal pixels per beat unit of the song layout
const SKY_TOP := 44.0
const C4_Y := SKY_TOP + 11.6 * STEP    # the C4 ledger line
const LIANA_Y := C4_Y + 4.1 * STEP
const FLOOR_Y := C4_Y + 5.7 * STEP
const HALF_BRANCH := 1.1 * STEP


static func y_of(step: float) -> float:
	return C4_Y - step * STEP


static func note_pos(n: RefCounted) -> Vector2:
	return Vector2(n.xu * BEAT_W, y_of(n.step))


## The stump the gorilla starts on, left of the first branch.
static func stump_spot(first: RefCounted) -> Vector2:
	return note_pos(first) + Vector2(-2.6, 1.4) * STEP


## The nest it ends in, right of the last branch.
static func home_spot(last: RefCounted) -> Vector2:
	return note_pos(last) + Vector2(2.9, 1.9) * STEP
