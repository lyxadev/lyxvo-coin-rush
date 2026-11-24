extends CharacterBody2D
# The player: arrow keys or WASD move it around the arena.
const SPEED := 320.0

func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = dir * SPEED
	move_and_slide()
	position = position.clamp(Vector2(24, 24), Vector2(936, 516))

func reset_state() -> void:
	velocity = Vector2.ZERO
