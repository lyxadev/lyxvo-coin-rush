extends Area2D
# A red enemy that bounces around the arena. Touching the player ends the game.
signal hit_player

const SPEED := 180.0
var direction := Vector2(1, 0.6).normalized()
var active := false
var start_pos := Vector2(200, 150)

func _ready() -> void:
	start_pos = position
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if not active:
		return
	position += direction * SPEED * delta
	if position.x < 40 or position.x > 920:
		direction.x = -direction.x
		position.x = clamp(position.x, 40, 920)
	if position.y < 40 or position.y > 500:
		direction.y = -direction.y
		position.y = clamp(position.y, 40, 500)

func set_active(value: bool) -> void:
	active = value
	monitoring = value

func reset_position() -> void:
	position = start_pos
	direction = Vector2(1, 0.6).normalized()

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		hit_player.emit()
