extends RefCounted
## A vertex-coloured triangle list, drawn in a single call: as a one-off canvas command
## (`submit`) or kept as a mesh (`to_mesh`). Godot sends every circle or polygon command as
## its own draw call; hundreds of those a frame is what made the first version of this
## port slow. Edges get a one-pixel alpha feather in place of antialiasing.

var xf := Transform2D.IDENTITY   # applied to every point added
var alpha := 1.0                 # like canvas globalAlpha
var verts := PackedVector2Array()
var cols := PackedColorArray()
var idx := PackedInt32Array()


func is_empty() -> bool:
	return idx.is_empty()


## An ellipse rotated by `angle`, or the slice of it from `from` to `to`.
func ellipse(c: Vector2, rx: float, ry: float, colour: Color, angle := 0.0, from := 0.0, to := TAU) -> void:
	var col := _faded(colour)
	var rim := Color(col, 0.0)
	var seg := clampi(int(maxf(rx, ry) * 0.7), 10, 40)
	if to - from < TAU:
		seg = maxi(4, ceili(seg * (to - from) / TAU))
	var ux := Vector2.from_angle(angle)
	var uy := Vector2(-ux.y, ux.x)
	var base := verts.size()
	verts.append(xf * c)
	cols.append(col)
	for i in seg + 1:
		var a := lerpf(from, to, float(i) / seg)
		var ca := cos(a)
		var sa := sin(a)
		verts.append(xf * (c + ux * (ca * maxf(rx - 0.5, 0.0)) + uy * (sa * maxf(ry - 0.5, 0.0))))
		verts.append(xf * (c + ux * (ca * (rx + 0.5)) + uy * (sa * (ry + 0.5))))
		cols.append(col)
		cols.append(rim)
	for i in seg:
		var k := base + 1 + 2 * i
		idx.append_array(PackedInt32Array([base, k, k + 2, k, k + 1, k + 3, k, k + 3, k + 2]))


func circle(c: Vector2, r: float, colour: Color) -> void:
	ellipse(c, r, r, colour)


## A polyline `width` wide, with round caps like the spike's strokes.
func stroke(pts: PackedVector2Array, colour: Color, width: float, caps := true) -> void:
	var col := _faded(colour)
	var rim := Color(col, 0.0)
	var n := pts.size()
	var inner := maxf(width / 2.0 - 0.5, 0.0)
	var outer := width / 2.0 + 0.5
	var base := verts.size()
	for i in n:
		var d := pts[mini(i + 1, n - 1)] - pts[maxi(i - 1, 0)]
		var side := Vector2(-d.y, d.x).normalized()
		verts.append(xf * (pts[i] + side * outer))
		verts.append(xf * (pts[i] + side * inner))
		verts.append(xf * (pts[i] - side * inner))
		verts.append(xf * (pts[i] - side * outer))
		cols.append(rim)
		cols.append(col)
		cols.append(col)
		cols.append(rim)
	for i in n - 1:
		var a := base + 4 * i
		for j in 3:
			idx.append_array(PackedInt32Array([a + j, a + j + 1, a + j + 5, a + j, a + j + 5, a + j + 4]))
	if caps:
		var back := (pts[0] - pts[1]).angle()
		var ahead := (pts[n - 1] - pts[n - 2]).angle()
		ellipse(pts[0], width / 2.0, width / 2.0, colour, 0.0, back - PI / 2.0, back + PI / 2.0)
		ellipse(pts[n - 1], width / 2.0, width / 2.0, colour, 0.0, ahead - PI / 2.0, ahead + PI / 2.0)


## Any simple polygon, its outline feathered by a thin stroke.
func poly(pts: PackedVector2Array, colour: Color) -> void:
	var col := _faded(colour)
	var base := verts.size()
	for p in pts:
		verts.append(xf * p)
		cols.append(col)
	for i in Geometry2D.triangulate_polygon(pts):
		idx.append(base + i)
	var edge := pts.duplicate()
	edge.append(pts[0])
	stroke(edge, colour, 1.0, false)


func rect(r: Rect2, colour: Color) -> void:
	var col := _faded(colour)
	var base := verts.size()
	for p in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
		verts.append(xf * p)
		cols.append(col)
	idx.append_array(PackedInt32Array([base, base + 1, base + 2, base, base + 2, base + 3]))


## Adds the triangles to `ci` as one command, then starts over.
func submit(ci: CanvasItem) -> void:
	if not is_empty():
		RenderingServer.canvas_item_add_triangle_array(ci.get_canvas_item(), idx, verts, cols)
	clear()


func to_mesh() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	if is_empty():
		return mesh
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_COLOR] = cols
	arrays[Mesh.ARRAY_INDEX] = idx
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func clear() -> void:
	verts = PackedVector2Array()
	cols = PackedColorArray()
	idx = PackedInt32Array()


func _faded(c: Color) -> Color:
	return Color(c, c.a * alpha)
