extends CharacterBody2D

const SPEED := 150.0
var facing := Vector2.DOWN
var walk_phase := 0.0

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input * SPEED
	if input.length_squared() > 0.01:
		facing = input.normalized()
		walk_phase += delta * 12.0
	else:
		walk_phase = 0.0
	move_and_slide()
	queue_redraw()

func _draw() -> void:
	var step := sin(walk_phase) * 2.0 if velocity.length() > 1.0 else 0.0
	draw_circle(Vector2(0, 10), 9, Color(0.12, 0.18, 0.14, 0.4))
	draw_rect(Rect2(Vector2(-6, 5 + step), Vector2(5, 7)), Color("493b46"))
	draw_rect(Rect2(Vector2(1, 5 - step), Vector2(5, 7)), Color("493b46"))
	draw_rect(Rect2(Vector2(-7, -2), Vector2(14, 10)), Color("397d5a"))
	draw_rect(Rect2(Vector2(-5, -1), Vector2(10, 8)), Color("55a66d"))
	draw_rect(Rect2(Vector2(-6, -12), Vector2(12, 11)), Color("f2c58b"))
	draw_rect(Rect2(Vector2(-7, -14), Vector2(14, 5)), Color("8c542d"))
	draw_rect(Rect2(Vector2(-6, -16), Vector2(12, 3)), Color("bd7a37"))
	draw_rect(Rect2(Vector2(-4, -8), Vector2(2, 2)), Color("392e35"))
	draw_rect(Rect2(Vector2(3, -8), Vector2(2, 2)), Color("392e35"))
	draw_rect(Rect2(Vector2(-3, -5), Vector2(6, 2)), Color("d88473"))
	if velocity.length() > 1.0:
		draw_rect(Rect2(Vector2(-8, -2), Vector2(3, 6)), Color("f2c58b"))
		draw_rect(Rect2(Vector2(5, -2), Vector2(3, 6)), Color("f2c58b"))

