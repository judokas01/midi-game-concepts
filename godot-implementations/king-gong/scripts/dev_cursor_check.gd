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

	# a value row that A presses too (the song boards' Song row opens the library)
	var opened := [0]
	var song_value := MenuCursor.value(func(by: int) -> void: v[0] += by, func(_by: int) -> bool: return true, [v_line],
		func() -> void: opened[0] += 1)
	cursor.use([song_value, MenuCursor.press(p)], 0, null, true)
	_expect(_lit(cursor) == "CDEFAB", "a value row with a press: all six lit, not %s" % _lit(cursor))
	cursor.act(MenuCursor.Act.PRESS)
	_expect(opened[0] == 1, "A on it runs its press")

	# a list the page keeps itself: C and D move in it and out of it at its ends, E and F step,
	# A presses the line selected
	var list_box := VBoxContainer.new()
	box.add_child(list_box)
	var lines := _buttons(list_box, 4, 80)
	var at := [0]
	var shelf := [0]
	var line_pressed := [-1]
	for k in lines.size():
		lines[k].pressed.connect(func() -> void: line_pressed[0] = k)
	var list := MenuCursor.list(lines,
		func(by: int) -> bool:
			if at[0] + by < 0 or at[0] + by >= lines.size():
				return false
			at[0] += by
			return true,
		func(_by: int) -> bool: return lines.size() > 1,
		func() -> Button: return lines[at[0]],
		func(b: Button) -> void: at[0] = lines.find(b),
		func(by: int) -> void: shelf[0] += by,
		func(by: int) -> bool: return shelf[0] + by >= 0,
		[list_box])
	await process_frame
	cursor.use([list, MenuCursor.press(p)], 0, null, true)
	_expect(cursor.selected() == lines[0] and _lit(cursor) == "CDFAB", "a list on its first line, at its first step: no E, not %s" % _lit(cursor))
	cursor.act(MenuCursor.Act.DOWN)
	cursor.act(MenuCursor.Act.DOWN)
	_expect(at[0] == 2 and cursor.selected() == lines[2], "D moves down the list, staying on the row")
	cursor.act(MenuCursor.Act.UP)
	_expect(at[0] == 1 and cursor.selected() == lines[1], "C moves up it")
	cursor.act(MenuCursor.Act.UP)
	cursor.act(MenuCursor.Act.UP)
	_expect(at[0] == 0 and cursor.selected() == p, "C past its first line leaves the list, for the row above")
	cursor.act(MenuCursor.Act.DOWN)
	_expect(cursor.selected() == lines[0], "D comes back into the list, on its selection")
	cursor.act(MenuCursor.Act.RIGHT)
	_expect(shelf[0] == 1 and "E" in _lit(cursor), "F steps, and E can then")
	cursor.act(MenuCursor.Act.PRESS)
	_expect(line_pressed[0] == 0, "A presses the line selected")
	lines[2].mouse_entered.emit()
	_expect(at[0] == 2 and cursor.selected() == lines[2], "the mouse on a line points at it")
	p.mouse_entered.emit()
	cursor.act(MenuCursor.Act.DOWN)
	_expect(cursor.selected() == lines[2], "from another row, D comes back to the list's line")
	var single := MenuCursor.list([lines[0]], func(_by: int) -> bool: return false, func(_by: int) -> bool: return false,
		func() -> Button: return lines[0], func(_b: Button) -> void: pass,
		func(_by: int) -> void: pass, func(_by: int) -> bool: return true, [list_box])
	cursor.use([single], 0, null, true)
	_expect(_lit(cursor) == "EFAB", "a list of one: no C or D, not %s" % _lit(cursor))
	list_box.hide()

	# the looks: gold only on what is selected, one thing at a time
	var foot := _line(box)
	var back := _wood(foot, "Back", &"Plank")
	var start := _wood(foot, "Start ▶", &"StartButton")
	await process_frame
	cursor.use([MenuCursor.cells([back, start], 1)], 0, null, true)
	await create_timer(0.3).timeout
	_expect_look(start, back, "Start selected")
	cursor.act(MenuCursor.Act.LEFT)
	await create_timer(0.3).timeout
	_expect_look(back, start, "Back selected")
	cursor.act(MenuCursor.Act.RIGHT)
	await create_timer(0.3).timeout
	_expect_look(start, back, "Start selected again")
	var theme := ThemeDB.get_project_theme()
	var rest: StyleBoxFlat = theme.get_stylebox(&"normal", &"StartButton")
	var text := theme.get_color(&"font_color", &"StartButton")
	_expect(_contrast(text, rest.bg_color) >= 4.5, "the resting yellow button's text reads: %.2f:1" % _contrast(text, rest.bg_color))
	_expect(_luminance(rest.bg_color) < 0.5 * _luminance(MenuCursor.MARK), "the resting yellow button is clearly not gold")

	print("cursor: ok" if not _failed else "cursor: failed")
	quit()


## `on` shows the selected look (its theme's hover), straight and a touch bigger; `off` its
## resting one. A yellow button's text is dark on gold, without an outline, only while selected.
func _expect_look(on: Button, off: Button, when: String) -> void:
	var theme := ThemeDB.get_project_theme()
	_expect(on.get_theme_stylebox(&"normal") == theme.get_stylebox(&"hover", on.theme_type_variation), "%s: %s looks selected" % [when, on.text])
	_expect(off.get_theme_stylebox(&"normal") == theme.get_stylebox(&"normal", off.theme_type_variation), "%s: %s looks at rest" % [when, off.text])
	_expect(on.scale.is_equal_approx(Vector2.ONE * 1.04), "%s: %s grows, scale %s" % [when, on.text, on.scale])
	_expect(off.scale.is_equal_approx(Vector2.ONE), "%s: %s is its own size, scale %s" % [when, off.text, off.scale])
	for b: Button in [on, off]:   # the mouse on it shows what the keys show
		_expect(b.get_theme_stylebox(&"hover") == b.get_theme_stylebox(&"normal") and b.get_theme_color(&"font_hover_color") == b.get_theme_color(&"font_color"),
			"%s: %s looks the same under the mouse" % [when, b.text])
	for b: Button in [on, off]:
		if b.theme_type_variation != &"StartButton":
			continue
		var lit := b == on
		_expect(b.get_theme_color(&"font_color") == theme.get_color(&"font_hover_color" if lit else &"font_color", &"StartButton"),
			"%s: the yellow button's text is %s" % [when, "dark" if lit else "cream"])
		_expect((b.get_theme_constant(&"outline_size") == 0) == lit, "%s: the yellow button's text outlined only at rest" % when)


## A Plank or a yellow button, with plank.gd, as the menus have them.
func _wood(parent: Container, text: String, variation: StringName) -> Button:
	var b := Button.new()
	b.set_script(load("res://scripts/plank.gd"))
	b.text = text
	b.theme_type_variation = variation
	parent.add_child(b)
	return b


static func _luminance(c: Color) -> float:
	return c.srgb_to_linear().get_luminance()


## WCAG contrast ratio.
static func _contrast(a: Color, b: Color) -> float:
	var hi := maxf(_luminance(a), _luminance(b))
	var lo := minf(_luminance(a), _luminance(b))
	return (hi + 0.05) / (lo + 0.05)


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
