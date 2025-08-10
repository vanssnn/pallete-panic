extends Node2D

var realtimetimer : RealTimeTimer = null

@onready var timer_label: Label = $UI/VBoxContainer/TimerLabel
@onready var score_label: Label = $UI/VBoxContainer/ScoreLabel
@onready var score_target_label: Label = $UI/VBoxContainer/ScoreTargetLabel

var score: int = 0:
	get():
		return score
	set(value):
		score = value
		score_label.text = str(score)
		
		if score >= score_target:
			score_target += score_target_accumulator
			score_target_accumulator += 10
			realtimetimer._setup(realtimetimer.remaining_time_sec() + 10)

var score_target_accumulator: int = 100
var score_target: int = score_target_accumulator:
	get():
		return score_target
	set(value):
		score_target = value
		score_target_label.text = str(score_target)

@onready var player: CharacterBody2D = $Player
@onready var tower: Area2D = $Tower

func _ready() -> void:
	realtimetimer = RealTimeTimer.new(20, false, true)
	realtimetimer.Timeout.connect(on_realtimetimer_timeout)
	realtimetimer.OnUpdateTimer.connect(on_realtimetimer_update_timer)
	realtimetimer.start_timer()
	
func on_realtimetimer_timeout() -> void:
	player.state = Enums.PlayerState.DIE

func on_realtimetimer_update_timer(seconds_inf_float : float) -> void:
	timer_label.text = realtimetimer.remaining_seconds_to_hms()

func _on_tower_interact(tower_color: Color, player_color: Color) -> void:
	var total_diff: float = absf(tower_color.r - player_color.r) + absf(tower_color.g - player_color.g) + absf(tower_color.b - player_color.b)
	score += 100 - ceil((total_diff/3) * 100)
	realtimetimer._setup(realtimetimer.remaining_time_sec() - 5)
