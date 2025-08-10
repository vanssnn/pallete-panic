extends Node2D

var realtimetimer : RealTimeTimer = null

@onready var timer_label: Label = $UI/VBoxContainer/HBoxTimer/TimerLabel
@onready var score_label: Label = $UI/VBoxContainer/HBoxScore/ScoreLabel
@onready var score_target_label: Label = $UI/VBoxContainer/ScoreTargetLabel

@onready var score_label_info: Label = $UI/VBoxContainer/HBoxScore/ScoreLabelInfo
@onready var timer_label_info: Label = $UI/VBoxContainer/HBoxTimer/TimerLabelInfo

var score_info_tween: Tween
var timer_info_tween: Tween

func show_score_info_tween() -> void:
	if score_info_tween and score_info_tween.is_running(): score_info_tween.kill()
	score_info_tween = create_tween()
	score_info_tween.tween_callback(func(): score_label_info.visible = true)
	score_info_tween.tween_property(score_label_info, "modulate:a", 1, 0.2)
	score_info_tween.tween_interval(0.1)
	score_info_tween.tween_property(score_label_info, "modulate:a", 0, 0.2)
	score_info_tween.tween_callback(func(): score_label_info.visible = false)

func show_timer_info_tween() -> void:
	if timer_info_tween and timer_info_tween.is_running(): timer_info_tween.kill()
	timer_info_tween = create_tween()
	timer_info_tween.tween_callback(func(): timer_label_info.visible = true)
	timer_info_tween.tween_property(timer_label_info, "modulate:a", 1, 0.2)
	timer_info_tween.tween_interval(0.5)
	timer_info_tween.tween_property(timer_label_info, "modulate:a", 0, 0.2)
	timer_info_tween.tween_callback(func(): timer_label_info.visible = false)

const next_target_sfx = preload("res://sfx/cardFan1.mp3")

var score: int = 0:
	get():
		return score
	set(value):
		score = value
		score_label.text = str(score)
		
		if score >= score_target:
			AudioHandler.play_sfx(next_target_sfx, 0, randf_range(0.8, 1.2))
			score_target += score_target_accumulator
			score_target_accumulator += 10
			show_timer_info_tween()
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
	realtimetimer = RealTimeTimer.new(40, false, true)
	realtimetimer.Timeout.connect(on_realtimetimer_timeout)
	realtimetimer.OnUpdateTimer.connect(on_realtimetimer_update_timer)
	realtimetimer.start_timer()
	
func on_realtimetimer_timeout() -> void:
	player.state = Enums.PlayerState.DIE
	
	Globals.score = score
	SceneManager.change_scene("res://menu/game_over.tscn", {"pattern": "squares"})

func on_realtimetimer_update_timer(seconds_inf_float : float) -> void:
	timer_label.text = realtimetimer.remaining_seconds_to_hms()

const negative_score_sfx = preload("res://sfx/creature1.mp3")
const positive_score_sfx = preload("res://sfx/cardSlide6.mp3")

func _on_tower_interact(tower_color: Color, player_color: Color) -> void:
	var total_diff: float = absf(tower_color.r - player_color.r) + absf(tower_color.g - player_color.g) + absf(tower_color.b - player_color.b)
	var score_diff: int = 100 - ceil((total_diff/3) * 100)
	
	if (total_diff < 0.3):
		AudioHandler.play_sfx(positive_score_sfx, 0, randf_range(0.8, 1.2))
		score += score_diff
		score_label_info.text = "+" + str(score_diff)
	else:
		AudioHandler.play_sfx(negative_score_sfx, 0, randf_range(0.8, 1.2))
		score -= score_diff
		score_label_info.text = "-" + str(score_diff)
	
	show_score_info_tween()
