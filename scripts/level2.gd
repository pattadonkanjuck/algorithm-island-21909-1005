extends Node2D

const MISSIONS := [
	{
		"title": "ภารกิจ 1/3 — ลูปนับเลข",
		"goal": "ใช้ลูปแสดงค่า 0, 1, 2, 3",
		"hint": "ในแต่ละรอบต้องแสดงค่าปัจจุบันก่อน แล้วค่อยเพิ่ม x",
		"blocks": ["เริ่มต้น", "กำหนด x = 0", "ทำซ้ำ 4 รอบ", "เพิ่ม x ทีละ 1", "แสดงค่า x", "จบการทำงาน"],
		"order": [0, 1, 2, 4, 3, 5],
		"output": "0   1   2   3"
	},
	{
		"title": "ภารกิจ 2/3 — ผลรวมด้วยลูป",
		"goal": "หาผลรวม 1 + 2 + 3 ให้ได้ 6",
		"hint": "กำหนด x เริ่มที่ 1 และ sum เริ่มที่ 0 จากนั้นบวกค่า x เข้า sum ก่อนเพิ่ม x",
		"blocks": ["เริ่มต้น", "กำหนด x = 1", "กำหนด sum = 0", "ทำซ้ำ 3 รอบ", "sum = sum + x", "เพิ่ม x ทีละ 1", "แสดงค่า sum", "จบการทำงาน"],
		"order": [0, 1, 2, 3, 4, 5, 6, 7],
		"output": "sum = 6"
	},
	{
		"title": "ภารกิจ 3/3 — เงื่อนไข",
		"goal": "ตรวจว่า n = 8 เป็นเลขคู่หรือเลขคี่",
		"hint": "ใช้เงื่อนไข n % 2 == 0 แล้วจัดคำสั่ง even/else ให้ตรงแขนง",
		"blocks": ["เริ่มต้น", "กำหนด n = 8", "ถ้า n % 2 == 0", "แสดง even", "มิฉะนั้น", "แสดง odd", "จบการทำงาน"],
		"order": [0, 1, 2, 3, 4, 5, 6],
		"output": "even"
	}
]
const BLOCK_COLORS := ["#e87365", "#49a8dc", "#f2ac45", "#65bd79", "#8d78d8", "#e18d56", "#68788e", "#518b9b"]
const STATION_POSITION := Vector2(752, 235)
const VICTORY_SCENE := "res://scenes/victory.tscn"

var player: CharacterBody2D
var game_panel: PanelContainer
var mission_title: Label
var mission_goal: Label
var status_label: Label
var output_label: Label
var palette: VBoxContainer
var slots: Array[PanelContainer] = []
var block_buttons: Array[Button] = []
var chosen_blocks: Array[int] = []
var game_open := false
var mission_passed := false
var mission_index := 0
var message_label: Label
var message_time := 0.0
var next_button: Button

func _ready() -> void:
	player = $Player
	_build_hud()
	queue_redraw()

func _process(delta: float) -> void:
	if message_time > 0.0:
		message_time -= delta
		if message_time <= 0.0:
			message_label.hide()
	if Input.is_action_just_pressed("interact") and not game_open:
		if player.global_position.distance_to(STATION_POSITION) < 90.0:
			_open_game()
		else:
			_show_message("เดินไปที่สถานีโปรแกรมสีทองแล้วกด E เพื่อเริ่มภารกิจ")
	if Input.is_action_just_pressed("cancel") and game_open:
		_close_game()
	player.global_position.x = clampf(player.global_position.x, 20.0, 940.0)
	player.global_position.y = clampf(player.global_position.y, 35.0, 605.0)

func _draw() -> void:
	# Procedural second-stage map: forest, village roads, river, bridge, and coast.
	draw_rect(Rect2(Vector2.ZERO, Vector2(960, 640)), Color("83bd67"))
	draw_rect(Rect2(Vector2(0, 0), Vector2(330, 640)), Color("397b4f"))
	draw_rect(Rect2(Vector2(306, 0), Vector2(74, 640)), Color("69a45b"))
	draw_rect(Rect2(Vector2(760, 0), Vector2(200, 360)), Color("d8bd8a"))
	draw_rect(Rect2(Vector2(790, 315), Vector2(170, 185)), Color("e8ce9d"))
	# Irregular coast and blue water.
	draw_colored_polygon(PackedVector2Array([Vector2(700, 640), Vector2(740, 574), Vector2(812, 542), Vector2(854, 500), Vector2(960, 500), Vector2(960, 640)]), Color("68a55b"))
	draw_colored_polygon(PackedVector2Array([Vector2(736, 640), Vector2(770, 590), Vector2(830, 555), Vector2(875, 520), Vector2(960, 520), Vector2(960, 640)]), Color("3199c1"))
	# River winds from the west to a wooden crossing.
	draw_line(Vector2(0, 500), Vector2(270, 500), Color("5b9d62"), 68.0, true)
	draw_line(Vector2(0, 500), Vector2(270, 500), Color("3199c1"), 56.0, true)
	draw_line(Vector2(270, 500), Vector2(330, 455), Color("3199c1"), 48.0, true)
	draw_line(Vector2(330, 455), Vector2(410, 455), Color("3199c1"), 42.0, true)
	for i in range(15):
		var x := float((i * 67 + 23) % 930)
		var y := float((i * 89 + 71) % 600)
		if x < 700 and not (x > 330 and x < 500 and y > 280 and y < 460):
			draw_rect(Rect2(Vector2(x, y), Vector2(4, 3)), Color("6eaa58"))
	# Broad winding road with a darker edge.
	var road := PackedVector2Array([Vector2(230, 360), Vector2(300, 405), Vector2(355, 455), Vector2(430, 455), Vector2(510, 410), Vector2(610, 370), Vector2(690, 300), Vector2(752, 235), Vector2(825, 230), Vector2(910, 245)])
	for i in range(road.size() - 1):
		draw_line(road[i], road[i + 1], Color("9d8156"), 43.0, true)
		draw_line(road[i], road[i + 1], Color("d9bd82"), 35.0, true)
	# Timber bridge over the river.
	draw_rect(Rect2(Vector2(324, 432), Vector2(28, 48)), Color("71533b"))
	for i in range(4):
		draw_rect(Rect2(Vector2(321, 435 + i * 11), Vector2(34, 6)), Color("bd8d50"))
	# Castle outpost and homes in the settlement.
	_draw_building(Vector2(170, 302), Color("72746c"), Color("4b5251"), 112, 93)
	_draw_building(Vector2(696, 125), Color("d29055"), Color("a75745"), 60, 52)
	_draw_building(Vector2(778, 116), Color("eed09a"), Color("a45543"), 62, 55)
	_draw_building(Vector2(858, 139), Color("dfb77b"), Color("8d4e43"), 56, 50)
	_draw_building(Vector2(827, 303), Color("e7c88e"), Color("ad6247"), 59, 52)
	# Woodland canopy, flower beds, stones, and water ripples.
	for tree in [Vector2(78, 130), Vector2(180, 175), Vector2(248, 217), Vector2(110, 251), Vector2(525, 180), Vector2(586, 510), Vector2(665, 454), Vector2(912, 399)]:
		_draw_tree(tree)
	for i in range(28):
		var flower := Vector2(float((i * 131 + 57) % 720 + 18), float((i * 97 + 34) % 590 + 20))
		draw_circle(flower, 2.5, Color("f5e7b2") if i % 2 == 0 else Color("ed9b83"))
	for i in range(10):
		var ripple_x := 12.0 + i * 27.0
		draw_line(Vector2(ripple_x, 488), Vector2(ripple_x + 13, 488), Color("83d9e5"), 2.0)
	for rock in [Vector2(884, 566), Vector2(926, 546), Vector2(849, 588)]:
		draw_circle(rock, 9, Color("797b78"))
		draw_circle(rock + Vector2(-2, -2), 5, Color("a6a49a"))

func _draw_building(position: Vector2, wall: Color, roof: Color, width: int, height: int) -> void:
	draw_rect(Rect2(position + Vector2(0, 17), Vector2(width, height - 17)), Color("59493e"))
	draw_rect(Rect2(position + Vector2(5, 20), Vector2(width - 10, height - 25)), wall)
	draw_colored_polygon(PackedVector2Array([position + Vector2(-8, 20), position + Vector2(width * 0.5, -12), position + Vector2(width + 8, 20)]), roof)
	draw_rect(Rect2(position + Vector2(width * 0.43, height - 24), Vector2(width * 0.18, 24)), Color("71503b"))
	draw_rect(Rect2(position + Vector2(12, 34), Vector2(10, 10)), Color("9bd4d3"))
	draw_rect(Rect2(position + Vector2(width - 22, 34), Vector2(10, 10)), Color("9bd4d3"))

func _draw_tree(position: Vector2) -> void:
	draw_circle(position + Vector2(2, 18), 16, Color(0.1, 0.16, 0.1, 0.25))
	draw_rect(Rect2(position + Vector2(-4, 2), Vector2(8, 22)), Color("704832"))
	draw_circle(position, 20, Color("285a3d"))
	draw_circle(position + Vector2(-9, -7), 12, Color("34794d"))
	draw_circle(position + Vector2(9, -8), 12, Color("397e4e"))
	draw_circle(position + Vector2(1, 1), 11, Color("55985d"))
	draw_circle(position + Vector2(-7, -13), 3, Color("8bb96a"))

func _build_hud() -> void:
	var ui := CanvasLayer.new()
	ui.name = "CanvasLayer"
	add_child(ui)
	var header := PanelContainer.new()
	header.position = Vector2(16, 14)
	header.size = Vector2(500, 78)
	header.add_theme_stylebox_override("panel", _panel_style(Color("20382f"), Color("e2c47e")))
	ui.add_child(header)
	var labels := VBoxContainer.new()
	header.add_child(labels)
	var title := Label.new()
	title.text = "ด่าน 2 — หมู่บ้านห้องทดลอง"
	title.add_theme_color_override("font_color", Color("f5dfaa"))
	title.add_theme_font_size_override("font_size", 20)
	labels.add_child(title)
	var help := Label.new()
	help.text = "WASD เดิน  •  E เริ่มภารกิจ  •  Esc ปิดหน้าต่าง"
	help.add_theme_color_override("font_color", Color("e5f0dc"))
	help.add_theme_font_size_override("font_size", 13)
	labels.add_child(help)
	message_label = Label.new()
	message_label.position = Vector2(150, 555)
	message_label.size = Vector2(660, 44)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_color_override("font_color", Color("fff1c8"))
	message_label.add_theme_font_size_override("font_size", 16)
	ui.add_child(message_label)
	var hint := Label.new()
	hint.text = "สำรวจหมู่บ้าน แล้วไปยังสถานีสีทองเพื่อทำภารกิจเขียนโค้ดแบบบล็อกทั้ง 3 ข้อ"
	hint.position = Vector2(110, 608)
	hint.size = Vector2(740, 24)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", Color("fff1c8"))
	ui.add_child(hint)
	_build_block_game(ui)

func _build_block_game(ui: CanvasLayer) -> void:
	game_panel = PanelContainer.new()
	game_panel.name = "BlockCodingGame"
	game_panel.position = Vector2(38, 45)
	game_panel.size = Vector2(884, 550)
	game_panel.add_theme_stylebox_override("panel", _panel_style(Color("202b40"), Color("ad9cf1")))
	ui.add_child(game_panel)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 15)
	game_panel.add_child(columns)
	palette = VBoxContainer.new()
	palette.custom_minimum_size = Vector2(235, 0)
	palette.add_theme_constant_override("separation", 7)
	columns.add_child(palette)
	var palette_title := Label.new()
	palette_title.text = "บล็อกคำสั่ง"
	palette_title.name = "PaletteTitle"
	palette_title.add_theme_color_override("font_color", Color("e0d7ff"))
	palette_title.add_theme_font_size_override("font_size", 20)
	palette.add_child(palette_title)
	var workspace := VBoxContainer.new()
	workspace.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	workspace.add_theme_constant_override("separation", 7)
	columns.add_child(workspace)
	mission_title = Label.new()
	mission_title.add_theme_color_override("font_color", Color("f5dfaa"))
	mission_title.add_theme_font_size_override("font_size", 20)
	workspace.add_child(mission_title)
	mission_goal = Label.new()
	mission_goal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mission_goal.add_theme_color_override("font_color", Color("d0d8e8"))
	workspace.add_child(mission_goal)
	var slot_list := VBoxContainer.new()
	slot_list.custom_minimum_size = Vector2(0, 245)
	slot_list.add_theme_constant_override("separation", 4)
	workspace.add_child(slot_list)
	for i in range(8):
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(0, 27)
		slot.add_theme_stylebox_override("panel", _panel_style(Color("303b52"), Color("535f78")))
		var slot_text := Label.new()
		slot_text.name = "Text"
		slot_text.text = "  %02d  วางบล็อกที่นี่" % (i + 1)
		slot_text.add_theme_color_override("font_color", Color("ecf1fb"))
		slot.add_child(slot_text)
		slot_list.add_child(slot)
		slots.append(slot)
	status_label = Label.new()
	status_label.text = "เรียงบล็อกให้ตรงกับโจทย์ แล้วกดตรวจและรัน"
	status_label.custom_minimum_size = Vector2(0, 28)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color("d0d8e8"))
	workspace.add_child(status_label)
	output_label = Label.new()
	output_label.text = "ผลลัพธ์: —"
	output_label.add_theme_color_override("font_color", Color("a9e6be"))
	workspace.add_child(output_label)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 6)
	workspace.add_child(actions)
	_add_action(actions, "▶ รัน", Color("388b69"), _run_program, 80)
	_add_action(actions, "ลบล่าสุด", Color("69718d"), _undo_block, 90)
	_add_action(actions, "ล้าง", Color("9d5c67"), _clear_blocks, 60)
	next_button = _add_action(actions, "ภารกิจถัดไป →", Color("397b9b"), _next_mission, 130)
	next_button.hide()
	_add_action(actions, "กลับเกม", Color("4c6484"), _close_game, 85)
	game_panel.hide()
	_refresh_mission()

func _add_action(parent: HBoxContainer, text: String, color: Color, callback: Callable, width: float) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(width, 38)
	_style_button(button, color)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _refresh_mission() -> void:
	var mission: Dictionary = MISSIONS[mission_index]
	mission_title.text = mission.title
	mission_goal.text = "เป้าหมาย: " + mission.goal
	chosen_blocks.clear()
	mission_passed = false
	status_label.text = "แตะบล็อกจากแถบซ้ายเพื่อเรียงลำดับ แล้วกดตรวจและรัน"
	output_label.text = "ผลลัพธ์: —"
	next_button.hide()
	for child in palette.get_children():
		if child.name != "PaletteTitle":
			child.queue_free()
	block_buttons.clear()
	for i in range(mission.blocks.size()):
		var block_button := Button.new()
		block_button.text = mission.blocks[i]
		block_button.custom_minimum_size = Vector2(220, 38)
		_style_button(block_button, Color(BLOCK_COLORS[i]))
		block_button.pressed.connect(_append_block.bind(i))
		palette.add_child(block_button)
		block_buttons.append(block_button)
	_refresh_slots()

func _open_game() -> void:
	game_open = true
	game_panel.show()
	player.set_physics_process(false)

func _close_game() -> void:
	game_open = false
	game_panel.hide()
	player.set_physics_process(true)

func _append_block(block_index: int) -> void:
	if mission_passed:
		return
	var mission: Dictionary = MISSIONS[mission_index]
	if chosen_blocks.size() >= mission.order.size():
		status_label.text = "บล็อกครบแล้ว ลบคำสั่งส่วนเกินหรือกดตรวจและรัน"
		return
	chosen_blocks.append(block_index)
	_refresh_slots()

func _undo_block() -> void:
	if mission_passed:
		return
	if not chosen_blocks.is_empty():
		chosen_blocks.pop_back()
	_refresh_slots()

func _clear_blocks() -> void:
	if mission_passed:
		return
	chosen_blocks.clear()
	status_label.text = "ล้างโปรแกรมแล้ว เริ่มเรียงบล็อกใหม่ได้"
	output_label.text = "ผลลัพธ์: —"
	_refresh_slots()

func _refresh_slots() -> void:
	var mission: Dictionary = MISSIONS[mission_index]
	for i in range(slots.size()):
		var slot := slots[i]
		var label := slot.get_node("Text") as Label
		if i < chosen_blocks.size():
			var block_id: int = chosen_blocks[i]
			label.text = "  %02d  %s" % [i + 1, mission.blocks[block_id]]
			slot.add_theme_stylebox_override("panel", _panel_style(Color(BLOCK_COLORS[block_id]), Color(BLOCK_COLORS[block_id]).lightened(0.2)))
		elif i < mission.order.size():
			label.text = "  %02d  วางบล็อกที่นี่" % (i + 1)
			slot.add_theme_stylebox_override("panel", _panel_style(Color("303b52"), Color("535f78")))
		else:
			label.text = ""
			slot.add_theme_stylebox_override("panel", _panel_style(Color("273247"), Color("37415a")))

func _run_program() -> void:
	if mission_passed:
		return
	var mission: Dictionary = MISSIONS[mission_index]
	if chosen_blocks.size() != mission.order.size():
		status_label.text = "วางบล็อกให้ครบ %d ช่องก่อนนะ" % mission.order.size()
		return
	for i in range(mission.order.size()):
		if chosen_blocks[i] != mission.order[i]:
			status_label.text = "ลำดับยังไม่ถูก ลองคิดตามขั้นตอนของโจทย์อีกครั้ง"
			output_label.text = "ผลลัพธ์: โปรแกรมยังทำงานไม่ตรงเป้าหมาย"
			return
	mission_passed = true
	status_label.text = "✓ สำเร็จ! " + mission.hint
	output_label.text = "ผลลัพธ์: " + mission.output
	if mission_index == MISSIONS.size() - 1:
		get_tree().change_scene_to_file(VICTORY_SCENE)
	else:
		next_button.show()

func _next_mission() -> void:
	if mission_index >= MISSIONS.size() - 1:
		return
	mission_index += 1
	_refresh_mission()

func _panel_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(9)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	return style

func _style_button(button: Button, color: Color) -> void:
	button.add_theme_stylebox_override("normal", _panel_style(color, color.lightened(0.18)))
	button.add_theme_stylebox_override("hover", _panel_style(color.lightened(0.12), Color("f5dfaa")))
	button.add_theme_stylebox_override("pressed", _panel_style(color.darkened(0.12), Color("f5dfaa")))
	button.add_theme_color_override("font_color", Color("fff8e8"))
	button.add_theme_font_size_override("font_size", 14)

func _show_message(text: String) -> void:
	message_label.text = text
	message_label.show()
	message_time = 3.5
