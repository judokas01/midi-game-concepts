extends SceneTree
## Dev check, not part of the game: the menu cursor's rules, tried on throwaway buttons.
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://scripts/dev_cursor_check.gd
## Prints "cursor: ok", or an error for each rule broken.

const MenuCursor := preload("res://scripts/menu_cursor.gd")

var _failed := false


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var box := VBoxContainer.new()
	box.position = Vector2(40, 40)
	root.add_child(box)
	var p := _buttons(box, 1, 120)[0]
	var q := _buttons(_line(box), 3, 40)
	var r := _buttons(_line(box), 3, 40)
	var group := ButtonGroup.new()
	for b in r:
		b.toggle_mode = true
		b.button_group = group
	r[0].button_pressed = true
	var v_line := _line(box)
	_buttons(v_line, 1, 30)
	var v := [2]
	var t := _buttons(box, 1, 60)[0]
	t.toggle_mode = true
	var h := _buttons(box, 1, 60)[0]
	h.hide()
	var s_line := _line(box)
	var s := _buttons(s_line, 2, 40)
	s[0].custom_minimum_size.x = 84   # so the second sits under q's third
	var pressed_q2 := [0]
	q[2].pressed.connect(func() -> void: pressed_q2[0] += 1)
	var cursor := MenuCursor.new()
	root.add_child(cursor)
	var backs := [0]
	cursor.back_requested.connect(func() -> void: backs[0] += 1)
	await process_frame
	await process_frame

	var value := MenuCursor.value(func(by: int) -> void: v[0] += by,
		func(by: int) -> bool: return v[0] + by >= 0 and v[0] + by <= 2, [v_line])
	cursor.use([MenuCursor.press(p), MenuCursor.cells(q, 1), MenuCursor.choice(r, [r[0].get_parent()]), value,
		MenuCursor.press(t), MenuCursor.press(h), MenuCursor.cells(s)], 0, null, true)
	_expect(cursor.selected() == p, "it starts on the first row")
	_expect(_lit(cursor) == "CDAB", "a button: up, down, press and back are lit, not %s" % _lit(cursor))
	cursor.act(MenuCursor.Act.DOWN)
	_expect(cursor.selected() == q[1], "a row of cells starts on its own cell")
	cursor.act(MenuCursor.Act.RIGHT)
	cursor.act(MenuCursor.Act.RIGHT)
	_expect(cursor.selected() == q[0], "cells wrap round to the right")
	cursor.act(MenuCursor.Act.LEFT)
	_expect(cursor.selected() == q[2], "cells wrap round to the left")
	cursor.act(MenuCursor.Act.PRESS)
	_expect(pressed_q2[0] == 1, "A presses the cell")
	cursor.act(MenuCursor.Act.DOWN)
	_expect(cursor.selected() == r[0].get_parent(), "a choice row selects its row")
	_expect(_lit(cursor) == "CDFB", "a choice on its first option: no left, no press, not %s" % _lit(cursor))
	cursor.act(MenuCursor.Act.LEFT)
	_expect(r[0].button_pressed, "a choice stops at its first option")
	cursor.act(MenuCursor.Act.RIGHT)
	_expect(r[1].button_pressed, "a choice steps to the next option")
	cursor.act(MenuCursor.Act.DOWN)
	_expect(_lit(cursor) == "CDEB", "a value at its top: no right, no press, not %s" % _lit(cursor))
	cursor.act(MenuCursor.Act.RIGHT)
	_expect(v[0] == 2, "a value stops at its end")
	cursor.act(MenuCursor.Act.LEFT)
	_expect(v[0] == 1, "a value steps down")
	cursor.act(MenuCursor.Act.DOWN)
	cursor.act(MenuCursor.Act.LEFT)
	_expect(t.button_pressed, "left flips an on/off")
	cursor.act(MenuCursor.Act.PRESS)
	_expect(not t.button_pressed, "A flips an on/off")
	cursor.act(MenuCursor.Act.DOWN)
	_expect(cursor.selected() == s[0], "down skips a hidden row, onto the next row's own cell")
	cursor.act(MenuCursor.Act.UP)
	_expect(cursor.selected() == t, "up skips the hidden row too")
	cursor.act(MenuCursor.Act.DOWN)
	cursor.act(MenuCursor.Act.DOWN)
	_expect(cursor.selected() == p, "down from the last row wraps to the first")
	cursor.act(MenuCursor.Act.BACK)
	_expect(backs[0] == 1, "B asks to go back")
	_expect(cursor.sign_shown(), "the sign shows")

	cursor.use([MenuCursor.cells(q), MenuCursor.cells(s)], 0, null, false, 1.0)
	_expect(not cursor.sign_shown(), "the sign waits when asked to")
	_expect(not "B" in _lit(cursor), "no back where there is none")
	cursor.act(MenuCursor.Act.BACK)
	_expect(backs[0] == 1, "B does nothing where there is no back")
	q[2].mouse_entered.emit()
	_expect(cursor.selected() == q[2], "the mouse selects what it points at")
	cursor.act(MenuCursor.Act.DOWN)
	_expect(cursor.selected() == s[1], "down from a cell lands on the nearest cell below")

	print("cursor: ok" if not _failed else "cursor: failed")
	quit()


func _lit(cursor: MenuCursor) -> String:
	return "".join(cursor.lit().map(func(a: int) -> String: return "CDEFAB"[a]))


func _line(box: Container) -> HBoxContainer:
	var line := HBoxContainer.new()
	box.add_child(line)
	return line


func _buttons(parent: Container, n: int, width: int) -> Array[Button]:
	var out: Array[Button] = []
	for k in n:
		var b := Button.new()
		b.custom_minimum_size = Vector2(width, 28)
		parent.add_child(b)
		out.append(b)
	return out


func _expect(ok: bool, what: String) -> void:
	if not ok:
		_failed = true
		push_error("cursor: not so: " + what)
