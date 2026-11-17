extends Node2D

const GAME_SCENE := "res://scenes/world.tscn"

func _ready() -> void:
	_build_ui()
	queue_redraw()

func _draw() -> void:
	for band in range(16):
		var color := Color("83bdd0").lerp(Color("d9e9c1"), float(band) / 15.0)
		draw_rect(Rect2(Vector2(0, band * 40), Vector2(960, 40)), color)
	# Layered hills frame the small village and winding trail.
	draw_colored_polygon(PackedVector2Array([Vector2(0, 390), Vector2(170, 260), Vector2(350, 400), Vector2(535, 250), Vector2(760, 400), Vector2(960, 270), Vector2(960, 640), Vector2(0, 640)]), Color("78aa69"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, 465), Vector2(210, 365), Vector2(420, 485), Vector2(650, 340), Vector2(960, 475), Vector2(960, 640), Vector2(0, 640)]), Color("558c5b"))
	# Winding path leading into the settlement.
	var trail := PackedVector2Array([Vector2(485, 640), Vector2(520, 565), Vector2(430, 505), Vector2(460, 455), Vector2(560, 425), Vector2(600, 365), Vector2(520, 320)])
	for i in range(trail.size() - 1):
		draw_line(trail[i], trail[i + 1], Color("a98b5b"), 46.0, true)
		draw_line(trail[i], trail[i + 1], Color("dfc18a"), 36.0, true)
	# Tiny cottages and leafy trees.
	_draw_house(Vector2(350, 355), Color("bf7055"))
	_draw_house(Vector2(635, 315), Color("a45d4a"))
	for tree in [Vector2(250, 370), Vector2(310, 300), Vector2(730, 380), Vector2(690, 280), Vector2(185, 450), Vector2(800, 455)]:
		_draw_tree(tree)
	# Floating colorful code tiles.
	for i in range(6):
		var p := Vector2(105.0 + i * 145.0, 142.0 + sin(float(i) * 1.2) * 20.0)
		var colors := [Color("4da9db"), Color("e9a93f"), Color("65b979"), Color("8d78d8"), Color("e27869"), Color("4c9ca0")]
		draw_rect(Rect2(p, Vector2(46, 22)), colors[i])
		draw_rect(Rect2(p + Vector2(9, 22), Vector2(28, 7)), colors[i].darkened(0.12))
		draw_circle(p + Vector2(12, 11), 3, Color("fff2c7"))

func _draw_house(position: Vector2, roof: Color) -> void:
	draw_rect(Rect2(position, Vector2(70, 46)), Color("f0d5a0"))
	draw_colored_polygon(PackedVector2Array([position + Vector2(-8, 8), position + Vector2(35, -22), position + Vector2(78, 8)]), roof)
	draw_rect(Rect2(position + Vector2(29, 25), Vector2(15, 21)), Color("76503d"))
	draw_rect(Rect2(position + Vector2(8, 14), Vector2(12, 11)), Color("94cbd0"))

func _draw_tree(position: Vector2) -> void:
	draw_rect(Rect2(position + Vector2(-4, 2), Vector2(8, 22)), Color("704832"))
	draw_circle(position, 20, Color("285a3d"))
	draw_circle(position + Vector2(-9, -7), 12, Color("34794d"))
	draw_circle(position + Vector2(9, -8), 12, Color("448757"))
	draw_circle(position + Vector2(1, 1), 11, Color("55985d"))

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var panel := PanelContainer.new()
	panel.position = Vector2(245, 205)
	panel.size = Vector2(470, 270)
	panel.add_theme_stylebox_override("panel", _panel_style())
	ui.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	var eyebrow := Label.new()
	eyebrow.text = "เกมผจญภัยเพื่อการเรียนรู้  •  21909-1005"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_color_override("font_color", Color("d8e9d4"))
	eyebrow.add_theme_font_size_override("font_size", 15)
	content.add_child(eyebrow)
	var title := Label.new()
	title.text = "เกาะอัลกอริทึม"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("fff0be"))
	title.add_theme_font_size_override("font_size", 36)
	content.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "สำรวจหมู่บ้าน เรียนรู้การเขียนโปรแกรม\nแล้วช่วยชาวเกาะแก้ปัญหาไปด้วยกัน"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color("e4ecd9"))
	subtitle.add_theme_font_size_override("font_size", 17)
	content.add_child(subtitle)
	var start := Button.new()
	start.text = "▶  START"
	start.custom_minimum_size = Vector2(230, 52)
	start.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	start.add_theme_stylebox_override("normal", _button_style(Color("3c8e68")))
	start.add_theme_stylebox_override("hover", _button_style(Color("58a77e")))
	start.add_theme_color_override("font_color", Color("fff8e8"))
	start.add_theme_font_size_override("font_size", 22)
	start.pressed.connect(_start_game)
	content.add_child(start)
	var controls := Label.new()
	controls.text = "WASD / ลูกศร เดิน  •  E โต้ตอบ  •  M แผนที่"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_color_override("font_color", Color("c6d9c7"))
	controls.add_theme_font_size_override("font_size", 13)
	content.add_child(controls)

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("20382f")
	style.border_color = Color("e2c47e")
	style.set_border_width_all(3)
	style.set_corner_radius_all(16)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	return style

func _button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = color.lightened(0.2)
	style.set_border_width_all(2)
	style.set_corner_radius_all(11)
	return style

func _start_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
