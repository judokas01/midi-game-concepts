extends RefCounted
## One layer of static scenery discs (bush blobs, canopy, floor mounds) built once into
## meshes, cut into chunks along x so a frame only draws what is on screen. The spike
## redrew these every frame; in Godot that was ~1000 circles a frame.

const Shapes := preload("res://scripts/shapes.gd")
const CHUNK := 512.0

var _parts := {}           # chunk index -> Shapes, while building
var _meshes := {}          # chunk index -> ArrayMesh
var _reach := 0.0          # widest radius, so a chunk is drawn as soon as any disc of it shows


## A disc, or its slice from `from` to `to` (radians, canvas direction).
func add_disc(c: Vector2, r: float, colour: Color, from := 0.0, to := TAU) -> void:
	var key := floori(c.x / CHUNK)
	if not _parts.has(key):
		_parts[key] = Shapes.new()
	_parts[key].ellipse(c, r, r, colour, 0.0, from, to)
	_reach = maxf(_reach, r + 1.0)


func build() -> void:
	_meshes.clear()
	for key: int in _parts:
		_meshes[key] = _parts[key].to_mesh()
	_parts.clear()


## Draws the chunks visible when the layer is scrolled by `offset` on a screen `width` wide.
func draw(ci: CanvasItem, offset: float, width: float) -> void:
	var xf := Transform2D(0.0, Vector2(-offset, 0.0))
	for key in range(floori((offset - _reach) / CHUNK), floori((offset + width + _reach) / CHUNK) + 1):
		if _meshes.has(key):
			ci.draw_mesh(_meshes[key], null, xf)
