extends Node2D

const START_SCENE := "res://scenes/title.tscn"

func _ready() -> void:
	_build_ui()
	queue_redraw()

func _draw() -> void:
	for band in range(16):
		var color := Color("27485a").lerp(Color("6c9870"), float(band) / 15.0)
		draw_rect(Rect2(Vector2(0, band * 40), Vector2(960, 40)), color)
	for i in range(42):
		var x := float((i * 137 + 41) % 950 + 5)
		var y := float((i * 83 + 26) % 420 + 12)
		var colors := [Color("f6d46f"), Color("f2a17b"), Color("a9e4c1"), Color("e5d8ff")]
		draw_circle(Vector2(x, y), 2.5 if i % 3 else 4.0, colors[i % colors.size()])
	draw_rect(Rect2(Vector2(0, 510), Vector2(960, 130)), Color("285643"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, 530), Vector2(145, 475), Vector2(280, 530)]), Color("39704f"))
	draw_colored_polygon(PackedVector2Array([Vector2(670, 530), Vector2(810, 465), Vector2(960, 530)]), Color("39704f"))
	draw_rect(Rect2(Vector2(455, 482), Vector2(50, 58)), Color("d4b577"))
	draw_colored_polygon(PackedVector2Array([Vector2(443, 487), Vector2(480, 448), Vector2(517, 487)]), Color("bf7056"))
	draw_rect(Rect2(Vector2(473, 508), Vector2(14, 32)), Color("78513b"))

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var panel := PanelContainer.new()
	panel.position = Vector2(215, 145)
	panel.size = Vector2(530, 335)
	panel.add_theme_stylebox_override("panel", _panel_style())
	ui.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 13)
	panel.add_child(content)
	var ribbon := Label.new()
	ribbon.text = "✦  เกาะอัลกอริทึม  ✦"
	ribbon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ribbon.add_theme_color_override("font_color", Color("f5dfaa"))
	ribbon.add_theme_font_size_override("font_size", 24)
	content.add_child(ribbon)
	var heading := Label.new()
	heading.text = "ยินดีด้วย คุณชนะแล้ว!"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_color_override("font_color", Color("fff2c7"))
	heading.add_theme_font_size_override("font_size", 31)
	content.add_child(heading)
	var body := Label.new()
	body.text = "คุณผ่านคำถามพื้นฐานและภารกิจเขียนโปรแกรมครบทั้ง 3 ข้อ\nตัวแปร ลูป และเงื่อนไขช่วยให้หมู่บ้านกลับมาทำงานได้อีกครั้ง"
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_color_override("font_color", Color("e4ecd9"))
	body.add_theme_font_size_override("font_size", 17)
	content.add_child(body)
	var badge := Label.new()
	badge.text = "นักแก้ปัญหาแห่งหมู่บ้าน  •  21909-1005"
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_color_override("font_color", Color("b9e7c5"))
	badge.add_theme_font_size_override("font_size", 16)
	content.add_child(badge)
	var restart := Button.new()
	restart.text = "เล่นอีกครั้ง"
	restart.custom_minimum_size = Vector2(220, 48)
	restart.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	restart.add_theme_stylebox_override("normal", _button_style(Color("3c8e68")))
	restart.add_theme_stylebox_override("hover", _button_style(Color("58a77e")))
	restart.add_theme_color_override("font_color", Color("fff8e8"))
	restart.add_theme_font_size_override("font_size", 18)
	restart.pressed.connect(_restart)
	content.add_child(restart)

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("20382f")
	style.border_color = Color("e2c47e")
	style.set_border_width_all(3)
	style.set_corner_radius_all(16)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	return style

func _button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = color.lightened(0.2)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	return style

func _restart() -> void:
	get_tree().change_scene_to_file(START_SCENE)
