extends Node2D
# Game flow: start screen -> play (60 s timer, coins, enemies) -> game over.
const ROUND_TIME := 60.0
const SAVE_PATH := "user://highscore.save"

enum State { READY, PLAYING, OVER }

var state := State.READY
var score := 0
var best := 0
var time_left := ROUND_TIME

@onready var player = $Player
@onready var coin: Area2D = $Coin
@onready var enemy = $Enemy
@onready var score_label: Label = $UI/Score
@onready var timer_label: Label = $UI/Timer
@onready var best_label: Label = $UI/Best
@onready var start_panel: Panel = $UI/Start
@onready var over_panel: Panel = $UI/GameOver
@onready var result_label: Label = $UI/GameOver/Result

func _ready() -> void:
	randomize()
	best = _load_best()
	coin.body_entered.connect(_on_coin)
	enemy.hit_player.connect(_on_enemy_hit)
	_show_state(State.READY)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if state == State.READY or state == State.OVER:
			_start_round()

func _process(delta: float) -> void:
	if state != State.PLAYING:
		return
	time_left = max(0.0, time_left - delta)
	timer_label.text = "Time: %d" % ceil(time_left)
	if time_left <= 0.0:
		_end_game("Time's up!")

func _start_round() -> void:
	score = 0
	time_left = ROUND_TIME
	score_label.text = "Score: 0"
	timer_label.text = "Time: %d" % int(ROUND_TIME)
	player.position = Vector2(480, 270)
	player.reset_state()
	enemy.reset_position()
	_move_coin()
	_show_state(State.PLAYING)

func _on_coin(body: Node) -> void:
	if state != State.PLAYING or body != player:
		return
	score += 1
	score_label.text = "Score: %d" % score
	_move_coin()

func _on_enemy_hit() -> void:
	if state == State.PLAYING:
		_end_game("Caught by an enemy!")

func _end_game(reason: String) -> void:
	state = State.OVER
	player.set_physics_process(false)
	enemy.set_active(false)
	var new_best := score > best
	if new_best:
		best = score
		_save_best()
	best_label.text = "Best: %d" % best
	result_label.text = "%s\nScore: %d   Best: %d%s\n\nPress ENTER to play again" % [
		reason, score, best, "\nNEW HIGH SCORE!" if new_best else ""]
	_show_state(State.OVER)

func _show_state(new_state: State) -> void:
	state = new_state
	start_panel.visible = new_state == State.READY
	over_panel.visible = new_state == State.OVER
	player.set_physics_process(new_state == State.PLAYING)
	enemy.set_active(new_state == State.PLAYING)
	coin.visible = new_state == State.PLAYING
	coin.set_deferred("monitoring", new_state == State.PLAYING)
	best_label.text = "Best: %d" % best

func _move_coin() -> void:
	coin.position = Vector2(randf_range(60, 900), randf_range(60, 480))

func _load_best() -> int:
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if f:
			return int(f.get_var())
	return 0

func _save_best() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_var(best)
