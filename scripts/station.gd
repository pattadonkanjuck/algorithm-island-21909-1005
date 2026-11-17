extends Node2D

func _draw() -> void:
	draw_circle(Vector2(0, 7), 29.0, Color(0.12, 0.16, 0.12, 0.36))
	draw_rect(Rect2(Vector2(-22, -22), Vector2(44, 42)), Color("76523b"))
	draw_rect(Rect2(Vector2(-18, -29), Vector2(36, 34)), Color("ead398"))
	draw_rect(Rect2(Vector2(-12, -22), Vector2(24, 19)), Color("8bd8cc"))
	draw_circle(Vector2(0, -13), 5, Color("f5d26f"))
	draw_circle(Vector2(17, -25), 6, Color("f5d26f"))
