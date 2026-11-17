extends Node2D

const WORLD_SIZE := Vector2(1600, 960)
const LEVEL_TWO := "res://scenes/level2.tscn"
const LESSONS := [
	{"title":"โรงเตี๊ยมข้อมูล", "topic":"ชนิดข้อมูลและตัวแปร", "prompt":"ชาวบ้านอยากเก็บอายุเป็นจำนวนเต็ม\nควรเลือกชนิดข้อมูลใดในภาษา C?", "answers":["float", "int", "char"], "correct":1, "hint":"จำนวนเต็มใช้ int เช่น int age = 18;"},
	{"title":"สะพานตรรกะ", "topic":"ตัวดำเนินการและเงื่อนไข", "prompt":"เงื่อนไขใดตรวจว่า score มีค่าตั้งแต่ 10 ขึ้นไป?", "answers":["score = 10", "score < 10", "score >= 10"], "correct":2, "hint":">= แปลว่า มากกว่าหรือเท่ากับ"},
	{"title":"กังหันวนน้ำ", "topic":"การทำงานแบบวนรอบ", "prompt":"for loop ต้องระบุองค์ประกอบใดบ้าง?", "answers":["ประกาศฟังก์ชันอย่างเดียว", "ค่าเริ่มต้น เงื่อนไข และการเปลี่ยนค่า", "แสดงผลเพียงครั้งเดียว"], "correct":1, "hint":"for มีส่วนเริ่มต้น; เงื่อนไข; การเปลี่ยนค่า"},
	{"title":"สวนอาร์เรย์", "topic":"อาร์เรย์", "prompt":"อาร์เรย์ int values[3] มี index ใดบ้าง?", "answers":["1, 2, 3", "0, 1, 2, 3", "0, 1, 2"], "correct":2, "hint":"index ของอาร์เรย์ใน C เริ่มนับจาก 0"},
	{"title":"หอจดหมายเหตุ", "topic":"การตรวจแก้โปรแกรม", "prompt":"โปรแกรมได้ผลไม่ตรงที่คาด ควรเริ่มอย่างไร?", "answers":["เปลี่ยนทุกตัวแปรทันที", "ไล่ตรวจโจทย์ ขั้นตอน และค่าระหว่างทำงาน", "ลบโปรแกรมทั้งหมด"], "correct":1, "hint":"แยกทดสอบเป็นกรณี ไล่หาจุดผิด แล้วทดสอบซ้ำ"}
]

var player: CharacterBody2D
var lesson_panel: PanelContainer
var lesson_text: RichTextLabel
var answer_buttons: Array[Button] = []
var progress_label: Label
var map_panel: PanelContainer
var message_label: Label
var message_time := 0.0
var current_lesson := -1
var solved: Dictionary = {}
var map_open := false

func _ready() -> void:
	player = $Player
	_build_ui()
	_load_progress()
	_update_gate()
	queue_redraw()

func _process(delta: float) -> void:
	if message_time > 0.0:
		message_time -= delta
		if message_time <= 0.0:
			message_label.hide()
	if Input.is_action_just_pressed("interact") and current_lesson < 0 and not map_open:
		_interact()
	if _all_lessons_solved() and player.global_position.distance_to(Vector2(1329, 455)) < 52.0:
		get_tree().change_scene_to_file(LEVEL_TWO)
	if Input.is_action_just_pressed("pause") and current_lesson < 0:
		map_open = not map_open
		map_panel.visible = map_open
		player.set_physics_process(not map_open)
	if Input.is_action_just_pressed("cancel"):
		if current_lesson >= 0:
			_close_lesson()
		elif map_open:
			map_open = false
			map_panel.hide()
			player.set_physics_process(true)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("83bd67"))
	draw_rect(Rect2(Vector2(0, 0), Vector2(365, 960)), Color("34794d"))
	draw_rect(Rect2(Vector2(355, 0), Vector2(92, 960)), Color("68a55b"))
	draw_rect(Rect2(Vector2(1130, 0), Vector2(470, 315)), Color("d8bb83"))
	draw_rect(Rect2(Vector2(1270, 265), Vector2(330, 275)), Color("e7ca91"))
	draw_rect(Rect2(Vector2(1152, 308), Vector2(448, 18)), Color("b7a073"))
	draw_rect(Rect2(Vector2(1160, 790), Vector2(440, 170)), Color("318fba"))
	draw_rect(Rect2(Vector2(1160, 780), Vector2(440, 16)), Color("7dd0c1"))
	for i in range(100):
		var p := Vector2(float((i * 173 + 47) % 1570 + 15), float((i * 97 + 31) % 930 + 15))
		if p.x < 1100 and not (p.y > 760 and p.x > 800):
			draw_rect(Rect2(p, Vector2(3, 3)), Color("6da855"))
	var path := PackedVector2Array([Vector2(0, 500), Vector2(240, 500), Vector2(310, 450), Vector2(430, 450), Vector2(520, 520), Vector2(690, 520), Vector2(790, 440), Vector2(920, 440), Vector2(1000, 520), Vector2(1200, 520), Vector2(1310, 455), Vector2(1600, 455)])
	for i in range(path.size() - 1):
		draw_line(path[i], path[i + 1], Color("d8ba78"), 34.0, true)
		draw_line(path[i], path[i + 1], Color("c8a365"), 2.0, true)
	draw_rect(Rect2(Vector2(0, 695), Vector2(520, 130)), Color("579a58"))
	draw_rect(Rect2(Vector2(0, 720), Vector2(520, 84)), Color("369fd0"))
	for i in range(20):
		var x := float(i * 29)
		draw_line(Vector2(x, 738 + sin(float(i)) * 7), Vector2(x + 16, 738 + sin(float(i)) * 7), Color("83d9e5"), 2.0)
	for i in range(5):
		draw_rect(Rect2(Vector2(240 + i * 12, 742), Vector2(13, 38)), Color("815d3d"))
		draw_rect(Rect2(Vector2(240 + i * 12, 742), Vector2(13, 4)), Color("b48652"))
	# Small flower patches, stepping stones, and shoreline sparkles add map texture.
	for i in range(34):
		var flower := Vector2(float((i * 211 + 83) % 1080 + 35), float((i * 137 + 94) % 680 + 70))
		if flower.distance_to(Vector2(260, 500)) > 60.0 and flower.distance_to(Vector2(510, 415)) > 60.0 and flower.distance_to(Vector2(790, 440)) > 60.0:
			draw_circle(flower, 3.0, Color("f2d884") if i % 2 == 0 else Color("f3efcf"))
			draw_circle(flower + Vector2(3, 2), 1.5, Color("e98f83"))
	for i in range(9):
		var stone := Vector2(580 + i * 27, 548 + sin(float(i) * 0.7) * 5.0)
		draw_rect(Rect2(stone, Vector2(8, 4)), Color("b39b70"))
	for i in range(10):
		var ripple_x := 1180.0 + i * 39.0
		draw_line(Vector2(ripple_x, 824 + sin(float(i)) * 8), Vector2(ripple_x + 20, 824 + sin(float(i)) * 8), Color("70cfe0"), 2.0)
	_draw_house(Vector2(250, 300), Color("cf794c"))
	_draw_house(Vector2(330, 320), Color("a95c45"))
	_draw_house(Vector2(1180, 300), Color("d38a55"))
	_draw_house(Vector2(1270, 320), Color("b9684b"))
	_draw_house(Vector2(1460, 260), Color("d3a35d"))
	for p in [Vector2(170,340), Vector2(440,300), Vector2(610,360), Vector2(1080,330), Vector2(1390,350), Vector2(1530,610), Vector2(670,680), Vector2(570,275)]:
		_draw_tree(p)
	for i in range(LESSONS.size()):
		_draw_kiosk(_lesson_position(i), i)
	_draw_sign(Vector2(510, 250))
	_draw_gate()

func _draw_house(p: Vector2, roof: Color) -> void:
	draw_rect(Rect2(p + Vector2(0, 15), Vector2(64, 43)), Color("f0d5a0"))
	draw_rect(Rect2(p + Vector2(8, 21), Vector2(48, 37)), Color("e9c78e"))
	draw_colored_polygon(PackedVector2Array([p + Vector2(-7, 20), p + Vector2(31, -7), p + Vector2(71, 20)]), roof)
	draw_rect(Rect2(p + Vector2(26, 37), Vector2(14, 21)), Color("76503d"))
	draw_rect(Rect2(p + Vector2(7, 29), Vector2(11, 10)), Color("94cbd0"))
	draw_rect(Rect2(p + Vector2(47, 29), Vector2(11, 10)), Color("94cbd0"))

func _draw_tree(p: Vector2) -> void:
	draw_circle(p + Vector2(1, 22), 13, Color(0.1, 0.16, 0.1, 0.25))
	draw_rect(Rect2(p + Vector2(-5, 3), Vector2(10, 25)), Color("704832"))
	draw_rect(Rect2(p + Vector2(-2, 5), Vector2(3, 22)), Color("99704a"))
	draw_circle(p, 21, Color("285a3d"))
	draw_circle(p + Vector2(-10, -6), 13, Color("34794d"))
	draw_circle(p + Vector2(9, -9), 12, Color("397e4e"))
	draw_circle(p + Vector2(1, -1), 12, Color("4d9057"))
	draw_circle(p + Vector2(-8, -12), 4, Color("71ad62"))
	draw_circle(p + Vector2(10, -14), 3, Color("6eaa5d"))

func _draw_kiosk(p: Vector2, i: int) -> void:
	var done: bool = solved.get(str(i), false)
	draw_circle(p + Vector2(0, 5), 25, Color(0.12, 0.2, 0.14, 0.3))
	draw_rect(Rect2(p + Vector2(-15, -13), Vector2(30, 28)), Color("74523b"))
	draw_rect(Rect2(p + Vector2(-12, -18), Vector2(24, 26)), Color("e7d1a3"))
	draw_colored_polygon(PackedVector2Array([p + Vector2(-18, -13), p + Vector2(0, -27), p + Vector2(18, -13)]), Color("528a69") if done else Color("4677a0"))
	draw_circle(p + Vector2(0, -4), 5, Color("f4cf74"))
	draw_circle(p + Vector2(12, -23), 6, Color("8bdc93") if done else Color("f4d469"))

func _draw_sign(p: Vector2) -> void:
	draw_rect(Rect2(p + Vector2(-3, 0), Vector2(6, 45)), Color("755039"))
	draw_rect(Rect2(p + Vector2(-93, -27), Vector2(186, 34)), Color("76513a"))
	draw_rect(Rect2(p + Vector2(-89, -23), Vector2(178, 26)), Color("dfbf7a"))

func _draw_gate() -> void:
	draw_rect(Rect2(Vector2(1300, 408), Vector2(15, 92)), Color("674a3e"))
	draw_rect(Rect2(Vector2(1343, 408), Vector2(15, 92)), Color("674a3e"))
	draw_rect(Rect2(Vector2(1300, 408), Vector2(58, 12)), Color("805940"))
	if not _all_lessons_solved():
		draw_rect(Rect2(Vector2(1314, 428), Vector2(30, 68)), Color("a94449"))
		draw_circle(Vector2(1329, 423), 7, Color("d66e69"))
	else:
		draw_circle(Vector2(1329, 423), 7, Color("65c985"))

func _lesson_position(i: int) -> Vector2:
	return [Vector2(260, 500), Vector2(510, 415), Vector2(790, 440), Vector2(1090, 500), Vector2(1210, 445)][i]

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	ui.name = "CanvasLayer"
	add_child(ui)
	var top := PanelContainer.new()
	top.position = Vector2(18, 14)
	top.size = Vector2(480, 82)
	top.add_theme_stylebox_override("panel", _panel_style(Color("20382f"), Color("e2c47e")))
	ui.add_child(top)
	var topbox := VBoxContainer.new()
	top.add_child(topbox)
	var title := Label.new()
	title.text = "✦  เกาะอัลกอริทึม — ด่าน 1"
	title.add_theme_color_override("font_color", Color("f5dfaa"))
	title.add_theme_font_size_override("font_size", 20)
	topbox.add_child(title)
	var help := Label.new()
	help.text = "21909-1005   •   WASD เดิน   •   E ตอบ/ใช้ประตู   •   M แผนที่"
	help.add_theme_color_override("font_color", Color("d0e4d0"))
	help.add_theme_font_size_override("font_size", 13)
	topbox.add_child(help)
	var progress_panel := PanelContainer.new()
	progress_panel.name = "ProgressPanel"
	progress_panel.position = Vector2(755, 18)
	progress_panel.size = Vector2(188, 54)
	progress_panel.add_theme_stylebox_override("panel", _panel_style(Color("20382f"), Color("e2c47e")))
	ui.add_child(progress_panel)
	progress_label = Label.new()
	progress_label.name = "Progress"
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.add_theme_color_override("font_color", Color("f5dfaa"))
	progress_label.add_theme_font_size_override("font_size", 17)
	progress_panel.add_child(progress_label)
	message_label = Label.new()
	message_label.position = Vector2(180, 530)
	message_label.size = Vector2(600, 54)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_color_override("font_color", Color("fff0be"))
	message_label.add_theme_font_size_override("font_size", 17)
	ui.add_child(message_label)
	var footer := Label.new()
	footer.text = "ด่าน 1: ตอบคำถามทั้ง 5 ให้ถูก แล้วเดินไปกด E ที่ประตูเพื่อเข้าสู่ด่าน 2"
	footer.position = Vector2(150, 602)
	footer.size = Vector2(660, 28)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_color_override("font_color", Color("fff1c8"))
	footer.add_theme_font_size_override("font_size", 15)
	ui.add_child(footer)
	_build_lesson_dialog(ui)
	_build_map_panel(ui)

func _build_lesson_dialog(ui: CanvasLayer) -> void:
	lesson_panel = PanelContainer.new()
	lesson_panel.position = Vector2(145, 340)
	lesson_panel.size = Vector2(670, 275)
	lesson_panel.add_theme_stylebox_override("panel", _panel_style(Color("253a38"), Color("ebca7e")))
	ui.add_child(lesson_panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	lesson_panel.add_child(content)
	lesson_text = RichTextLabel.new()
	lesson_text.bbcode_enabled = true
	lesson_text.fit_content = true
	lesson_text.custom_minimum_size = Vector2(620, 90)
	content.add_child(lesson_text)
	for i in range(3):
		var button := Button.new()
		button.custom_minimum_size = Vector2(620, 40)
		_style_button(button, Color("34514d"))
		button.pressed.connect(_answer.bind(i))
		content.add_child(button)
		answer_buttons.append(button)
	lesson_panel.hide()

func _build_map_panel(ui: CanvasLayer) -> void:
	map_panel = PanelContainer.new()
	map_panel.name = "MapPanel"
	map_panel.position = Vector2(270, 150)
	map_panel.size = Vector2(420, 325)
	map_panel.add_theme_stylebox_override("panel", _panel_style(Color("20382f"), Color("e2c47e")))
	var box := VBoxContainer.new()
	box.name = "VBoxContainer"
	box.add_theme_constant_override("separation", 12)
	map_panel.add_child(box)
	var title := Label.new()
	title.text = "แผนที่เกาะอัลกอริทึม"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("f5dfaa"))
	title.add_theme_font_size_override("font_size", 23)
	box.add_child(title)
	var detail := Label.new()
	detail.name = "MapDetail"
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_color_override("font_color", Color("deeadc"))
	box.add_child(detail)
	map_panel.hide()
	ui.add_child(map_panel)

func _panel_style(color: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 13
	style.content_margin_right = 13
	style.content_margin_top = 11
	style.content_margin_bottom = 11
	return style

func _style_button(button: Button, color: Color) -> void:
	button.add_theme_stylebox_override("normal", _panel_style(color, color.lightened(0.18)))
	button.add_theme_stylebox_override("hover", _panel_style(color.lightened(0.12), Color("f5dfaa")))
	button.add_theme_stylebox_override("pressed", _panel_style(color.darkened(0.12), Color("f5dfaa")))
	button.add_theme_color_override("font_color", Color("fff8e8"))
	button.add_theme_font_size_override("font_size", 15)

func _progress_text() -> String:
	var count := 0
	for i in range(LESSONS.size()):
		if solved.get(str(i), false):
			count += 1
	return "ด่าน 1  •  %d / %d" % [count, LESSONS.size()]

func _load_progress() -> void:
	# Start each play session from a clean slate so a previous 5/5 save
	# cannot unlock the gate before the player answers this run.
	solved.clear()
	var config := ConfigFile.new()
	config.set_value("progress", "version", 4)
	config.set_value("progress", "solved", solved)
	config.save("user://progress.cfg")
	_refresh_progress()

func _save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "version", 3)
	config.set_value("progress", "solved", solved)
	config.save("user://progress.cfg")
	_refresh_progress()

func _refresh_progress() -> void:
	progress_label.text = _progress_text()
	var detail := map_panel.get_node("VBoxContainer/MapDetail") as Label
	detail.text = "ด่าน 1  หมู่บ้านข้อมูล\nด่าน 2  แผนที่หมู่บ้านและห้องทดลองบล็อก\n\n%s\nตอบถูกครบแล้วเดินไปกด E ที่ประตู" % _progress_text()
	_update_gate()
	queue_redraw()

func _all_lessons_solved() -> bool:
	for i in range(LESSONS.size()):
		if not solved.get(str(i), false):
			return false
	return true

func _update_gate() -> void:
	var shape := get_node_or_null("Gate/CollisionShape2D") as CollisionShape2D
	if shape:
		shape.set_deferred("disabled", false)

func _interact() -> void:
	var position := player.global_position
	if position.distance_to(Vector2(1329, 455)) < 72.0:
		if not _all_lessons_solved():
			_show_message("ประตูยังปิด: ตอบคำถามให้ถูกครบ %d / %d ก่อน" % [_solved_count(), LESSONS.size()])
			return
		get_tree().change_scene_to_file(LEVEL_TWO)
		return
	var nearest := -1
	var nearest_distance := 99999.0
	for i in range(LESSONS.size()):
		var distance: float = position.distance_to(_lesson_position(i))
		if distance < 76.0 and distance < nearest_distance:
			nearest = i
			nearest_distance = distance
	if nearest < 0:
		_show_message("เข้าใกล้ศาลาเรียนรู้หรือประตู แล้วกด E")
	else:
		_open_lesson(nearest)

func _open_lesson(index: int) -> void:
	current_lesson = index
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	var lesson: Dictionary = LESSONS[index]
	lesson_text.text = "[color=#f5dfaa][b]%s — %s[/b][/color]\n%s%s" % [lesson.title, lesson.topic, lesson.prompt, "\n[ผ่านแล้ว — ทบทวนได้]" if solved.get(str(index), false) else ""]
	for i in range(3):
		answer_buttons[i].text = "%d. %s" % [i + 1, lesson.answers[i]]
	lesson_panel.show()

func _answer(index: int) -> void:
	if current_lesson < 0:
		return
	var lesson: Dictionary = LESSONS[current_lesson]
	if index != lesson.correct:
		lesson_text.text = "[color=#ffd19a][b]ยังไม่ถูก ลองอีกครั้ง[/b][/color]\n%s\n\n%s" % [lesson.hint, lesson.prompt]
		return
	var was_solved: bool = solved.get(str(current_lesson), false)
	solved[str(current_lesson)] = true
	_save_progress()
	var passed_all := _all_lessons_solved()
	_close_lesson()
	if passed_all and not was_solved:
		_show_message("ครบทั้ง 5 ข้อแล้ว! เดินไปที่ประตูด้านขวาและกด E เพื่อเข้าด่าน 2")
	else:
		_show_message("ถูกต้อง! " + lesson.hint)

func _close_lesson() -> void:
	lesson_panel.hide()
	current_lesson = -1
	player.set_physics_process(true)

func _solved_count() -> int:
	var count := 0
	for i in range(LESSONS.size()):
		if solved.get(str(i), false):
			count += 1
	return count

func _show_message(text: String) -> void:
	message_label.text = text
	message_label.show()
	message_time = 4.0
