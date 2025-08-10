extends Control

const click_sfx = preload("res://sfx/click2.mp3")
@onready var score: Label = $Score

func _ready() -> void:
	score.text = str(Globals.score)

func _on_restart_pressed() -> void:
	AudioHandler.play_sfx(click_sfx, 0, randf_range(0.8, 1.2))
	SceneManager.change_scene(
	"res://game/game.tscn",
	{
	  "pattern": "squares",
	}
	)


func _on_home_pressed() -> void:
	AudioHandler.play_sfx(click_sfx, 0, randf_range(0.8, 1.2))
	SceneManager.change_scene(
	"res://menu/menu.tscn",
	{
	  "pattern": "squares",
	}
	)
